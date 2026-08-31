/// BYD Connect service: spawns Python subprocess to fetch live vehicle data.
///
// Time-stamp: <Friday 2026-03-27 18:50:07 +1100 Graham Williams>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://opensource.org/license/gpl-3-0
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Claude, Graham Williams

library;

import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:bydpod/models/vehicle.dart';

/// BYD Connect service — Linux/desktop only.
/// Spawns byd_fetch.py as a subprocess using pybyd.
/// Requires: pip install pybyd

/// Country used when none has been chosen. BYD Sealion 7 owners in Australia
/// and New Zealand share the same regional server.
const String defaultCountry = 'AU';

class BydApiException implements Exception {
  final String message;
  BydApiException(this.message);
  @override
  String toString() => message;
}

class BydService {
  bool _authenticated = false;
  String? _username, _password, _pin;
  List<Vehicle>? _cachedVehicles;

  /// ISO country code selecting the BYD regional server. The BYD cloud is
  /// sharded by region and an account only exists on the shard it was
  /// created on, so the wrong code fails authentication rather than simply
  /// returning no vehicles.
  String _country = defaultCountry;

  bool get isAuthenticated => _authenticated;

  String get country => _country;

  String findScript() {
    final candidates = [
      '${File(Platform.resolvedExecutable).parent.path}/byd_fetch.py',
      '${Directory.current.path}/byd_fetch.py',
      '${Directory.current.parent.path}/byd_fetch.py',
    ];
    for (final path in candidates) {
      if (File(path).existsSync()) return path;
    }
    return candidates[1];
  }

  Future<String> _findPython() async {
    // Ordered preference:
    //  1. A venv created specifically for bydpod at a predictable location.
    //  2. The system python3 / python (library installed with
    //     pip install pybyd --break-system-packages).
    final home = Platform.environment['HOME'] ?? '';
    final venvCandidates = [
      '$home/.local/share/bydpod/venv/bin/python',
      '$home/.bydpod-venv/bin/python',
      '${File(Platform.resolvedExecutable).parent.path}/venv/bin/python',
    ];
    final systemCandidates = ['python3', 'python'];

    for (final cmd in [...venvCandidates, ...systemCandidates]) {
      try {
        final r = await Process.run(cmd, ['--version']);
        if (r.exitCode == 0) {
          debugPrint('[BYD] Using Python: $cmd');
          return cmd;
        }
      } catch (_) {
        // Not found at this path — try next.
      }
    }
    throw BydApiException(
      'Python 3.11 or newer not found (pybyd requires it).\n\n'
      'Option A (simplest):\n'
      '  pip install pybyd --break-system-packages\n\n'
      'Option B (venv):\n'
      '  python3 -m venv ~/.local/share/bydpod/venv\n'
      '  ~/.local/share/bydpod/venv/bin/pip install pybyd',
    );
  }

  Future<void> login({
    required String username,
    required String password,
    required String pin,
    String country = defaultCountry,
  }) async {
    _username = username;
    _password = password;
    _pin = pin;
    _country = country.isEmpty ? defaultCountry : country;
    _cachedVehicles = await _fetchFromPython();
    _authenticated = true;
  }

  Future<List<Vehicle>> getVehicles() async {
    if (_cachedVehicles != null) return _cachedVehicles!;
    return _fetchFromPython();
  }

  Future<void> refresh() async {
    _cachedVehicles = await _fetchFromPython();
  }

  Future<List<Vehicle>> _fetchFromPython() async {
    final python = await _findPython();
    final script = findScript();

    if (!File(script).existsSync()) {
      throw BydApiException(
        'byd_fetch.py not found.\nExpected at: $script',
      );
    }

    final check = await Process.run(python, ['-c', 'import pybyd']);
    debugPrint('IMPORT $python pybyd');
    if (check.exitCode != 0) {
      throw BydApiException(
        'Python library not installed.\nRun: pip install pybyd\n\n'
        'pybyd requires Python 3.11 or newer.',
      );
    }

    dev.log('[BYD] Running Python script…', name: 'BydService');
    // 20260803 gjw Log the interpreter and script actually used — a stale
    // script copy or a venv with an outdated pybyd has
    // caused wrong timestamps before, and this pins it down immediately.
    dev.log(
      '[BYD] python=$python script=$script',
      name: 'BydService',
    );

    final result = await Process.run(
      python,
      [script, _username!, _password!, _pin!, '--country', _country],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ).timeout(
      const Duration(seconds: 90),
      onTimeout: () => throw BydApiException('Timed out after 90s.'),
    );

    final stdout = (result.stdout as String).trim();
    final stderr = (result.stderr as String).trim();
    debugPrint('STDERR $stderr');
    dev.log('[BYD] exit=${result.exitCode}', name: 'BydService');
    if (stderr.isNotEmpty) {
      dev.log('[BYD] stderr=$stderr', name: 'BydService');
    }

    if (stdout.isEmpty) {
      throw BydApiException(
        'The login helper exited without output '
        '(exit code ${result.exitCode}).'
        '${stderr.isNotEmpty ? '\n\n$stderr' : ''}'
        '\n\nIf this persists, log out and back in on the official BYD '
        'Connect app, then try again.',
      );
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(stdout) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[BYD] JSON parse error: $e');
      throw BydApiException(
        'Could not parse output:\n${stdout.substring(0, stdout.length.clamp(0, 300))}',
      );
    }

    if (data.containsKey('error')) {
      final error = '${data['error']}';
      final fix = data['fix'];

      // The BYD cloud is sharded by region and an account exists only on the
      // shard it was created on, so the wrong country is indistinguishable
      // from a bad password at the API. It is the most common cause of a
      // login that fails with credentials the official app accepts, so name
      // it first. Logging out and back in on the official app also helps:
      // repeated API attempts can leave the session in a state the cloud
      // rejects until the app re-establishes it.
      final isAuthFailure = error.toLowerCase().contains('login') ||
          error.toLowerCase().contains('auth') ||
          error.toLowerCase().contains('password');

      final buffer = StringBuffer(error);
      if (fix != null) {
        buffer.write('\n\nFix: $fix');
      }
      if (isAuthFailure) {
        buffer.write(
          '\n\nCountry is currently set to $_country. BYD keeps accounts on '
          'a regional server, so the wrong country looks exactly like a wrong '
          'password — check it under Settings first.\n\n'
          'If the country and credentials are both right, log out and back in '
          'on the official BYD Connect app, then try again. Repeated attempts '
          'can temporarily lock the account until the official app '
          're-establishes a session.',
        );
      }

      // Log the Python traceback (not shown in the user dialog) to aid future
      // debugging without overwhelming the user.
      if (data['traceback'] != null) {
        dev.log(
          '[BYD] script traceback:\n${data['traceback']}',
          name: 'BydService',
        );
      }

      throw BydApiException(buffer.toString());
    }

    final rawList =
        (data['vehicles'] as List? ?? []).cast<Map<String, dynamic>>();
    if (rawList.isEmpty) {
      throw BydApiException('No vehicles found on this account.');
    }

    final fetchedAt = DateTime.now().toIso8601String();
    final vehicles = <Vehicle>[];
    for (final raw in rawList) {
      try {
        vehicles.add(Vehicle.fromApiJson({...raw, 'fetchedAt': fetchedAt}));
      } catch (e, st) {
        debugPrint('[BYD] Vehicle parse error: $e\n$st');
        dev.log('[BYD] Parse error: $e\n$st', name: 'BydService');
        throw BydApiException(
          'Failed to parse vehicle data: $e\n\nRaw: $raw',
        );
      }
    }
    _rawJson = {
      'vehicles': rawList,
      'fetchedAt': fetchedAt,
    };
    return vehicles;
  }

  /// Returns the raw JSON map from the last Python fetch (for pod saving).
  /// Caches the raw output from the Python script on each fetch.
  Map<String, dynamic>? _rawJson;

  Future<Map<String, dynamic>> getRawVehicleJson() async {
    if (_rawJson != null) return _rawJson!;
    // Re-fetch if not cached
    await _fetchFromPython();
    return _rawJson ??
        {'vehicles': [], 'fetchedAt': DateTime.now().toIso8601String()};
  }

  void logout() {
    _authenticated = false;
    _cachedVehicles = null;
    _rawJson = null;
    _username = null;
    _password = null;
    _pin = null;
    _country = defaultCountry;
  }
}
