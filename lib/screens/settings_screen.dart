/// Settings screen: BYD Connect credentials and pod setup info.
///
// Time-stamp: <Monday 2026-03-16 22:01:12 +1100 Graham Williams>
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

import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';
import 'package:provider/provider.dart';

import 'package:bydpod/constants/countries.dart';
import 'package:bydpod/screens/settings_diagnostics.dart';
import 'package:bydpod/services/app_provider.dart';
import 'package:bydpod/services/byd_service.dart';
import 'package:bydpod/theme/byd_theme.dart';
import 'package:bydpod/widgets/setup_dialog.dart';

/// Settings screen — BYD Connect credentials and app preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  String _country = defaultCountry;
  bool _obscurePass = true;
  bool _obscurePin = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    const storage = FlutterSecureStorage();
    final username = await storage.read(key: 'byd_username') ?? '';
    final password = await storage.read(key: 'byd_password') ?? '';
    final pin = await storage.read(key: 'byd_pin') ?? '';
    final country = await storage.read(key: 'byd_country') ?? defaultCountry;
    if (!mounted) return;
    setState(() {
      _emailCtrl.text = username;
      _passCtrl.text = password;
      _pinCtrl.text = pin;
      _country = bydCountries.containsKey(country) ? country : defaultCountry;
    });
  }

  Future<void> _save() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'byd_username', value: _emailCtrl.text.trim());
    await storage.write(key: 'byd_password', value: _passCtrl.text);
    await storage.write(key: 'byd_pin', value: _pinCtrl.text.trim());
    await storage.write(key: 'byd_country', value: _country);
    setState(() => _saved = true);
    Future.delayed(
      const Duration(seconds: 2),
      () => mounted ? setState(() => _saved = false) : null,
    );
  }

  Future<void> _clearAndLogout() async {
    await context.read<AppProvider>().logout();
    _emailCtrl.clear();
    _passCtrl.clear();
    _pinCtrl.clear();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('BYD Connect Credentials'),
          const Gap(4),
          Text(
            'Credentials are stored locally on this device. '
            'They are used to fetch live data via the byd_fetch.py script. '
            'The PIN is only needed for remote commands, which this app does '
            'not send, so it may be left blank.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const Gap(16),
          MarkdownTooltip(
            message: '''

            **Country**

            BYD keeps each account on a regional server, and an account only
            exists on the one it was created on. Choosing the wrong country
            makes a correct password look wrong, so set this to the country
            your BYD Connect account was registered in.

            ''',
            child: DropdownButtonFormField<String>(
              initialValue: _country,
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public_outlined),
              ),
              items: [
                for (final e in bydCountries.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _country = v ?? defaultCountry),
            ),
          ),
          const Gap(12),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'BYD Connect Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const Gap(12),
          TextField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            decoration: InputDecoration(
              labelText: 'BYD Connect Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
          ),
          const Gap(12),
          TextField(
            controller: _pinCtrl,
            obscureText: _obscurePin,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'BYD Connect PIN',
              prefixIcon: const Icon(Icons.pin_outlined),
              counterText: '',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePin
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
            ),
          ),
          const Gap(20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _save,
                icon: Icon(_saved ? Icons.check : Icons.save_outlined),
                label: Text(_saved ? 'Saved!' : 'Save Credentials'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _saved ? BydColors.success : BydColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const Gap(12),
              OutlinedButton.icon(
                onPressed: _clearAndLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Clear & Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BydColors.error,
                  side: const BorderSide(color: BydColors.error),
                ),
              ),
            ],
          ),
          const Gap(12),
          OutlinedButton.icon(
            onPressed: () => runConnectionTest(
              context: context,
              username: _emailCtrl.text.trim(),
              password: _passCtrl.text,
              pin: _pinCtrl.text.trim(),
              country: _country,
            ),
            icon: const Icon(Icons.network_check, size: 18),
            label: const Text('Test Connection'),
            style: OutlinedButton.styleFrom(
              foregroundColor: BydColors.primary,
              side: const BorderSide(color: BydColors.primary),
            ),
          ),
          const Gap(32),
          const _SectionTitle('Solid Pod'),
          const Gap(4),
          Text(
            'Vehicle snapshots are saved to your Solid Pod under bydpod/. '
            'Log in to your pod using the pod login button in the app bar.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const Gap(32),
          const _SectionTitle('BYD Connect setup'),
          const Gap(4),
          Text(
            'Live vehicle data requires the pybyd Python '
            'library and the byd_fetch.py script.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const Gap(10),
          OutlinedButton.icon(
            onPressed: _showSetupInstructions,
            icon: const Icon(Icons.info_outline, size: 18),
            label: const Text('View setup instructions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: BydColors.primary,
              side: const BorderSide(color: BydColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetupInstructions() {
    showDialog<void>(
      context: context,
      builder: (_) => const SetupDialog(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}
