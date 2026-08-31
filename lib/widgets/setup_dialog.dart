/// SetupDialog — BYD Connect setup instructions.
///
/// Shows step-by-step instructions for installing the Python library,
/// placing byd_fetch.py, and fixing keyring issues on Linux.
///
// Time-stamp: <2026-05-22>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'package:flutter/material.dart';

import 'package:gap/gap.dart';

/// Full setup instructions for BYD Connect connectivity.
/// Shown from Settings and auto-displayed when a setup-related error occurs.
class SetupDialog extends StatelessWidget {
  const SetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final code = TextStyle(
      fontFamily: 'monospace',
      fontSize: 12,
      color: cs.onSurfaceVariant,
      backgroundColor: cs.surfaceContainerHighest,
      height: 1.6,
    );
    final body = TextStyle(
      fontSize: 13,
      color: cs.onSurfaceVariant,
      height: 1.5,
    );
    final heading = body.copyWith(fontWeight: FontWeight.w700);
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.build_outlined),
          Gap(8),
          Text('BYD Connect setup'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Step 1 — Install Python 3.11 or newer', style: heading),
            const Gap(4),
            Text(
              'pybyd needs Python 3.11+. Check with: python3 --version\n'
              'If it is missing or older, on Ubuntu/Debian:',
              style: body,
            ),
            const Gap(4),
            Text('  sudo apt install python3 python3-pip', style: code),
            const Gap(16),
            Text('Step 2 — Install the library', style: heading),
            const Gap(4),
            Text('Option A — simplest (recommended):', style: body),
            const Gap(4),
            Text(
              '  pip install pybyd \\\n'
              '    --break-system-packages',
              style: code,
            ),
            const Gap(8),
            Text('Option B — virtual environment:', style: body),
            const Gap(4),
            Text(
              '  python3 -m venv \\\n'
              '    ~/.local/share/bydpod/venv\n'
              '  ~/.local/share/bydpod/venv/bin/pip \\\n'
              '    install pybyd',
              style: code,
            ),
            const Gap(4),
            Text(
              'The app finds the venv automatically — no extra config needed.',
              style: body,
            ),
            const Gap(16),
            Text('Step 3 — Place byd_fetch.py', style: heading),
            const Gap(4),
            Text(
              'Copy byd_fetch.py into the same directory as the bydpod '
              'binary. Use Settings → Test Connection to confirm the path.',
              style: body,
            ),
            const Gap(16),
            Text('Step 4 — Choose your country', style: heading),
            const Gap(4),
            Text(
              'BYD keeps each account on a regional server and an account '
              'exists only on the one it was created on, so the wrong country '
              'makes a correct password look wrong. Set it under Settings '
              '— Australia and New Zealand share a server.',
              style: body,
            ),
            const Gap(16),
            Text('Step 5 — Keyring (fresh Linux install)', style: heading),
            const Gap(4),
            Text(
              'If you see a KeyringLocked error on startup, install Seahorse '
              'and create an unlocked keyring:',
              style: body,
            ),
            const Gap(4),
            Text(
              '  sudo apt install seahorse\n'
              '  seahorse',
              style: code,
            ),
            const Gap(4),
            Text(
              'In Seahorse: File → New → Password Keyring → name it "Login" '
              '→ blank password. The keyring then unlocks automatically on '
              'desktop login.',
              style: body,
            ),
            const Gap(16),
            Text('Verify everything', style: heading),
            const Gap(4),
            Text(
              'Use Settings → Test Connection. Each prerequisite is checked '
              'in turn with a specific fix command if anything is missing.',
              style: body,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
