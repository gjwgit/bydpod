#!/usr/bin/env python3
"""
BYD Connect data fetcher — backend for the Flutter app (BYD Sealion 7).

Usage:  python3 byd_fetch.py <username> <password> [<pin>] [--country AU]
                             [--debug]

The PIN is the 6-digit remote-control PIN set in the BYD app. This app only
reads vehicle state, so the PIN is optional — pass an empty string to omit it.

Requires: pip install pybyd
"""

import asyncio
import json
import sys
import traceback
from datetime import datetime

# BYD regional API node -> (base URL, country codes it serves).
_NODES = {
    'au': ('https://dilinkappoversea-au.byd.auto', 'AU NZ'),
    'br': ('https://dilinkappoversea-br.byd.auto', 'BR'),
    'eu': (
        'https://dilinkappoversea-eu.byd.auto',
        'AL AT BA BE BG CH CY CZ DE DK EE ES FI FR GB GR HR HU ',
        'IE IL IS IT LI LT LU LV MC MD ME MK MT NL NO PL PT RO ',
        'RS SE SI SK UA VA XK',
    ),
    'id': ('https://dilinkappoversea-id.byd.auto', 'ID'),
    'in': ('https://dilinkappoversea-in.byd.auto', 'IN'),
    'jp': ('https://dilinkappoversea-jp.byd.auto', 'JP'),
    'kr': ('https://dilinkappoversea-kr.byd.auto', 'KR'),
    'kz': ('https://dilinkappoversea-kz.byd.auto', 'KZ'),
    'mx': (
        'https://dilinkappoversea-mx.byd.auto',
        'AR BO CL CO CR DO EC GT HN MX NI PA PE PY SV UY',
    ),
    'no': (
        'https://dilinkappoversea-no.byd.auto',
        'AE BH EG JO KW MA MU QA RE ZA',
    ),
    'om': ('https://dilinkappoversea-om.byd.auto', 'OM'),
    'sa': ('https://dilinkappoversea-sa.byd.auto', 'SA'),
    'sg': (
        'https://dilinkappoversea-sg.byd.auto',
        'BD BN BT HK KH LA LK MM MN MO MV MY NC NP PF PH PK SG TH',
    ),
    'tr': ('https://dilinkappoversea-tr.byd.auto', 'TR'),
    'uz': ('https://dilinkappoversea-uz.byd.auto', 'UZ'),
    'vn': ('https://dilinkappoversea-vn.byd.auto', 'VN'),
}

# Non-English app languages by country; everything else defaults to en.
_LANGS = {
    'AE': 'ar', 'AR': 'es', 'AT': 'de', 'BH': 'ar', 'BO': 'es', 'BR':
    'pt', 'CH': 'de', 'CL': 'es', 'CO': 'es', 'CR': 'es', 'DE': 'de',
    'DO': 'es', 'EC': 'es', 'EG': 'ar', 'ES': 'es', 'FR': 'fr', 'GT':
    'es', 'HK': 'zh_TW', 'HN': 'es', 'ID': 'id', 'IL': 'he', 'IT': 'it',
    'JO': 'ar', 'JP': 'ja', 'KR': 'ko', 'KW': 'ar', 'KZ': 'ru', 'LI':
    'de', 'LU': 'fr', 'MA': 'ar', 'MC': 'fr', 'MD': 'ru', 'MO': 'zh_TW',
    'MX': 'es', 'NC': 'fr', 'NI': 'es', 'NL': 'nl', 'OM': 'ar', 'PA':
    'es', 'PE': 'es', 'PF': 'fr', 'PT': 'pt', 'PY': 'es', 'QA': 'ar',
    'RE': 'fr', 'SA': 'ar', 'SV': 'es', 'TH': 'th', 'TR': 'tr', 'UA':
    'ru', 'UY': 'es', 'UZ': 'ru', 'VA': 'it', 'VN': 'vi',
}

# The BYD cloud is sharded by region and an account only exists on the shard
# it was created on, so the wrong base URL fails authentication rather than
# returning an empty vehicle list.
DEFAULT_COUNTRY = 'AU'


def resolve_region(code):
    """Return (country_code, language, base_url) for an ISO country code."""
    code = (code or DEFAULT_COUNTRY).strip().upper()
    for _node, entry in _NODES.items():
        url, served = entry[0], ' '.join(entry[1:])
        if code in served.split():
            return code, _LANGS.get(code, 'en'), url
    raise ValueError(
        f'Unknown country code {code!r}. BYD Connect is not available there, '
        f'or the code is mistyped (use a two-letter ISO code such as AU).'
    )


def safe(val):
    """Recursively convert any value to a JSON-serialisable primitive.

    Datetimes are converted to local time before stringifying so that daily
    figures are attributed to the correct local calendar date. Enums from
    pybyd are IntEnums, so they are decoded to their names by the callers
    that care and fall through to int here otherwise."""
    if val is None or isinstance(val, (bool, int, float, str)):
        return val
    if isinstance(val, datetime):
        # BYD timestamps are parsed to UTC by pybyd; show local time.
        return (val.astimezone() if val.tzinfo else val).isoformat()
    if isinstance(val, (list, tuple)):
        return [safe(i) for i in val]
    if isinstance(val, dict):
        return {str(k): safe(v) for k, v in val.items()}
    return str(val)


def num(val):
    """Coerce to float, returning None for anything unparseable."""
    if val is None or isinstance(val, bool):
        return None
    try:
        return float(val)
    except (TypeError, ValueError):
        return None


# Tyre pressure arrives in whichever unit the car is configured for; the app
# displays kPa throughout, matching what the BYD dash shows in Australia.
_TO_KPA = {1: 100.0, 2: 6.894757, 3: 1.0}


def kpa(value, unit):
    """Convert a tyre pressure reading to kPa given its TirePressureUnit."""
    v = num(value)
    if v is None or v <= 0:
        return None
    return round(v * _TO_KPA.get(int(unit) if unit is not None else 3, 1.0), 1)


def flag(value):
    """Map a BYD 0=normal / >0=warning indicator to a bool."""
    if value is None:
        return None
    return int(value) > 0


def seat_level(state):
    """Map a SeatHeatVentState to the 0-3 level the app's seat tiles expect.

    NO_DATA (0) and UNKNOWN (-1) both mean "nothing reported" rather than
    "off", so they become None and the tile is hidden."""
    if state is None or int(state) <= 0:
        return None
    return int(state) - 1  # OFF=1 -> 0, LOW=2 -> 1, HIGH=3 -> 2


def build_vehicle(meta, rt, gps, energy):
    """Flatten the four BYD endpoints into one JSON record for the app.

    Field names are the app's own neutral vocabulary (see
    lib/models/vehicle_parser.dart), not BYD's — the Dart side never sees
    BYD's camelCase keys or its sentinel encodings."""
    from pybyd.models.realtime import DoorOpenState, WindowState
    from pybyd.models.vehicle import EnergyType

    def door(state):
        return None if state is None else state == DoorOpenState.OPEN

    def window(state):
        return None if state is None else state == WindowState.OPEN

    energy_type = {
        EnergyType.EV: 'EV',
        EnergyType.ICE: 'ICE',
        # A BYD DM-i is a plug-in hybrid: the app shows both the battery and
        # the fuel sections for PHEV, which is what these cars report.
        EnergyType.HYBRID: 'PHEV',
    }.get(meta.energy_type, 'EV')

    unit = rt.tire_press_unit
    cum = energy.cumulative_energy_consumption if energy else None
    near = energy.nearest_energy_consumption if energy else None

    d = {
        # ── Identity ──────────────────────────────────────────────────────
        'vehicleId': meta.vin,
        'vin': meta.vin,
        'name': meta.auto_alias or meta.model_name or 'My BYD',
        'model': meta.model_name,
        'brand': meta.brand_name,
        'trim': meta.out_model_type,
        'plate': meta.auto_plate,
        'engine_type': energy_type,

        # ── Lock / doors ──────────────────────────────────────────────────
        'is_locked': rt.is_locked,
        'trunk_is_open': door(rt.trunk_lid),
        'hood_is_open': door(rt.forehold),
        'front_left_door_is_open': door(rt.left_front_door),
        'front_right_door_is_open': door(rt.right_front_door),
        'back_left_door_is_open': door(rt.left_rear_door),
        'back_right_door_is_open': door(rt.right_rear_door),

        # ── Power / drive ─────────────────────────────────────────────────
        'engine_is_running': rt.is_vehicle_on,
        'speed': num(rt.speed),
        'parking_brake_is_on': flag(rt.epb),

        # ── Climate ───────────────────────────────────────────────────────
        'set_temperature': num(rt.main_setting_temp_new),
        'interior_temperature': num(rt.temp_in_car),
        'steering_wheel_heater_is_on': rt.is_steering_wheel_heating,
        'front_left_seat_status': seat_level(rt.main_seat_heat_state),
        'front_right_seat_status': seat_level(rt.copilot_seat_heat_state),
        'rear_left_seat_status': seat_level(rt.lr_seat_heat_state),
        'rear_right_seat_status': seat_level(rt.rr_seat_heat_state),
        'front_left_seat_cool_status':
            seat_level(rt.main_seat_ventilation_state),
        'front_right_seat_cool_status':
            seat_level(rt.copilot_seat_ventilation_state),

        # ── EV / battery ──────────────────────────────────────────────────
        'ev_battery_percentage': num(rt.elec_percent),
        'ev_driving_range': num(rt.endurance_mileage),
        'ev_battery_is_charging': rt.is_charging,
        'ev_battery_is_plugged_in': rt.is_charger_connected,
        'ev_estimated_current_charge_duration': rt.time_to_full_minutes,
        'ev_charging_power': num(rt.rate),
        'ev_charge_scheduled_on': flag(rt.booking_charge_state),
        'battery_power_watts': num(rt.gl),
        'battery_heating_is_on': rt.is_battery_heating,

        # ── Fuel (DM-i / hybrid only) ─────────────────────────────────────
        'fuel_level': num(rt.oil_percent),
        'fuel_driving_range': num(rt.oil_endurance),

        # ── Odometer / location ───────────────────────────────────────────
        'odometer': num(rt.total_mileage) or num(meta.total_mileage),
        'location_latitude': num(gps.latitude) if gps else None,
        'location_longitude': num(gps.longitude) if gps else None,

        # ── Tyres ─────────────────────────────────────────────────────────
        'tire_pressure_front_left': kpa(rt.left_front_tire_pressure, unit),
        'tire_pressure_front_right': kpa(rt.right_front_tire_pressure, unit),
        'tire_pressure_rear_left': kpa(rt.left_rear_tire_pressure, unit),
        'tire_pressure_rear_right': kpa(rt.right_rear_tire_pressure, unit),
        'tire_pressure_front_left_warning_is_on':
            flag(rt.left_front_tire_status),
        'tire_pressure_front_right_warning_is_on':
            flag(rt.right_front_tire_status),
        'tire_pressure_rear_left_warning_is_on':
            flag(rt.left_rear_tire_status),
        'tire_pressure_rear_right_warning_is_on':
            flag(rt.right_rear_tire_status),
        'tire_pressure_all_warning_is_on': flag(rt.tirepressure_system),

        # ── Windows ───────────────────────────────────────────────────────
        'front_left_window_is_open': window(rt.left_front_window),
        'front_right_window_is_open': window(rt.right_front_window),
        'back_left_window_is_open': window(rt.left_rear_window),
        'back_right_window_is_open': window(rt.right_rear_window),
        'sunroof_is_open': window(rt.skylight),

        # ── Warnings ──────────────────────────────────────────────────────
        'brake_fluid_warning_is_on': flag(rt.braking_system),
        'abs_warning_is_on': flag(rt.abs_warning),
        'airbag_warning_is_on': flag(rt.srs),
        'stability_warning_is_on': flag(rt.esp),
        'steering_warning_is_on': flag(rt.eps),
        'service_warning_is_on': flag(rt.svs),
        'power_system_warning_is_on': flag(rt.power_system),
        'charging_system_warning_is_on': flag(rt.charging_system),
        'tire_leak_warning_is_on': flag(rt.rapid_tire_leak),

        # ── Efficiency (kWh/100km) ────────────────────────────────────────
        # Three horizons, mirroring what the BYD app shows on its energy
        # page: the last 50 km, the current trip, and lifetime.
        'efficiency_latest_trip': num(rt.energy_consumption_ev),
        'efficiency_recent_50km':
            num(near.avg_ev_consumption if near else None)
            or num(rt.recent_50km_energy_ev),
        'efficiency_overall':
            num(cum.avg_ev_consumption if cum else None)
            or num(rt.total_consumption_en_ev),
        'equivalent_fuel_consumption':
            num(near.avg_eq_oil_consumption if near else None),

        # ── Totals ────────────────────────────────────────────────────────
        'total_driving_range': num(cum.total_mileage if cum else None),
        'recent_50km_energy_kwh': num(near.ev_consumption if near else None),

        # ── Timestamps ────────────────────────────────────────────────────
        'last_updated_at': safe(rt.timestamp),
        'registration_date': safe(meta.auto_bought_time),
        'vehicle_time_zone': rt.vehicle_time_zone,
        'gps_timestamp': safe(gps.gps_timestamp) if gps else None,

        # ── Connectivity ──────────────────────────────────────────────────
        'is_online': rt.is_online,
        'tbox_version': meta.tbox_version,
    }

    # The seven-day consumption series and the drive-mode split have no
    # Bluelink equivalent, so they live in their own block rather than being
    # forced into the flat namespace above.
    if energy is not None:
        d['energy_history'] = {
            'series': list((energy.self_graph.energy_consumption
                            if energy.self_graph else []) or []),
            'series_unit': (energy.self_graph.energy_consumption_unit
                            if energy.self_graph else ''),
            'model_average': list((energy.auto_model_graph.energy_consumption
                                   if energy.auto_model_graph else []) or []),
        }
        if near is not None:
            d['drive_distribution'] = {
                'drive': near.drive_distribution,
                'electronics': near.elect_distribution,
                'climate': near.air_distribution,
                'other': near.other_distribution,
            }

    return {k: v for k, v in d.items() if v is not None}


async def fetch(username, password, pin, country):
    """Log in and return one flattened record per vehicle on the account."""
    from pybyd import BydClient, BydConfig

    code, language, base_url = resolve_region(country)
    config = BydConfig(
        username=username,
        password=password,
        base_url=base_url,
        country_code=code,
        language=language,
        control_pin=pin or None,
    )

    vehicles = []
    async with BydClient(config) as client:
        await client.login()
        for meta in await client.get_vehicles():
            vin = meta.vin
            realtime = await client.get_vehicle_realtime(vin)
            # GPS and energy are secondary: a car that is asleep or parked
            # underground still has useful realtime state, so a failure here
            # must not lose the whole snapshot.
            gps = energy = None
            try:
                gps = await client.get_gps_info(vin)
            except Exception:
                pass
            try:
                energy = await client.get_energy_consumption(vin)
            except Exception:
                pass
            vehicles.append(build_vehicle(meta, realtime, gps, energy))
    return vehicles


def parse_args(argv):
    """Split argv into (positionals, country, debug).

    Accepts both ``--country AU`` and ``--country=AU`` so the flag reads
    naturally on the command line without the value being mistaken for a
    positional PIN."""
    positional, country, debug = [], DEFAULT_COUNTRY, False
    i = 0
    while i < len(argv):
        arg = argv[i]
        if arg == '--debug':
            debug = True
        elif arg.startswith('--country='):
            country = arg.split('=', 1)[1]
        elif arg == '--country' and i + 1 < len(argv):
            i += 1
            country = argv[i]
        elif not arg.startswith('--'):
            positional.append(arg)
        i += 1
    return positional, country, debug


def main():
    args, country, debug = parse_args(sys.argv[1:])

    if len(args) < 2:
        print(json.dumps({
            'error': 'Usage: byd_fetch.py <username> <password> [<pin>] '
                     '[--country AU]',
        }))
        sys.exit(1)

    username, password = args[0], args[1]
    pin = args[2] if len(args) > 2 else ''

    try:
        import pybyd  # noqa: F401
    except ImportError:
        print(json.dumps({
            'error': 'pybyd not installed',
            'fix': 'Run: pip install pybyd',
        }))
        sys.exit(1)

    try:
        vehicles = asyncio.run(fetch(username, password, pin, country))

        if debug:
            # Pretty-print every field for debugging.
            for vd in vehicles:
                print(f"\n=== {vd.get('name', vd.get('vin'))} ===")
                for k, val in sorted(vd.items()):
                    print(f'  {k}: {val!r}')
        else:
            print(json.dumps({'vehicles': vehicles}))

    except Exception as e:
        print(json.dumps({
            'error': str(e) or e.__class__.__name__,
            'traceback': traceback.format_exc(),
        }))
        sys.exit(1)


if __name__ == '__main__':
    main()
