/// Where the energy of the last 50 km went, as reported by BYD.
///
// Time-stamp: <Sunday 2026-08-30 00:00:00 +1000 Graham Williams>
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

import 'package:gap/gap.dart';

import 'package:bydpod/models/energy_history.dart';
import 'package:bydpod/theme/byd_theme.dart';
import 'package:bydpod/widgets/stats/stat_card.dart';

/// Colour per consumption category, in the order BYD lists them.
const _shareColours = <String, Color>{
  'Drive motor': BydColors.primary,
  'Climate': BydColors.accent,
  'Electronics': BydColors.warning,
  'Other': BydColors.midGrey,
};

/// The four-way split of the last 50 km of energy use.
///
/// BYD rounds each share independently, so they do not necessarily total 100
/// and the bar is drawn from each share's own width rather than normalised.
class DistributionCard extends StatelessWidget {
  final DriveDistribution distribution;
  const DistributionCard({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final shares = distribution.shares;

    return statsCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          statsHeading(context, 'Where the Energy Went'),
          statsSubheading(context, 'Last 50 km'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    for (final s in shares)
                      Expanded(
                        flex: s.value,
                        child: ColoredBox(
                          color: _shareColours[s.key] ?? BydColors.midGrey,
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          for (final s in shares)
            _ShareRow(
              label: s.key,
              percent: s.value,
              colour: _shareColours[s.key] ?? BydColors.midGrey,
            ),
          const Gap(8),
        ],
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  final String label;
  final int percent;
  final Color colour;
  const _ShareRow({
    required this.label,
    required this.percent,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colour,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
