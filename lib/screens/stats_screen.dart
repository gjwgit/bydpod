/// Stats screen: distance and energy figures reported by the BYD API.
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
import 'package:provider/provider.dart';

import 'package:bydpod/services/app_provider.dart';
import 'package:bydpod/widgets/stats/distribution_card.dart';
import 'package:bydpod/widgets/stats/efficiency_card.dart';
import 'package:bydpod/widgets/stats/energy_overview_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<AppProvider>().selectedVehicle;

    if (vehicle == null) {
      return const _StatsPlaceholder(
        title: 'No vehicle data',
        detail: 'Load data from BYD Connect or your Solid Pod '
            'to see statistics.',
      );
    }

    final distribution = vehicle.energyHistory?.distribution;
    final hasFigures = vehicle.odometerKm != null ||
        vehicle.efficiencyOverall != null ||
        vehicle.efficiencySinceCharging != null;

    if (!hasFigures) {
      return const _StatsPlaceholder(
        title: 'No statistics available',
        detail: 'BYD had not accumulated energy figures for this car when '
            'the snapshot was taken. Refresh once the car has been driven.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EnergyOverviewCard(vehicle: vehicle),
          const Gap(16),
          EfficiencyCard(vehicle: vehicle),
          if (distribution != null) ...[
            const Gap(16),
            DistributionCard(distribution: distribution),
          ],
          const Gap(24),
        ],
      ),
    );
  }
}

class _StatsPlaceholder extends StatelessWidget {
  final String title, detail;
  const _StatsPlaceholder({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.query_stats,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const Gap(16),
            Text(title, style: const TextStyle(fontSize: 16)),
            const Gap(8),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
