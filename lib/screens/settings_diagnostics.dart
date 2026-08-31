/// Connection-test diagnostic widgets for the Settings screen.
///
/// A small model plus a live progress dialog used by the BYD Connect
/// "Test Connection" flow in settings_screen.dart.
///
// Time-stamp: <2026-06-09>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

import 'package:bydpod/services/byd_service.dart';
import 'package:bydpod/theme/byd_theme.dart';

// ── Connection test runner ────────────────────────────────────────────────────

/// Run the BYD Connect connection diagnostic, showing a live progress dialog and
/// then a result dialog. Each step checks one prerequisite: Python + library,
/// the fetch script, credentials, and finally a live API login.
///
/// [context] must be mounted when called. Credentials and [country] are
/// passed in from the Settings form. Returns when the result dialog has been
/// shown.
Future<void> runConnectionTest({
  required BuildContext context,
  required String username,
  required String password,
  required String pin,
  String country = defaultCountry,
}) async {
  final steps = <DiagStep>[];
  final notifier = ValueNotifier<int>(0); // increment to trigger rebuild

  void addOrUpdate({required String label, bool? ok, String? detail}) {
    if (steps.isNotEmpty && steps.last.ok == null) {
      steps[steps.length - 1] = DiagStep(label: label, ok: ok, detail: detail);
    } else {
      steps.add(DiagStep(label: label, ok: ok, detail: detail));
    }
    notifier.value++;
  }

  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => DiagDialog(steps: steps, notifier: notifier),
  );

  // 20260803 gjw [okDetail] supplies a detail line for a step that PASSED
  // (evaluated after [work], so it can report values the step resolved).
  Future<void> tick(
    String label,
    Future<String?> Function() work, {
    String? Function()? okDetail,
  }) async {
    addOrUpdate(label: label); // in-progress
    String? err;
    try {
      err = await work();
    } catch (e) {
      err = e.toString();
    }
    addOrUpdate(
      label: label,
      ok: err == null,
      detail: err ?? okDetail?.call(),
    );
  }

  void finish() {
    if (context.mounted) Navigator.of(context).pop();
    if (context.mounted) _showDiagResult(context, steps);
  }

  // 1. Python with pybyd available?
  String? pythonCmd;
  await tick('Python 3.11+ with pybyd found', () async {
    final home = Platform.environment['HOME'] ?? '';
    final candidates = [
      '$home/.local/share/bydpod/venv/bin/python',
      '$home/.bydpod-venv/bin/python',
      'python3',
      'python',
    ];
    for (final cmd in candidates) {
      try {
        final ver = await Process.run(cmd, ['--version']);
        if (ver.exitCode != 0) continue;
        final imp = await Process.run(
          cmd,
          ['-c', 'import pybyd'],
        );
        if (imp.exitCode == 0) {
          pythonCmd = cmd;
          return null; // found one that has the library
        }
      } catch (_) {
        continue;
      }
    }
    return 'pybyd not found in any Python (it needs 3.11+).\n\n'
        'Option A (simplest):\n'
        '  pip install pybyd --break-system-packages\n\n'
        'Option B (venv):\n'
        '  python3 -m venv ~/.local/share/bydpod/venv\n'
        '  ~/.local/share/bydpod/venv/bin/pip install pybyd';
  });
  if (pythonCmd == null) {
    finish();
    return;
  }

  // 2. byd_fetch.py present?
  final svc = BydService();
  String? scriptPath;
  await tick(
    'byd_fetch.py found',
    () async {
      final path = svc.findScript();
      if (!File(path).existsSync()) {
        return 'Script not found at:\n$path\n\n'
            'Place byd_fetch.py next to the app binary.';
      }
      scriptPath = path;
      return null;
    },
    // 20260803 gjw Show which copy of the script was actually resolved —
    // several can exist on a dev machine and the first match wins.
    okDetail: () => scriptPath,
  );
  if (scriptPath == null) {
    finish();
    return;
  }

  // 3. Credentials entered? The PIN is only needed for remote commands,
  // which this app does not send, so it is not required here.
  await tick('Credentials entered', () async {
    if (username.isEmpty || password.isEmpty) {
      return 'Email and password must both be filled in.';
    }
    return null;
  });
  if (steps.last.ok == false) {
    finish();
    return;
  }

  // 4. Network call to BYD API.
  await tick('BYD API login for $country (up to 90s)…', () async {
    try {
      final result = await Process.run(
        pythonCmd!,
        [scriptPath!, username, password, pin, '--country', country],
        stdoutEncoding: const SystemEncoding(),
        stderrEncoding: const SystemEncoding(),
      ).timeout(const Duration(seconds: 90));
      final stdout = (result.stdout as String).trim();
      final stderr = (result.stderr as String).trim();
      if (result.exitCode != 0 || stdout.isEmpty) {
        return 'Exit code ${result.exitCode}\n'
            '${stderr.isNotEmpty ? "stderr: $stderr" : "No output"}';
      }
      if (!stdout.contains('"vehicles"')) {
        return 'Unexpected output:\n'
            '${stdout.substring(0, stdout.length.clamp(0, 300))}';
      }
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  });

  finish();
}

/// Show the final pass/fail result dialog for a completed diagnostic run.
void _showDiagResult(BuildContext context, List<DiagStep> steps) {
  final allOk = steps.every((s) => s.ok == true);
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          Icon(
            allOk ? Icons.check_circle : Icons.error_outline,
            color: allOk ? BydColors.success : BydColors.error,
          ),
          const Gap(8),
          Text(allOk ? 'Connection OK' : 'Connection failed'),
        ],
      ),
      content: SingleChildScrollView(child: DiagStepList(steps: steps)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

// ── Diagnostic step model ─────────────────────────────────────────────────────

class DiagStep {
  final String label;
  final bool? ok; // null = in progress
  final String? detail;
  const DiagStep({required this.label, this.ok, this.detail});
}

// ── Live progress dialog ──────────────────────────────────────────────────────

class DiagDialog extends StatelessWidget {
  final List<DiagStep> steps;
  final ValueNotifier<int> notifier;
  const DiagDialog({required this.steps, required this.notifier, super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Testing connection…'),
        content: SingleChildScrollView(
          child: ValueListenableBuilder<int>(
            valueListenable: notifier,
            builder: (_, __, ___) => DiagStepList(steps: steps),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      );
}

// ── Step list widget ──────────────────────────────────────────────────────────

class DiagStepList extends StatelessWidget {
  final List<DiagStep> steps;
  const DiagStepList({required this.steps, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in steps) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                child: s.ok == null
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        s.ok! ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: s.ok! ? BydColors.success : BydColors.error,
                      ),
              ),
              const Gap(6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: s.ok == false ? BydColors.error : null,
                      ),
                    ),
                    if (s.detail != null) ...[
                      const Gap(2),
                      Text(
                        s.detail!,
                        style: TextStyle(
                          fontSize: 11,
                          color: s.ok == false
                              ? BydColors.error
                              : cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Gap(10),
        ],
      ],
    );
  }
}
