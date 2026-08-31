/// Parses raw BYD API JSON into a Vehicle; provides mock data.
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

import 'package:bydpod/models/vehicle.dart';

/// Keys byd_fetch.py emits that map onto a named [Vehicle] field. Anything
/// outside this set is surfaced in the raw-data view as an extra, so a new
/// field appearing in the BYD API shows up in the app without a code change.
const _knownKeys = {
  'vehicleId',
  'vin',
  'name',
  'model',
  'brand',
  'trim',
  'plate',
  'engine_type',
  'is_locked',
  'trunk_is_open',
  'hood_is_open',
  'front_left_door_is_open',
  'front_right_door_is_open',
  'back_left_door_is_open',
  'back_right_door_is_open',
  'engine_is_running',
  'speed',
  'parking_brake_is_on',
  'set_temperature',
  'interior_temperature',
  'steering_wheel_heater_is_on',
  'front_left_seat_status',
  'front_right_seat_status',
  'rear_left_seat_status',
  'rear_right_seat_status',
  'front_left_seat_cool_status',
  'front_right_seat_cool_status',
  'ev_battery_percentage',
  'ev_driving_range',
  'ev_battery_is_charging',
  'ev_battery_is_plugged_in',
  'ev_estimated_current_charge_duration',
  'ev_charging_power',
  'ev_charge_scheduled_on',
  'battery_power_watts',
  'battery_heating_is_on',
  'fuel_level',
  'fuel_driving_range',
  'odometer',
  'location_latitude',
  'location_longitude',
  'tire_pressure_front_left',
  'tire_pressure_front_right',
  'tire_pressure_rear_left',
  'tire_pressure_rear_right',
  'tire_pressure_front_left_warning_is_on',
  'tire_pressure_front_right_warning_is_on',
  'tire_pressure_rear_left_warning_is_on',
  'tire_pressure_rear_right_warning_is_on',
  'tire_pressure_all_warning_is_on',
  'front_left_window_is_open',
  'front_right_window_is_open',
  'back_left_window_is_open',
  'back_right_window_is_open',
  'sunroof_is_open',
  'brake_fluid_warning_is_on',
  'abs_warning_is_on',
  'airbag_warning_is_on',
  'stability_warning_is_on',
  'steering_warning_is_on',
  'service_warning_is_on',
  'power_system_warning_is_on',
  'charging_system_warning_is_on',
  'tire_leak_warning_is_on',
  'efficiency_latest_trip',
  'efficiency_recent_50km',
  'efficiency_overall',
  'equivalent_fuel_consumption',
  'recent_50km_energy_kwh',
  'total_driving_range',
  'energy_history',
  'drive_distribution',
  'last_updated_at',
  'registration_date',
  'gps_timestamp',
  'is_online',
  'fetchedAt',
};

/// Parses a raw API JSON map into a [Vehicle].
/// Separated from [Vehicle] to keep the model class under the line limit.
Vehicle parseVehicleFromJson(Map<String, dynamic> j) {
  // byd_fetch.py decodes BYD's enums and sentinel values before emitting, so
  // booleans arrive as JSON true/false and absent readings are simply missing
  // keys rather than -1 / "--" placeholders.
  bool? b(String k) {
    final v = j[k];
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v == 'true' || v == '1';
    return null;
  }

  double? d(String k) {
    final v = j[k];
    if (v == null || v is bool) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  int? i(String k) {
    final v = j[k];
    if (v == null) return null;
    if (v is bool) return v ? 1 : 0;
    if (v is num) return v.round();
    return int.tryParse(v.toString());
  }

  DateTime? t(String k) =>
      j[k] == null ? null : DateTime.tryParse(j[k].toString())?.toLocal();

  Map<String, dynamic>? m(String k) =>
      j[k] is Map ? (j[k] as Map).cast<String, dynamic>() : null;

  // BYD reports the powertrain as EV, ICE or PHEV. Anything unrecognised is
  // treated as an EV — every BYD sold in Australia is at least partly one,
  // and the battery sections are the more useful default.
  final engine = j['engine_type']?.toString().toUpperCase() ?? '';
  final fuelType =
      const {'EV', 'ICE', 'PHEV', 'HEV'}.contains(engine) ? engine : 'EV';

  // Only scalars go into extras: the raw-data view renders each value with
  // toString(), so a nested map would arrive as one unreadable line.
  final extras = <String, dynamic>{};
  for (final entry in j.entries) {
    final v = entry.value;
    if (!_knownKeys.contains(entry.key) &&
        v != null &&
        v is! Map &&
        v is! List &&
        v != false &&
        v != '' &&
        v != 0) {
      extras[entry.key] = v;
    }
  }

  return Vehicle(
    id: j['vehicleId']?.toString() ?? j['vin']?.toString() ?? '',
    vin: j['vin']?.toString() ?? '',
    nickname: j['name']?.toString() ?? 'My BYD',
    modelName: j['model']?.toString() ?? '',
    // BYD's account API carries no model year — the purchase date is the
    // closest thing, and it is surfaced separately as the registration date
    // rather than being passed off as a model year.
    modelYear: '',
    fuelType: fuelType,
    color: '',
    trim: j['trim']?.toString() ?? '',
    plate: j['plate']?.toString() ?? '',
    isLocked: b('is_locked'),
    isTrunkOpen: b('trunk_is_open'),
    isBonnetOpen: b('hood_is_open'),
    isDoorFrontLeftOpen: b('front_left_door_is_open'),
    isDoorFrontRightOpen: b('front_right_door_is_open'),
    isDoorRearLeftOpen: b('back_left_door_is_open'),
    isDoorRearRightOpen: b('back_right_door_is_open'),
    isEngineRunning: b('engine_is_running'),
    isParkingBrakeOn: b('parking_brake_is_on'),
    speedKmh: d('speed'),
    isOnline: b('is_online'),
    isSteeringWheelHeatOn: b('steering_wheel_heater_is_on'),
    targetTempC: d('set_temperature'),
    interiorTempC: d('interior_temperature'),
    seatHeatFrontLeft: i('front_left_seat_status'),
    seatHeatFrontRight: i('front_right_seat_status'),
    seatHeatRearLeft: i('rear_left_seat_status'),
    seatHeatRearRight: i('rear_right_seat_status'),
    seatCoolFrontLeft: i('front_left_seat_cool_status'),
    seatCoolFrontRight: i('front_right_seat_cool_status'),
    fuelLevelPercent: d('fuel_level'),
    fuelRangeKm: d('fuel_driving_range'),
    batteryLevelPercent: d('ev_battery_percentage'),
    evRangeKm: d('ev_driving_range'),
    isChargingOn: b('ev_battery_is_charging'),
    isPluggedIn: b('ev_battery_is_plugged_in'),
    estimatedChargeCompletionMinutes: d('ev_estimated_current_charge_duration'),
    chargingPowerKw: d('ev_charging_power'),
    isChargeScheduledOn: b('ev_charge_scheduled_on'),
    batteryPowerWatts: d('battery_power_watts'),
    isBatteryHeatingOn: b('battery_heating_is_on'),
    efficiencyLatestTrip: d('efficiency_latest_trip'),
    efficiencySinceCharging: d('efficiency_recent_50km'),
    efficiencyOverall: d('efficiency_overall'),
    equivalentFuelConsumption: d('equivalent_fuel_consumption'),
    recent50kmEnergyKwh: d('recent_50km_energy_kwh'),
    energyHistory:
        EnergyHistory.fromJson(m('energy_history'), m('drive_distribution')),
    odometerKm: d('odometer'),
    latitude: d('location_latitude'),
    longitude: d('location_longitude'),
    tyrePressureFrontLeft: d('tire_pressure_front_left'),
    tyrePressureFrontRight: d('tire_pressure_front_right'),
    tyrePressureRearLeft: d('tire_pressure_rear_left'),
    tyrePressureRearRight: d('tire_pressure_rear_right'),
    tyrePressureWarningFrontLeft: b('tire_pressure_front_left_warning_is_on'),
    tyrePressureWarningFrontRight: b('tire_pressure_front_right_warning_is_on'),
    tyrePressureWarningRearLeft: b('tire_pressure_rear_left_warning_is_on'),
    tyrePressureWarningRearRight: b('tire_pressure_rear_right_warning_is_on'),
    tyrePressureWarningAll: b('tire_pressure_all_warning_is_on'),
    isWindowFrontLeftOpen: b('front_left_window_is_open'),
    isWindowFrontRightOpen: b('front_right_window_is_open'),
    isWindowRearLeftOpen: b('back_left_window_is_open'),
    isWindowRearRightOpen: b('back_right_window_is_open'),
    isSunroofOpen: b('sunroof_is_open'),
    isBrakingFluidWarning: b('brake_fluid_warning_is_on'),
    isAbsWarning: b('abs_warning_is_on'),
    isAirbagWarning: b('airbag_warning_is_on'),
    isStabilityWarning: b('stability_warning_is_on'),
    isSteeringWarning: b('steering_warning_is_on'),
    isServiceWarning: b('service_warning_is_on'),
    isPowerSystemWarning: b('power_system_warning_is_on'),
    isChargingSystemWarning: b('charging_system_warning_is_on'),
    isTyreLeakWarning: b('tire_leak_warning_is_on'),
    totalDrivenKm: d('total_driving_range'),
    extras: extras,
    lastUpdated: t('last_updated_at'),
    fetchedAt: t('fetchedAt'),
    registrationDate: t('registration_date'),
  );
}

/// Returns a [Vehicle] populated with demo data for UI testing.
Vehicle mockVehicle() => const Vehicle(
      id: 'demo-001',
      vin: 'LC0C74C4XR0123456',
      nickname: 'My SEALION 7',
      modelName: 'SEALION 7',
      modelYear: '',
      fuelType: 'EV',
      color: '',
      trim: 'Performance AWD',
      plate: 'DEMO01',
      isLocked: true,
      isTrunkOpen: false,
      isBonnetOpen: false,
      isDoorFrontLeftOpen: false,
      isDoorFrontRightOpen: false,
      isDoorRearLeftOpen: false,
      isDoorRearRightOpen: false,
      isEngineRunning: false,
      isParkingBrakeOn: true,
      isOnline: true,
      batteryLevelPercent: 62,
      evRangeKm: 305,
      isChargingOn: false,
      isPluggedIn: false,
      // batteryCapacityKwh / batteryRemainKwh are deliberately absent: BYD
      // does not report pack energy, and the chips that show them divide by
      // 3600 to undo Bluelink's kilojoules.
      interiorTempC: 21.5,
      targetTempC: 22,
      odometerKm: 14820,
      totalDrivenKm: 14820,
      efficiencyLatestTrip: 17.8,
      efficiencySinceCharging: 18.4,
      efficiencyOverall: 19.1,
      equivalentFuelConsumption: 2.1,
      recent50kmEnergyKwh: 9.2,
      latitude: -35.2809,
      longitude: 149.1300,
      tyrePressureFrontLeft: 240,
      tyrePressureFrontRight: 240,
      tyrePressureRearLeft: 230,
      tyrePressureRearRight: 235,
      tyrePressureWarningFrontLeft: false,
      tyrePressureWarningFrontRight: false,
      tyrePressureWarningRearLeft: false,
      tyrePressureWarningRearRight: false,
      energyHistory: EnergyHistory(
        series: [18.1, 17.4, 19.0, 16.8, 18.9, 17.2, 18.0],
        modelAverage: [19.5, 19.5, 19.5, 19.5, 19.5, 19.5, 19.5],
        distribution: DriveDistribution(
          drive: 71,
          climate: 14,
          electronics: 12,
          other: 3,
        ),
      ),
      lastUpdated: null,
    );
