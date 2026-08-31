/// Vehicle data model: all fields, constructor, computed getters.
///
// Time-stamp: <Monday 2026-03-17 00:00:00 +1100 Graham Williams>
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

import 'package:bydpod/models/energy_history.dart';
import 'package:bydpod/models/vehicle_parser.dart';

export 'energy_history.dart';
export 'vehicle_parser.dart';

/// Full vehicle data model — populated from the pybyd Python library.
class Vehicle {
  // ── Identity ──────────────────────────────────────────────────────────────
  final String id;
  final String vin;
  final String nickname;
  final String modelName;
  final String modelYear;
  final String fuelType;
  final String color;
  final String trim;

  /// Registration plate, as recorded in the BYD Connect account.
  final String plate;

  // ── Lock / doors ─────────────────────────────────────────────────────────
  final bool? isLocked;
  final bool? isTrunkOpen;
  final bool? isBonnetOpen;
  final bool? isDoorFrontLeftOpen;
  final bool? isDoorFrontRightOpen;
  final bool? isDoorRearLeftOpen;
  final bool? isDoorRearRightOpen;

  // ── Engine / ignition ────────────────────────────────────────────────────
  final bool? isEngineRunning;
  final bool? isAccOn;

  /// Electronic parking brake engaged.
  final bool? isParkingBrakeOn;

  /// Road speed in km/h at the time of the reading.
  final double? speedKmh;

  /// Whether the T-Box reported the car as online for this reading.
  final bool? isOnline;

  // ── Climate ──────────────────────────────────────────────────────────────
  final bool? isClimateOn;
  final bool? isDefrostingOn;
  final bool? isRearWindowDefrostOn;
  final bool? isSteeringWheelHeatOn;
  final bool? isSideMirrorHeatOn;
  final double? targetTempC;
  final double? externalTempC;

  /// Cabin temperature in °C. BYD reports the interior reading rather than
  /// the outside air temperature that Bluelink cars provide.
  final double? interiorTempC;

  // ── Seat heating/cooling ─────────────────────────────────────────────────
  final int? seatHeatFrontLeft;
  final int? seatHeatFrontRight;
  final int? seatHeatRearLeft;
  final int? seatHeatRearRight;
  final int? seatCoolFrontLeft;
  final int? seatCoolFrontRight;

  // ── Fuel / range ─────────────────────────────────────────────────────────
  final double? fuelLevelPercent;
  final double? fuelRangeKm;
  final bool? isLowFuelWarning;

  // ── EV / battery ─────────────────────────────────────────────────────────
  final double? batteryLevelPercent;
  final double? evRangeKm;
  final bool? isChargingOn;
  final bool? isPluggedIn;
  final double? estimatedChargeCompletionMinutes;
  final double? batteryCapacityKwh;
  final double? batteryRemainKwh;
  final double? batterySohPercent;
  final double? chargingCurrentAc;
  final double? chargingPowerKw;
  final double? estimatedFastChargeMins;
  final double? estimatedPortableChargeMins;
  final double? estimatedStationChargeMins;
  final int? targetSocAC;
  final int? targetSocDC;
  final bool? isChargeScheduledOn;
  final double? ev12vPercent;

  /// Instantaneous traction-battery power in watts. Negative while
  /// discharging, positive while charging or regenerating.
  final double? batteryPowerWatts;

  /// Battery thermal-management heater active.
  final bool? isBatteryHeatingOn;

  // ── EV efficiency (kWh/100km) ─────────────────────────────────────────────
  /// Latest trip efficiency in kWh/100km.
  final double? efficiencyLatestTrip;

  /// Efficiency over the last 50 km in kWh/100km.
  final double? efficiencySinceCharging;

  /// Overall accumulated efficiency in kWh/100km.
  final double? efficiencyOverall;

  /// Petrol-equivalent consumption for the last 50 km, in L/100km. BYD
  /// reports this alongside the electrical figure so EV running costs can be
  /// compared against a combustion car.
  final double? equivalentFuelConsumption;

  /// Energy drawn over the last 50 km, in kWh.
  final double? recent50kmEnergyKwh;

  /// Seven-day consumption history and the drive-mode split behind it.
  final EnergyHistory? energyHistory;

  // ── 12V battery ──────────────────────────────────────────────────────────
  final int? battery12VPercent;
  final bool? is12VBatteryWarning;

  // ── Odometer / location ──────────────────────────────────────────────────
  final double? odometerKm;
  final double? latitude;
  final double? longitude;
  final String? locationAddress;

  // ── Tyre pressure ────────────────────────────────────────────────────────
  final bool? tyrePressureWarningFrontLeft;
  final bool? tyrePressureWarningFrontRight;
  final bool? tyrePressureWarningRearLeft;
  final bool? tyrePressureWarningRearRight;
  final bool? tyrePressureWarningAll;

  /// Actual tyre pressures in kPa (from data.Chassis.Axle).
  final double? tyrePressureFrontLeft;
  final double? tyrePressureFrontRight;
  final double? tyrePressureRearLeft;
  final double? tyrePressureRearRight;

  // ── Windows ──────────────────────────────────────────────────────────────
  final bool? isWindowFrontLeftOpen;
  final bool? isWindowFrontRightOpen;
  final bool? isWindowRearLeftOpen;
  final bool? isWindowRearRightOpen;
  final bool? isSunroofOpen;

  // ── Safety / warnings ────────────────────────────────────────────────────
  final bool? isSmartKeyBatteryWarning;
  final bool? isWasherFluidWarning;
  final bool? isBrakingFluidWarning;
  final bool? isAbsWarning;
  final bool? isAirbagWarning;
  final bool? isStabilityWarning;
  final bool? isSteeringWarning;
  final bool? isServiceWarning;
  final bool? isPowerSystemWarning;
  final bool? isChargingSystemWarning;
  final bool? isTyreLeakWarning;

  // ── Driving stats ─────────────────────────────────────────────────────────
  final double? totalDrivenKm;

  /// Lifetime total power consumed, in Wh (from API field total_power_consumed).
  final int? totalPowerConsumedKwh;

  /// Power consumed in the last 30 days, in Wh (from API field power_consumption_30d).
  final int? powerConsumption30dKwh;

  // ── Raw extras (everything else non-null from API) ───────────────────────
  final Map<String, dynamic> extras;

  // ── Timestamps ───────────────────────────────────────────────────────────
  final DateTime? lastUpdated;
  final DateTime? fetchedAt;
  final DateTime? registrationDate;

  const Vehicle({
    required this.id,
    required this.vin,
    required this.nickname,
    required this.modelName,
    required this.modelYear,
    required this.fuelType,
    required this.color,
    this.trim = '',
    this.plate = '',
    this.isLocked,
    this.isTrunkOpen,
    this.isBonnetOpen,
    this.isDoorFrontLeftOpen,
    this.isDoorFrontRightOpen,
    this.isDoorRearLeftOpen,
    this.isDoorRearRightOpen,
    this.isEngineRunning,
    this.isAccOn,
    this.isParkingBrakeOn,
    this.speedKmh,
    this.isOnline,
    this.isClimateOn,
    this.isDefrostingOn,
    this.isRearWindowDefrostOn,
    this.isSteeringWheelHeatOn,
    this.isSideMirrorHeatOn,
    this.targetTempC,
    this.externalTempC,
    this.interiorTempC,
    this.seatHeatFrontLeft,
    this.seatHeatFrontRight,
    this.seatHeatRearLeft,
    this.seatHeatRearRight,
    this.seatCoolFrontLeft,
    this.seatCoolFrontRight,
    this.fuelLevelPercent,
    this.fuelRangeKm,
    this.isLowFuelWarning,
    this.batteryLevelPercent,
    this.evRangeKm,
    this.isChargingOn,
    this.isPluggedIn,
    this.estimatedChargeCompletionMinutes,
    this.batteryCapacityKwh,
    this.batteryRemainKwh,
    this.batterySohPercent,
    this.chargingCurrentAc,
    this.chargingPowerKw,
    this.estimatedFastChargeMins,
    this.estimatedPortableChargeMins,
    this.estimatedStationChargeMins,
    this.targetSocAC,
    this.targetSocDC,
    this.isChargeScheduledOn,
    this.ev12vPercent,
    this.batteryPowerWatts,
    this.isBatteryHeatingOn,
    this.efficiencyLatestTrip,
    this.efficiencySinceCharging,
    this.efficiencyOverall,
    this.equivalentFuelConsumption,
    this.recent50kmEnergyKwh,
    this.energyHistory,
    this.battery12VPercent,
    this.is12VBatteryWarning,
    this.odometerKm,
    this.latitude,
    this.longitude,
    this.locationAddress,
    this.tyrePressureWarningFrontLeft,
    this.tyrePressureWarningFrontRight,
    this.tyrePressureWarningRearLeft,
    this.tyrePressureWarningRearRight,
    this.tyrePressureWarningAll,
    this.tyrePressureFrontLeft,
    this.tyrePressureFrontRight,
    this.tyrePressureRearLeft,
    this.tyrePressureRearRight,
    this.isWindowFrontLeftOpen,
    this.isWindowFrontRightOpen,
    this.isWindowRearLeftOpen,
    this.isWindowRearRightOpen,
    this.isSunroofOpen,
    this.isSmartKeyBatteryWarning,
    this.isWasherFluidWarning,
    this.isBrakingFluidWarning,
    this.isAbsWarning,
    this.isAirbagWarning,
    this.isStabilityWarning,
    this.isSteeringWarning,
    this.isServiceWarning,
    this.isPowerSystemWarning,
    this.isChargingSystemWarning,
    this.isTyreLeakWarning,
    this.totalDrivenKm,
    this.totalPowerConsumedKwh,
    this.powerConsumption30dKwh,
    this.extras = const {},
    this.lastUpdated,
    this.fetchedAt,
    this.registrationDate,
  });

  bool get isEV => fuelType == 'EV' || fuelType == 'PHEV';
  bool get isICE =>
      fuelType == 'ICE' || fuelType == 'HEV' || fuelType == 'PHEV';

  factory Vehicle.fromApiJson(Map<String, dynamic> j) =>
      parseVehicleFromJson(j);

  factory Vehicle.mock() => mockVehicle();
}
