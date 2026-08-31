/// Lifetime distance and energy figures reported by the BYD API.
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

import 'package:intl/intl.dart';

import 'package:bydpod/models/vehicle.dart';
import 'package:bydpod/widgets/stats/stat_card.dart';

/// Distance and energy totals for the vehicle.
///
/// BYD reports lifetime figures plus a last-50 km window, rather than the
/// per-day breakdown Bluelink cars provide, so this card presents those two
/// horizons side by side.
class EnergyOverviewCard extends StatelessWidget {
  final Vehicle vehicle;
  const EnergyOverviewCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final v = vehicle;
    final km = NumberFormat('#,##0');

    return statsCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          statsHeading(context, 'Overview'),
          statsSubheading(context, 'Distance'),
          if (v.odometerKm != null)
            StatsRow(
              'Odometer',
              '${km.format(v.odometerKm!.round())} km',
              bold: true,
              tooltip: '**Odometer**\n\n'
                  'Total distance the car has travelled, straight from the '
                  'instrument cluster.',
            ),
          if (v.totalDrivenKm != null)
            StatsRow(
              'Distance on record',
              '${km.format(v.totalDrivenKm!.round())} km',
              tooltip: '**Distance on Record**\n\n'
                  'Distance covered by the energy figures BYD has accumulated '
                  'for this car.\n\n'
                  'It can fall short of the odometer, which also counts any '
                  'driving done before the car was connected to your BYD '
                  'Connect account.',
            ),
          if (v.registrationDate != null)
            StatsRow(
              'Recording since',
              DateFormat('d MMM yyyy').format(v.registrationDate!),
              tooltip: '**Recording Since**\n\n'
                  'When the car was registered to your BYD Connect account. '
                  'Lifetime figures are accumulated from this date.',
            ),
          statsSubheading(context, 'Energy · last 50 km'),
          if (v.recent50kmEnergyKwh != null)
            StatsRow(
              'Energy used',
              '${v.recent50kmEnergyKwh!.toStringAsFixed(1)} kWh',
              bold: true,
              tooltip: '**Energy Used**\n\n'
                  'Total energy drawn from the battery over the most recent '
                  '50 km of driving.',
            ),
          if (v.efficiencySinceCharging != null)
            StatsRow(
              'Consumption',
              '${v.efficiencySinceCharging!.toStringAsFixed(1)} kWh/100km',
              tooltip: '**Consumption**\n\n'
                  'Average consumption across the last 50 km. Lower is '
                  'better — the Sealion 7 uses roughly 17 kWh/100km on the '
                  'WLTP cycle.',
            ),
          if (v.equivalentFuelConsumption != null)
            StatsRow(
              'Petrol equivalent',
              '${v.equivalentFuelConsumption!.toStringAsFixed(1)} L/100km',
              tooltip: '**Petrol Equivalent**\n\n'
                  'What the same energy would have cost a petrol car, in '
                  'litres per 100 km. BYD computes this so electric running '
                  'costs can be compared against a combustion car.',
            ),
          if (v.efficiencyOverall != null) ...[
            statsSubheading(context, 'Energy · lifetime'),
            StatsRow(
              'Consumption',
              '${v.efficiencyOverall!.toStringAsFixed(1)} kWh/100km',
              bold: true,
              tooltip: '**Lifetime Consumption**\n\n'
                  'Average consumption across every kilometre BYD has '
                  'recorded for this car.\n\n'
                  'This settles down over time and is the fairest number to '
                  'compare against the WLTP rating.',
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
