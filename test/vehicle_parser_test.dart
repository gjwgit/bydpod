/// Tests for parsing byd_fetch.py output into a Vehicle.
///
/// The fixture below is real output from byd_fetch.py's build_vehicle(), so
/// these tests pin the contract between the Python helper and the Dart model.
/// They need no Pod and no BYD account.
///
// Time-stamp: <Sunday 2026-08-30 00:00:00 +1000 Graham Williams>
///
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3

library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:bydpod/models/vehicle.dart';

/// A snapshot as byd_fetch.py emits it for a charging Sealion 7.
const _fixture = '''
{
  "vehicleId": "LC0C74C4XR0123456",
  "vin": "LC0C74C4XR0123456",
  "name": "Sealion",
  "model": "SEALION 7",
  "brand": "BYD",
  "trim": "Performance AWD",
  "plate": "ABC12D",
  "engine_type": "EV",
  "is_locked": true,
  "trunk_is_open": true,
  "hood_is_open": false,
  "front_left_door_is_open": false,
  "engine_is_running": false,
  "parking_brake_is_on": true,
  "speed": 0.0,
  "is_online": true,
  "set_temperature": 22.0,
  "interior_temperature": 21.5,
  "steering_wheel_heater_is_on": true,
  "front_left_seat_status": 2,
  "front_right_seat_status": 0,
  "ev_battery_percentage": 62.0,
  "ev_driving_range": 305.0,
  "ev_battery_is_charging": true,
  "ev_battery_is_plugged_in": true,
  "ev_estimated_current_charge_duration": 85,
  "ev_charging_power": 6.9,
  "battery_power_watts": -2400.0,
  "odometer": 14820.5,
  "location_latitude": -35.2809,
  "location_longitude": 149.13,
  "tire_pressure_front_left": 240.0,
  "tire_pressure_rear_left": 230.0,
  "tire_pressure_rear_right_warning_is_on": true,
  "tire_pressure_front_left_warning_is_on": false,
  "front_left_window_is_open": false,
  "front_right_window_is_open": true,
  "sunroof_is_open": false,
  "brake_fluid_warning_is_on": false,
  "abs_warning_is_on": false,
  "efficiency_latest_trip": 17.8,
  "efficiency_recent_50km": 18.4,
  "efficiency_overall": 19.1,
  "equivalent_fuel_consumption": 2.1,
  "recent_50km_energy_kwh": 9.2,
  "total_driving_range": 14820.5,
  "energy_history": {
    "series": [18.1, 17.4, 19.0, 16.8, 18.9, 17.2, 18.0],
    "series_unit": "kWh/100km",
    "model_average": [19.5, 19.5, 19.5, 19.5, 19.5, 19.5, 19.5]
  },
  "drive_distribution": {
    "drive": 71, "electronics": 12, "climate": 14, "other": 3
  },
  "last_updated_at": "2026-08-30T06:40:00+10:00",
  "vehicle_time_zone": "Australia/Sydney",
  "tbox_version": "3"
}
''';

Vehicle _parse([Map<String, dynamic>? overrides]) {
  final j = jsonDecode(_fixture) as Map<String, dynamic>;
  if (overrides != null) j.addAll(overrides);
  return Vehicle.fromApiJson(j);
}

void main() {
  group('identity', () {
    test('maps names, trim and plate', () {
      final v = _parse();
      expect(v.vin, 'LC0C74C4XR0123456');
      expect(v.id, 'LC0C74C4XR0123456');
      expect(v.nickname, 'Sealion');
      expect(v.modelName, 'SEALION 7');
      expect(v.trim, 'Performance AWD');
      expect(v.plate, 'ABC12D');
    });

    test('treats the car as an EV and never as an ICE', () {
      final v = _parse();
      expect(v.fuelType, 'EV');
      expect(v.isEV, isTrue);
      expect(v.isICE, isFalse);
    });

    test('a DM-i reports as PHEV so both battery and fuel sections show', () {
      final v = _parse({'engine_type': 'PHEV'});
      expect(v.isEV, isTrue);
      expect(v.isICE, isTrue);
    });

    test('an unrecognised powertrain falls back to EV', () {
      expect(_parse({'engine_type': 'SOMETHING_NEW'}).fuelType, 'EV');
    });

    test('a nameless vehicle still gets a label', () {
      final j = jsonDecode(_fixture) as Map<String, dynamic>..remove('name');
      expect(Vehicle.fromApiJson(j).nickname, 'My BYD');
    });
  });

  group('state', () {
    test('booleans survive round-tripping, including false', () {
      final v = _parse();
      expect(v.isLocked, isTrue);
      expect(v.isTrunkOpen, isTrue);
      // A reported false must stay false rather than collapsing to null:
      // "bonnet closed" and "bonnet unknown" are different things.
      expect(v.isBonnetOpen, isFalse);
      expect(v.isWindowFrontLeftOpen, isFalse);
      expect(v.isWindowFrontRightOpen, isTrue);
      expect(v.isSunroofOpen, isFalse);
      expect(v.isParkingBrakeOn, isTrue);
      expect(v.isOnline, isTrue);
    });

    test('absent keys stay null rather than defaulting to false', () {
      final v = _parse();
      // byd_fetch.py omits anything the car did not report.
      expect(v.isDoorRearLeftOpen, isNull);
      expect(v.isAirbagWarning, isNull);
      expect(v.fuelLevelPercent, isNull);
    });

    test('battery and charging figures map across', () {
      final v = _parse();
      expect(v.batteryLevelPercent, 62.0);
      expect(v.evRangeKm, 305.0);
      expect(v.isChargingOn, isTrue);
      expect(v.isPluggedIn, isTrue);
      expect(v.estimatedChargeCompletionMinutes, 85.0);
      expect(v.chargingPowerKw, 6.9);
      expect(v.batteryPowerWatts, -2400.0);
    });

    test('tyre pressures arrive in kPa with per-corner warnings', () {
      final v = _parse();
      expect(v.tyrePressureFrontLeft, 240.0);
      expect(v.tyrePressureRearLeft, 230.0);
      expect(v.tyrePressureWarningRearRight, isTrue);
      expect(v.tyrePressureWarningFrontLeft, isFalse);
    });

    test('cabin temperature is interior, not outside air', () {
      final v = _parse();
      expect(v.interiorTempC, 21.5);
      expect(v.targetTempC, 22.0);
      // BYD reports no outside air temperature at all.
      expect(v.externalTempC, isNull);
    });
  });

  group('efficiency', () {
    test('maps the three horizons BYD reports', () {
      final v = _parse();
      expect(v.efficiencyLatestTrip, 17.8);
      expect(v.efficiencySinceCharging, 18.4);
      expect(v.efficiencyOverall, 19.1);
      expect(v.equivalentFuelConsumption, 2.1);
      expect(v.recent50kmEnergyKwh, 9.2);
      expect(v.totalDrivenKm, 14820.5);
    });
  });

  group('energy history', () {
    test('parses the series, baseline and split', () {
      final h = _parse().energyHistory!;
      expect(h.series, hasLength(7));
      expect(h.unit, 'kWh/100km');
      expect(h.best, 16.8);
      expect(h.worst, 19.0);
      expect(h.average, closeTo(17.9, 0.05));
      expect(h.modelAverageMean, 19.5);
      expect(h.distribution!.drive, 71);
    });

    test('shares are ordered largest first', () {
      final shares = _parse().energyHistory!.distribution!.shares;
      expect(
        shares.map((e) => e.key).toList(),
        ['Drive motor', 'Climate', 'Electronics', 'Other'],
      );
    });

    test('is null when the API supplied neither block', () {
      final j = jsonDecode(_fixture) as Map<String, dynamic>
        ..remove('energy_history')
        ..remove('drive_distribution');
      expect(Vehicle.fromApiJson(j).energyHistory, isNull);
    });

    test('survives a distribution with no series', () {
      final j = jsonDecode(_fixture) as Map<String, dynamic>
        ..remove('energy_history');
      final h = Vehicle.fromApiJson(j).energyHistory!;
      expect(h.hasSeries, isFalse);
      expect(h.average, isNull);
      expect(h.distribution!.climate, 14);
    });
  });

  group('extras', () {
    test('carries unrecognised scalars through for the raw view', () {
      final v = _parse({'some_new_byd_field': 42});
      expect(v.extras['some_new_byd_field'], 42);
      expect(v.extras['vehicle_time_zone'], 'Australia/Sydney');
    });

    test('never carries nested blocks, which would render unreadably', () {
      final v = _parse();
      expect(v.extras.containsKey('energy_history'), isFalse);
      expect(v.extras.values.any((e) => e is Map || e is List), isFalse);
    });

    test('omits named fields that already have a home on the model', () {
      final v = _parse();
      for (final key in ['vin', 'odometer', 'ev_battery_percentage']) {
        expect(v.extras.containsKey(key), isFalse, reason: key);
      }
    });
  });

  group('timestamps', () {
    test('parses the reading time to local', () {
      final v = _parse();
      expect(v.lastUpdated, isNotNull);
      expect(v.lastUpdated!.isUtc, isFalse);
    });

    test('an unparseable timestamp is dropped, not thrown', () {
      expect(_parse({'last_updated_at': 'not a date'}).lastUpdated, isNull);
    });
  });

  group('demo data', () {
    test('mock vehicle renders without the fields BYD cannot supply', () {
      final v = Vehicle.mock();
      expect(v.fuelType, 'EV');
      expect(v.energyHistory!.series, hasLength(7));
      // These chips divide by 3600 to undo Bluelink's kilojoules, so a value
      // here would render as a nonsense fraction of a kWh.
      expect(v.batteryCapacityKwh, isNull);
      expect(v.batteryRemainKwh, isNull);
    });
  });
}
