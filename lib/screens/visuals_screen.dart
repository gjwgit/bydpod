/// Driving screen: charts of the consumption history BYD reports.
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
import 'package:bydpod/widgets/consumption_chart.dart';
import 'package:bydpod/widgets/stats/distribution_card.dart';
import 'package:bydpod/widgets/visuals/chart_section.dart';

class VisualsScreen extends StatelessWidget {
  const VisualsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<AppProvider>().selectedVehicle;

    if (vehicle == null) {
      return _placeholder(
        context,
        'No vehicle data loaded.',
        'Load a BYD Connect snapshot or pod data first.',
      );
    }

    final history = vehicle.energyHistory;
    if (history == null || !history.hasSeries) {
      return _placeholder(
        context,
        'No consumption history available.',
        'BYD builds this series once the car has been driven over several '
            'days. Refresh again after a few trips.',
      );
    }

    final average = history.average;
    final distribution = history.distribution;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChartSection(
            title: 'Daily Energy Consumption',
            subtitle: average == null
                ? history.unit
                : '${history.unit} · ${average.toStringAsFixed(1)} average',
            tooltip: '**Daily Energy Consumption**\n\n'
                'How much energy the car used per 100 km on each of the last '
                'few days. The number above each bar is that day\'s figure.\n\n'
                'The dashed line is the average across every Sealion 7 BYD '
                'sees, so a bar below it is a better-than-typical day. Bars '
                'above the line are shown in amber.\n\n'
                'BYD supplies this series in order but without dates, so the '
                'bars are labelled by how many days back each reading is.',
            chart: ConsumptionChart(history: history),
          ),
          if (distribution != null) ...[
            const Gap(24),
            DistributionCard(distribution: distribution),
          ],
          const Gap(24),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context, String title, String detail) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart,
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
