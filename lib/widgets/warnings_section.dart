/// WarningsSection widget listing all active vehicle warnings.
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

import 'package:gap/gap.dart';
import 'package:markdown_tooltip/markdown_tooltip.dart';

import 'package:bydpod/models/vehicle.dart';
import 'package:bydpod/theme/byd_theme.dart';
import 'package:bydpod/widgets/primitives.dart';

const _warningTips = {
  'Low fuel': '**Low Fuel**\n\nFuel level is critically low — refuel soon.',
  'Tyre pressure (all)':
      '**Tyre Pressure (All)**\n\nAll tyres are reporting abnormal pressure.',
  'Tyre pressure FL':
      '**Tyre Pressure — Front Left**\n\nFront left tyre pressure is outside the recommended range.',
  'Tyre pressure FR':
      '**Tyre Pressure — Front Right**\n\nFront right tyre pressure is outside the recommended range.',
  'Tyre pressure RL':
      '**Tyre Pressure — Rear Left**\n\nRear left tyre pressure is outside the recommended range.',
  'Tyre pressure RR':
      '**Tyre Pressure — Rear Right**\n\nRear right tyre pressure is outside the recommended range.',
  '12V battery low': '**12V Battery Low**\n\nThe auxiliary 12V battery is low. '
      'The car may not start if it drops further.',
  'Smart key battery':
      '**Smart Key Battery**\n\nThe key fob battery is running low — replace the CR2032 cell.',
  'Washer fluid low':
      '**Washer Fluid Low**\n\nWindscreen washer reservoir needs refilling.',
  'Braking fluid low':
      '**Braking Fluid Low**\n\nBrake fluid is below the minimum level — have it checked.',
  'Rapid tyre leak': '**Rapid Tyre Leak**\n\nA tyre is losing pressure fast. '
      'Stop and check before driving on.',
  'ABS': '**ABS**\n\nThe anti-lock braking system has faulted. Braking still '
      'works, but without anti-lock assistance.',
  'Airbag (SRS)': '**Airbag (SRS)**\n\nThe restraint system has faulted and '
      'airbags may not deploy. Have it checked.',
  'Stability control':
      '**Stability Control**\n\nThe electronic stability program has faulted.',
  'Power steering':
      '**Power Steering**\n\nElectric power steering has faulted — expect '
          'heavier steering effort.',
  'Power system': '**Power System**\n\nThe high-voltage drive system has '
      'reported a fault.',
  'Charging system':
      '**Charging System**\n\nThe charging system has reported a fault.',
  'Service due': '**Service Due**\n\nThe car is asking to be serviced.',
};

class WarningsSection extends StatelessWidget {
  final Vehicle v;
  const WarningsSection({super.key, required this.v});
  @override
  Widget build(BuildContext context) {
    final warnings = <String>[
      if (v.isLowFuelWarning == true) 'Low fuel',
      if (v.tyrePressureWarningAll == true) 'Tyre pressure (all)',
      if (v.tyrePressureWarningFrontLeft == true) 'Tyre pressure FL',
      if (v.tyrePressureWarningFrontRight == true) 'Tyre pressure FR',
      if (v.tyrePressureWarningRearLeft == true) 'Tyre pressure RL',
      if (v.tyrePressureWarningRearRight == true) 'Tyre pressure RR',
      if (v.is12VBatteryWarning == true) '12V battery low',
      if (v.isSmartKeyBatteryWarning == true) 'Smart key battery',
      if (v.isWasherFluidWarning == true) 'Washer fluid low',
      if (v.isBrakingFluidWarning == true) 'Braking fluid low',
      if (v.isTyreLeakWarning == true) 'Rapid tyre leak',
      if (v.isAbsWarning == true) 'ABS',
      if (v.isAirbagWarning == true) 'Airbag (SRS)',
      if (v.isStabilityWarning == true) 'Stability control',
      if (v.isSteeringWarning == true) 'Power steering',
      if (v.isPowerSystemWarning == true) 'Power system',
      if (v.isChargingSystemWarning == true) 'Charging system',
      if (v.isServiceWarning == true) 'Service due',
    ];
    return DashboardCard(
      child: warnings.isEmpty
          ? const MarkdownTooltip(
              message: '**No Active Warnings**\n\n'
                  'All monitored systems are within normal parameters. '
                  'Checks include tyre pressure, brakes, ABS, airbags, '
                  'stability control, power steering, the drive system and '
                  'the charging system.',
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: BydColors.success,
                    size: 20,
                  ),
                  Gap(10),
                  Text(
                    'No active warnings',
                    style: TextStyle(
                      color: BydColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: warnings
                  .map(
                    (w) => MarkdownTooltip(
                      message: _warningTips[w] ?? '**$w**',
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              color: BydColors.error,
                              size: 18,
                            ),
                            const Gap(8),
                            Text(
                              w,
                              style: const TextStyle(
                                color: BydColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
