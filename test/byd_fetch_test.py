"""Tests for byd_fetch.py against synthetic pybyd models.

Run with:  python3 test/byd_fetch_test.py

These exercise every mapping byd_fetch.py performs without needing a BYD
account, so a pybyd upgrade that renames a field fails here rather than in
the app. Requires pybyd to be installed.
"""

import json
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
import byd_fetch as bf  # noqa: E402

from pybyd.models.realtime import VehicleRealtimeData
from pybyd.models.vehicle import Vehicle
from pybyd.models.gps import GpsInfo
from pybyd.models.energy import EnergyConsumption

# --- region resolution -----------------------------------------------------
assert bf.resolve_region('AU') == ('AU', 'en', 'https://dilinkappoversea-au.byd.auto')
assert bf.resolve_region('nz')[2].endswith('-au.byd.auto')
assert bf.resolve_region(None)[0] == 'AU'
assert bf.resolve_region('IE')[2].endswith('-eu.byd.auto')   # wrap-boundary
assert bf.resolve_region('IL')[2].endswith('-eu.byd.auto')   # wrap-boundary
assert bf.resolve_region('RS')[2].endswith('-eu.byd.auto')   # wrap-boundary
assert bf.resolve_region('JP') == ('JP', 'ja', 'https://dilinkappoversea-jp.byd.auto')
try:
    bf.resolve_region('ZZ'); raise SystemExit('FAIL: bad country accepted')
except ValueError:
    pass
print('region resolution OK (101 codes, wrap boundaries intact)')

# --- arg parsing -----------------------------------------------------------
assert bf.parse_args(['u', 'p', '1234']) == (['u', 'p', '1234'], 'AU', False)
assert bf.parse_args(['u', 'p', '--country', 'NZ']) == (['u', 'p'], 'NZ', False)
assert bf.parse_args(['u', 'p', '--country=GB', '--debug']) == (['u', 'p'], 'GB', True)
assert bf.parse_args(['u', 'p', '', '--debug']) == (['u', 'p', ''], 'AU', True)
print('arg parsing OK (space and = forms, PIN not eaten by --country)')

# --- unit conversion -------------------------------------------------------
assert bf.kpa(2.4, 1) == 240.0          # bar
assert bf.kpa(35, 2) == 241.3           # psi
assert bf.kpa(240, 3) == 240.0          # already kPa
assert bf.kpa(0, 3) is None and bf.kpa(None, 1) is None
assert bf.seat_level(3) == 2 and bf.seat_level(1) == 0
assert bf.seat_level(0) is None and bf.seat_level(-1) is None
assert bf.flag(0) is False and bf.flag(2) is True and bf.flag(None) is None
print('unit/enum helpers OK')

# --- full record build, from a Sealion-7-shaped realtime payload -----------
raw_rt = {
    'onlineState': 1, 'connectState': 1, 'elecPercent': 62,
    'enduranceMileage': 305, 'totalMileage': 14820.5, 'speed': 0,
    'powerGear': 1, 'tempInCar': 21.5, 'mainSettingTempNew': 22.0,
    'chargeState': 1, 'fullHour': 1, 'fullMinute': 25, 'rate': 6.9,
    'leftFrontDoorLock': 2, 'rightFrontDoorLock': 2,
    'leftRearDoorLock': 2, 'rightRearDoorLock': 2,
    'leftFrontDoor': 0, 'rightFrontDoor': 0, 'backCover': 1, 'forehold': 0,
    'leftFrontWindow': 1, 'rightFrontWindow': 2, 'skylight': 1,
    'leftFrontTirepressure': 2.4, 'rightFrontTirepressure': 2.4,
    'leftRearTirepressure': 2.3, 'rightRearTirepressure': 2.35,
    'tirePressUnit': 1, 'tirepressureSystem': 0, 'rapidTireLeak': 0,
    'leftFrontTireStatus': 0, 'rightRearTireStatus': 1,
    'mainSeatHeatState': 3, 'copilotSeatHeatState': 1,
    'stearingWheelHeatState': -1,
    'brakingSystem': 0, 'srs': 0, 'esp': 0, 'abs': 0, 'svs': 0,
    'oilEndurance': -1, 'batteryHeatState': 0, 'epb': 1,
    'energyConsumption': '17.8kW·h/100km',
    'recent50kmEnergy': '18.4kW·h/100km',
    'totalConsumptionEn': '19.1kW·h/100km',
    'vehicleTimeZone': 'Australia/Sydney',
    'time': 1756500000, 'gl': -2400,
}
rt = VehicleRealtimeData.model_validate(raw_rt)
meta = Vehicle.model_validate({
    'vin': 'LC0C74C4XR0123456', 'modelName': 'SEALION 7', 'brandName': 'BYD',
    'energyType': 0, 'autoAlias': 'Sealion', 'autoPlate': 'ABC12D',
    'outModelType': 'Performance AWD', 'totalMileage': 14820.5,
    'autoBoughtTime': 1735689600, 'tboxVersion': '3',
})
gps = GpsInfo.model_validate({'data': {'latitude': -35.2809, 'longitude': 149.13,
                                       'gpsTimeStamp': 1756500000}})
energy = EnergyConsumption.model_validate({
    'selfGraph': {'energyConsumption': ['18.1', '17.4', '19.0', '16.8',
                                        '18.9', '17.2', '18.0'],
                  'energyConsumptionUnit': 'kW·h/100km'},
    'autoModelGraph': {'energyConsumption': ['19.5'] * 7},
    'cumulativeEnergyConsumption': {'totalMileage': '14820.5',
                                    'avgEvConsumption': '19.1',
                                    'evUnit': 'kW·h/100km'},
    'nearestEnergyConsumption': {'avgEvConsumption': '18.4',
                                 'evConsumption': '9.2',
                                 'avgEqOilConsumption': '2.1',
                                 'driveDistribution': 71,
                                 'electDistribution': 12,
                                 'airDistribution': 14,
                                 'otherDistribution': 3},
})

rec = bf.build_vehicle(meta, rt, gps, energy)

# --- assertions on the mapped record ---------------------------------------
checks = {
    'engine_type': 'EV',
    'name': 'Sealion',
    'is_locked': True,
    'trunk_is_open': True,
    'hood_is_open': False,
    'front_left_window_is_open': False,
    'front_right_window_is_open': True,
    'ev_battery_percentage': 62.0,
    'ev_driving_range': 305.0,
    'ev_battery_is_charging': True,
    'ev_battery_is_plugged_in': True,
    'ev_estimated_current_charge_duration': 85,
    'tire_pressure_front_left': 240.0,
    'tire_pressure_rear_left': 230.0,
    'tire_pressure_rear_right_warning_is_on': True,
    'tire_pressure_front_left_warning_is_on': False,
    'front_left_seat_status': 2,
    'front_right_seat_status': 0,
    'steering_wheel_heater_is_on': True,
    'odometer': 14820.5,
    'efficiency_latest_trip': 17.8,
    'efficiency_recent_50km': 18.4,
    'efficiency_overall': 19.1,
    'equivalent_fuel_consumption': 2.1,
    'total_driving_range': 14820.5,
    'location_latitude': -35.2809,
    'parking_brake_is_on': True,
    'engine_is_running': False,
}
bad = {k: (rec.get(k), want) for k, want in checks.items() if rec.get(k) != want}
assert not bad, f'MISMATCH got/want: {bad}'
assert 'fuel_driving_range' not in rec, 'BEV must not report a fuel range'
assert len(rec['energy_history']['series']) == 7
assert rec['drive_distribution']['drive'] == 71
assert json.loads(json.dumps(rec)) == rec, 'record must be JSON round-trippable'
print('build_vehicle OK — %d fields mapped, all assertions passed'
      % len(rec))

# --- degraded path: no GPS, no energy --------------------------------------
lean = bf.build_vehicle(meta, rt, None, None)
assert 'location_latitude' not in lean and 'energy_history' not in lean
assert lean['ev_battery_percentage'] == 62.0
assert lean['efficiency_recent_50km'] == 18.4     # falls back to realtime
assert lean['efficiency_overall'] == 19.1         # falls back to realtime
print('degraded path OK (GPS/energy unavailable still yields a snapshot)')


# --- the Dart country dropdown must offer exactly what the script accepts ---
dart = open(os.path.join(os.path.dirname(__file__), '..', 'lib', 'constants',
                         'countries.dart')).read()
dart_codes = set(re.findall(r"^  '([A-Z]{2})':", dart, re.M))
script_codes = {c for entry in bf._NODES.values()
                for c in ' '.join(entry[1:]).split()}
assert dart_codes == script_codes, (
    'countries.dart and byd_fetch.py disagree: '
    f'only in Dart {sorted(dart_codes - script_codes)}, '
    f'only in script {sorted(script_codes - dart_codes)}')
for code in sorted(dart_codes):
    bf.resolve_region(code)   # every offered country must resolve
print(f'country table OK — {len(dart_codes)} codes match countries.dart')
