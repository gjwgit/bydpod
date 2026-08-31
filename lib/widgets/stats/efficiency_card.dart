/// Efficiency card: the three consumption horizons BYD reports, plus the
/// spread of the last seven days.
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

import 'package:bydpod/models/vehicle.dart';
import 'package:bydpod/theme/byd_theme.dart';
import 'package:bydpod/widgets/stats/stat_card.dart';

// Consumption bands in kWh/100km, calibrated for the Sealion 7 around its
// ~17 kWh/100km WLTP figure. A lighter or heavier BYD sits differently, so
// treat these as a rough guide rather than a verdict.
const _bands = <({String label, double from, double to, Color colour})>[
  (label: '< 15  Excellent', from: 0, to: 15, colour: BydColors.success),
  (label: '15–18  Good', from: 15, to: 18, colour: BydColors.accent),
  (label: '18–21  Fair', from: 18, to: 21, colour: BydColors.warning),
  (
    label: '≥ 21   Heavy',
    from: 21,
    to: double.infinity,
    colour: BydColors.error
  ),
];

// ── Efficiency card ───────────────────────────────────────────────────────────

class EfficiencyCard extends StatelessWidget {
  final Vehicle vehicle;
  const EfficiencyCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final v = vehicle;
    final history = v.energyHistory;
    final days = history?.series ?? const <double>[];

    Widget divider() => Divider(
          height: 1,
          color: cs.outlineVariant,
          indent: 16,
          endIndent: 16,
        );

    return statsCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          statsHeading(context, 'Efficiency'),
          statsSubheading(context, 'kWh/100km · lower is better'),
          if (v.efficiencyLatestTrip != null) ...[
            StatsRow(
              'Current trip',
              '${v.efficiencyLatestTrip!.toStringAsFixed(1)} kWh/100km',
              tooltip: '**Current Trip**\n\n'
                  'Consumption since the car was last switched on.\n\n'
                  'Short trips read high: warming the cabin and the battery '
                  'costs the same energy whether you drive 2 km or 50 km.',
            ),
            divider(),
          ],
          if (v.efficiencySinceCharging != null) ...[
            StatsRow(
              'Last 50 km',
              '${v.efficiencySinceCharging!.toStringAsFixed(1)} kWh/100km',
              bold: true,
              tooltip: '**Last 50 km**\n\n'
                  'Rolling average over the most recent 50 km. This is the '
                  'figure BYD headlines on its own energy page.\n\n'
                  'It is long enough to smooth out one cold start but short '
                  'enough to still reflect how you have been driving lately.',
            ),
            divider(),
          ],
          if (v.efficiencyOverall != null) ...[
            StatsRow(
              'Lifetime',
              '${v.efficiencyOverall!.toStringAsFixed(1)} kWh/100km',
              tooltip: '**Lifetime Efficiency**\n\n'
                  'Long-run average reported by the car across all driving '
                  'BYD has recorded.\n\n'
                  'The Sealion 7 draws roughly 17 kWh/100km from the battery '
                  'on the WLTP cycle; 15–20 kWh/100km is typical in the real '
                  'world depending on speed, temperature and climate use.',
            ),
          ],
          if (history != null && history.hasSeries) ...[
            statsSubheading(context, 'Last ${days.length} days'),
            StatsRow(
              'Best day',
              '${history.best!.toStringAsFixed(1)} kWh/100km',
              valueColor: BydColors.success,
              tooltip: '**Best Day**\n\n'
                  'The most efficient of the days in the series.\n\n'
                  'Steady low-speed driving with plenty of regenerative '
                  'braking gives the best figures.',
            ),
            divider(),
            StatsRow(
              'Worst day',
              '${history.worst!.toStringAsFixed(1)} kWh/100km',
              valueColor: BydColors.warning,
              tooltip: '**Worst Day**\n\n'
                  'The least efficient of the days in the series.\n\n'
                  'Highway speed, cold weather and heavy climate use all '
                  'push consumption up.',
            ),
            if (history.modelAverageMean != null) ...[
              divider(),
              StatsRow(
                'Model average',
                '${history.modelAverageMean!.toStringAsFixed(1)} kWh/100km',
                tooltip: '**Model Average**\n\n'
                    'What BYD sees across the whole fleet of this model over '
                    'the same period — a like-for-like benchmark for your '
                    'own figures.',
              ),
            ],
            statsSubheading(context, 'Day distribution'),
            for (final band in _bands) ...[
              BandBar(
                label: band.label,
                count: days.where((d) => d >= band.from && d < band.to).length,
                total: days.length,
                color: band.colour,
              ),
              const Gap(4),
            ],
          ],
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class BandBar extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const BandBar({
    super.key,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final frac = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: frac,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const Gap(8),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: count > 0 ? color : cs.onSurfaceVariant,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
