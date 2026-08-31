/// Countries where BYD Connect accounts can be registered.
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

/// ISO country code to display name, in alphabetical order by name.
///
/// The country selects which BYD regional server byd_fetch.py talks to. BYD
/// shards accounts across those servers and an account exists only on the one
/// it was created on, so this is a connection setting rather than a display
/// preference — see byd_fetch.py for the code-to-server mapping.
const Map<String, String> bydCountries = {
  'AL': 'Albania',
  'AR': 'Argentina',
  'AU': 'Australia',
  'AT': 'Austria',
  'BH': 'Bahrain',
  'BD': 'Bangladesh',
  'BE': 'Belgium',
  'BT': 'Bhutan',
  'BO': 'Bolivia',
  'BA': 'Bosnia and Herzegovina',
  'BR': 'Brazil',
  'BN': 'Brunei',
  'BG': 'Bulgaria',
  'KH': 'Cambodia',
  'CL': 'Chile',
  'CO': 'Colombia',
  'CR': 'Costa Rica',
  'HR': 'Croatia',
  'CY': 'Cyprus',
  'CZ': 'Czech Republic',
  'DK': 'Denmark',
  'DO': 'Dominican Republic',
  'EC': 'Ecuador',
  'EG': 'Egypt',
  'SV': 'El Salvador',
  'EE': 'Estonia',
  'FI': 'Finland',
  'FR': 'France',
  'PF': 'French Polynesia',
  'DE': 'Germany',
  'GR': 'Greece',
  'GT': 'Guatemala',
  'HN': 'Honduras',
  'HK': 'Hong Kong',
  'HU': 'Hungary',
  'IS': 'Iceland',
  'IN': 'India',
  'ID': 'Indonesia',
  'IE': 'Ireland',
  'IL': 'Israel',
  'IT': 'Italy',
  'JP': 'Japan',
  'JO': 'Jordan',
  'KZ': 'Kazakhstan',
  'XK': 'Kosovo',
  'KW': 'Kuwait',
  'LA': 'Laos',
  'LV': 'Latvia',
  'LI': 'Liechtenstein',
  'LT': 'Lithuania',
  'LU': 'Luxembourg',
  'MO': 'Macao',
  'MY': 'Malaysia',
  'MV': 'Maldives',
  'MT': 'Malta',
  'MU': 'Mauritius',
  'MX': 'Mexico',
  'MD': 'Moldova',
  'MC': 'Monaco',
  'MN': 'Mongolia',
  'ME': 'Montenegro',
  'MA': 'Morocco',
  'MM': 'Myanmar',
  'NP': 'Nepal',
  'NL': 'Netherlands',
  'NC': 'New Caledonia',
  'NZ': 'New Zealand',
  'NI': 'Nicaragua',
  'MK': 'North Macedonia',
  'NO': 'Norway',
  'OM': 'Oman',
  'PK': 'Pakistan',
  'PA': 'Panama',
  'PY': 'Paraguay',
  'PE': 'Peru',
  'PH': 'Philippines',
  'PL': 'Poland',
  'PT': 'Portugal',
  'QA': 'Qatar',
  'RE': 'Reunion Island',
  'RO': 'Romania',
  'SA': 'Saudi Arabia',
  'RS': 'Serbia',
  'SG': 'Singapore',
  'SK': 'Slovakia',
  'SI': 'Slovenia',
  'ZA': 'South Africa',
  'KR': 'South Korea',
  'ES': 'Spain',
  'LK': 'Sri Lanka',
  'SE': 'Sweden',
  'CH': 'Switzerland',
  'TH': 'Thailand',
  'TR': 'Turkey',
  'UA': 'Ukraine',
  'AE': 'United Arab Emirates',
  'GB': 'United Kingdom',
  'UY': 'Uruguay',
  'UZ': 'Uzbekistan',
  'VA': 'Vatican City',
  'VN': 'Vietnam',
};
