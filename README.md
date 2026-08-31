# BYD Pod - A BYD Sealion 7 Vehicle Monitor

> Vehicle Monitoring with Secure and Private Solid Pod Storage

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![Github Docs](https://img.shields.io/badge/GitHub-Pages-green?logo=gitbook)](https://gjwgit.github.io/bydpod)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-blue?logo=github)](https://github.com/gjwgit/bydpod)
[![GitHub License](https://img.shields.io/github/license/gjwgit/bydpod)](https://raw.githubusercontent.com/gjwgit/bydpod/dev/LICENSE)
[![Github Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/gjwgit/bydpod/master/pubspec.yaml&query=$.version&label=version)](https://github.com/gjwgit/bydpod/blob/dev/CHANGELOG.md)
[![Github Last Updated](https://img.shields.io/github/last-commit/gjwgit/bydpod?label=last%20updated)](https://github.com/gjwgit/bydpod/commits/dev/)
[![GitHub Commit Activity (dev)](https://img.shields.io/github/commit-activity/w/gjwgit/bydpod/dev)](https://github.com/gjwgit/rattle/commits/dev/)
[![GitHub Issues](https://img.shields.io/github/issues/gjwgit/bydpod)](https://github.com/gjwgit/bydpod/issues)

[BydPod](https://gjwgit.github.io/bydpod/) monitors your BYD Sealion 7:
live vehicle status from the BYD API, a logbook for recording charges and
drives, battery history charts, and driving efficiency statistics. All data is
stored encrypted in your own personal Data Vault on a Solid server in the
cloud, where everything stays within the Pod under your control. The app is
supported by [Togaware](https://togaware.com) and implemented by [Graham
Williams](https://togaware.com/Graham.Williams.html) pair coding with
[Claude Code](https://claude.com/product/claude-code) using
[Flutter](https://flutter.dev)'s [SolidUI](https://github.com/anusii/solidui)
package for cross platform development.

Solid Pods are a new approach to handling your personal data on the World Wide
Web and is the latest innovation from the inventor of the WWW, Sir Tim
Berners-Lee. Obtain a Pod for yourself on any Solid server and link it to your
app.

We make this project available for free so if you appreciate the app then
please show some ❤️ and tap on the star at
[GitHub](https://github.com/gjwgit/bydpod) to support our work. See the [AU
Solid Community](https://solidcommunity.au) **showcase** for many more apps
using the Solid ecosystem.

The latest version of the app can be run online at
[bydpod.solidcommunity.au](https://bydpod.solidcommunity.au) with no
installation required though requiring a BYD Connect login, or the app can be
downloaded and installed for your platform
from the [Solid Community AU](https://solidcommunity.au) repository:

<!-- markdownlint-disable MD036 -->
+ **Web**
  [solidcommunity](https://bydpod.solidcommunity.au/);
+ **Android**
  [aab](https://solidcommunity.au/installers/bydpod.aab) or
  [apk](https://solidcommunity.au/installers/bydpod.apk);
+ **GNU/Linux**
  [deb](https://solidcommunity.au/installers/bydpod_amd64.deb) or
  [snap](https://solidcommunity.au/installers/bydpod_amd64.snap) or
  [zip](https://solidcommunity.au/installers/bydpod-linux.zip);
+ **macOS**
  [dmg](https://solidcommunity.au/installers/bydpod-macos.dmg) or
  [zip](https://solidcommunity.au/installers/bydpod-macos.zip);
+ **Windows**
  [exe](https://solidcommunity.au/installers/bydpod-windows-inno.exe) or
  [zip](https://solidcommunity.au/installers/bydpod-windows.zip).

[Installation
details](https://github.com/gjwgit/bydpod/blob/dev/installers/README.md)
are available for all platforms.

Contributions are welcome. Visit
[github](https://github.com/gjwgit/bydpod) to submit an issue or, even
better, fork the repository yourself, update the code, and submit a Pull
Request. The app is implemented in [Flutter](https://flutter.dev) using
[solidui](https://pub.dev/packages/solidui). Thanks.

## Introduction

BydPod is a desktop and mobile app for BYD owners. It was developed against a
BYD Sealion 7 in Australia, and because it reads generic BYD Connect fields it
should also suit other models — including the DM-i plug-in hybrids, whose fuel
level and range are shown alongside the battery. Every country BYD Connect
operates in can be selected; PRs fixing model- or region-specific quirks are
very welcome.

It connects to the BYD Connect API to fetch live vehicle status (battery
charge, range, odometer, cabin climate, tyre pressures, door locks, warning
lamps) and saves snapshots to your Solid Pod so the data is always yours. A
logbook lets you record every charge and drive with start/end readings,
charging details, and notes. Battery history charts are built from the
accumulated snapshots, while consumption figures come from BYD's own energy
records.

The BYD Connect connection runs via a small Python helper script
(`byd_fetch.py`) that uses the open-source
[pybyd](https://github.com/jkaberg/pyBYD) library, itself built on
community reverse-engineering of the BYD app. There is no official public BYD
API, so expect the occasional field to shift when BYD updates its cloud. The
required setup takes about two minutes on a fresh install.

---

## Features

+ **Login** with your BYD Connect email and password, and the country your
  account is registered in
+ **Auto login** on relaunch — no need to re-enter BYD Connect credentials
+ **Demo mode** — test the UI without real credentials
+ **Status** showing:
  + Vehicle nickname, model, trim, plate & powertrain badge
  + Lock status, power status, charging status
  + Battery level + range bar
  + Fuel level + range bar (DM-i plug-in hybrids)
  + Door, frunk & boot open/close, plus windows and sunroof
  + Tyre pressure (all 4 corners, in kPa) with per-corner warnings
  + Warning lamps — brakes, ABS, airbags, stability, steering, drive and
    charging systems
  + Cabin temperature and climate set point
  + Odometer reading and current speed
  + GPS coordinates on a map
  + Full VIN & vehicle details
  + Last updated timestamp and online/offline state
+ **Driving** — seven-day consumption chart against the model average, and
  where the last 50 km of energy went
+ **Stats** — lifetime and last-50 km consumption, petrol equivalent, and the
  spread of recent days
+ **Log Book** — record every charge and drive with start/end readings
+ **Battery history** — charge and range trends built from your own snapshots
+ **Refresh** button and **Sign out**

---

## Quick start

1. **Install the Python library** — see [BYD Connect setup](#byd-setup)
   below. This is required for live vehicle data.
2. **Log in to your Solid Pod** — tap the pod login button in the app bar and
   authenticate with your Pod provider.
3. **Enter BYD Connect credentials** — go to **Settings** and enter your BYD
   BYD Connect email, password, and PIN. Tap **Save Credentials**.
4. **Test the connection** — tap **Test Connection** in Settings. A step-by-step
   diagnostic shows exactly what's working and what needs attention.
5. **Fetch live data** — tap the cloud refresh button in the app bar to pull the
   latest vehicle status from BYD Connect and save it to your Pod.

---

## BYD Connect setup

The app delegates all BYD API calls to a Python script
(`byd_fetch.py`) that must be placed next to the app binary. The script
requires the `pybyd` Python library.

### 1. Install Python 3.11 or newer

`pybyd` requires Python 3.11+. Most current Linux and macOS systems already
have it. Check with:

```bash
python3 --version
```

If it is missing on Ubuntu/Debian:

```bash
sudo apt install python3 python3-pip
```

### 2. Install pybyd

**Option A — simplest (recommended):**

```bash
pip install pybyd --break-system-packages
```

The `--break-system-packages` flag is required on Ubuntu 23.04+ because the
system pip blocks global installs by default. It is safe to use here — this
library has no effect on system tools.

**Option B — virtual environment:**

If you prefer to keep the library isolated:

```bash
python3 -m venv ~/.local/share/bydpod/venv
~/.local/share/bydpod/venv/bin/pip install pybyd
```

BydPod will find and use this venv automatically — no further
configuration needed. The app searches the following locations in order:

```console
~/.local/share/bydpod/venv/bin/python
~/.bydpod-venv/bin/python
<app binary dir>/venv/bin/python
python3   (system)
python    (system)
```

### 3. Place byd_fetch.py next to the app binary

The script ships alongside the installer. If it is missing, copy it from the
repository into the same directory as the `bydpod` binary:

```bash
# Find where the binary lives:
which bydpod

# Copy the script there (example):
cp byd_fetch.py /usr/local/bin/
```

### 4. Choose your country

BYD keeps each account on a regional server and an account exists only on the
one it was created on, so the wrong country makes a correct password look
wrong. Set it under **Settings → Country** before testing. Australia and New
Zealand share a server; every country BYD Connect operates in is listed.

### 5. Verify with Test Connection

Open **Settings → Test Connection**. The diagnostic dialog checks each
prerequisite in turn and shows a fix command if anything is missing.

### Keyring issues on a fresh Linux install

The app stores BYD Connect credentials in the system keyring (`libsecret`). On a
fresh Ubuntu install the keyring may not be unlocked at startup, which
prevents credentials from being read and causes a `KeyringLocked` error.

Install and open Seahorse to create and unlock the default keyring:

```bash
sudo apt install seahorse
seahorse
```

In Seahorse: **File → New → Password Keyring** → name it `Login` → set a
blank password (or your login password). After that the keyring will unlock
automatically when you log in to the desktop.

---

## 🔌🚗 Showcase 🌳🌞

Under **Settings** you specify the country your BYD Connect account is
registered in, together with your username and password. This is necessary to
use the app. The remote-control PIN is optional — this app only reads vehicle
state and never sends commands to the car.

Screenshots are yet to be captured for BydPod. Run the app in **Demo mode**
from the login screen to see the interface without credentials.

## Setup to Build for Yourself

### Prerequisites

+ Flutter 3.x+ installed
+ `flutter doctor` passing for your target platform

### Install

```bash
git clone git@github.com:gjwgit/bydpod.git
cd bydpod
flutter pub get
flutter run
```

---

## ⚠️ Important Notes

### Unofficial API

BYD does not publish a public API. This app talks to the same endpoints the
BYD Connect phone app uses, via the community reverse-engineering work behind
`pybyd`:

+ [pybyd](https://github.com/jkaberg/pyBYD) — the Python client this app calls
+ [hass-byd-vehicle](https://github.com/jkaberg/hass-byd-vehicle) — the Home
  Assistant integration built on the same library
+ [BYD-re](https://github.com/Niek/BYD-re) — notes on the app's request
  encryption

Two consequences follow. Fields can move or disappear when BYD updates its
cloud, and nothing here is supported by BYD. Unrecognised fields are shown
verbatim in the raw-data view on the Status page rather than being dropped, so
a change usually shows up there first.

To check the connection outside the app, run the helper script directly:

```bash
python3 byd_fetch.py you@example.com YOUR_PASSWORD '' \
        --country AU --debug
```

### Regional servers

BYD runs a separate server per region and an account exists only on the one it
was created on. Pointing the app at the wrong one fails authentication in a
way that is indistinguishable from a wrong password, so if a login you know is
correct keeps failing, check **Settings → Country** first. Australia and New
Zealand share a server.

### Sharing an account with the phone app

The BYD cloud is not always happy with two clients on one account. If the
official app starts logging you out, register a second BYD account, share the
car with it from the app, and use that account here.

### The PIN

The six-digit PIN set in the BYD app authorises remote commands — locking,
climate, and so on. This app only ever reads vehicle state, so the PIN field
may be left blank.

### Rate limits

Avoid refreshing too frequently. A refresh wakes the car's telematics unit to
take a fresh reading, and over-polling a parked car will drain its 12V
battery. Refresh when you want a current reading rather than on a timer.

## Android Network Config

Add to `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
android:networkSecurityConfig="@xml/network_security_config"
```

And create `android/app/src/main/res/xml/network_security_config.xml`.
Every BYD regional node sits under `byd.auto` and is HTTPS only, so cleartext
stays disabled:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">byd.auto</domain>
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </domain-config>
</network-security-config>
```

## iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## The six screens

A left-hand navigation rail gives you:

### Status

Live vehicle status fetched from BYD Connect: battery percentage and estimated
range, climate state, door and window locks, tyre pressures, and the last
update time. Tap the cloud button in the app bar to refresh.

### Driving

Driving efficiency statistics calculated from the logbook: consumption
(kWh/100 km), average speed, and trip breakdowns.

### Battery

Battery history chart built from accumulated logbook readings. Shows state of
charge over time and highlights charge events.

### Comfort

Climate, seat heating/cooling, and other comfort-related readings from the
last BYD Connect snapshot.

### Log Book

The main record of every charge and drive. Each entry captures start and end
vehicle readings (odometer, battery %, remaining kWh, EV range) plus charging
details (vendor, energy delivered, charge rate, duration, cost). Tap an entry
to expand its details, or tap the edit icon to modify it.

### Settings

Enter and save BYD Connect credentials, run the connection diagnostic, and view
setup instructions.

---

## Adding and editing a log entry

Tap **+** in the Log Book screen to add a new entry. The edit form captures:

+ **Title** — e.g. "Home charge", "NRMA fast charge", "Drive to Sydney"
+ **Date and time** — defaults to now
+ **Location** — optional address with geocode
+ **Start readings** — odometer (km), battery (%), EV range (km)
+ **Charging session toggle** — turn on to reveal charging detail fields
+ **End readings** — same fields as start, plus a "From BYD Connect" button that
  fills in the latest values from the last API fetch
+ **Charging details** — vendor/network, energy delivered (kWh), charge rate
  (kW), duration (h and m), cost per kWh, total cost
+ **Notes** — free text for anything else

Tap any existing entry to edit it. Drag the right handle to reorder entries.
Swipe left to delete (with confirmation).

---

## About info

Tap the **info** (ℹ) button in the top app bar at any time to see a brief
about-the-app dialog with the version number and links to the repository.

---

## Data and privacy

All vehicle snapshots and logbook entries are stored in your Solid Pod under
the `bydpod/` directory as Turtle (`.ttl`) and JSON files. Nothing about
your vehicle or driving ever leaves your Pod unless you explicitly export it.

Your BYD Connect credentials (email, password, PIN) are stored only in the
system keyring on your local device — they are never sent to the Pod or to
any server other than the BYD Connect API during a live fetch.

---

## Troubleshooting

**Test Connection shows "Python + pybyd not found".**
Install the library: `pip install pybyd --break-system-packages`
or set up a venv at `~/.local/share/bydpod/venv` — see
[BYD Connect setup](#byd-setup).

**Test Connection shows "byd_fetch.py not found".**
The script must sit next to the app binary. Copy it from the repository to the
path shown in the error message.

**KeyringLocked error on startup.**
The system keyring is not unlocked. Install Seahorse and unlock the default
keyring — see [Keyring issues](#keyring-issues-on-a-fresh-linux-install).
The app will continue to load; enter credentials manually in Settings.

**"Timed out after 90s" from BYD Connect.**
The BYD API is slow or temporarily unavailable. Try again after a few
minutes. If it consistently times out, check that your BYD Connect account is
active in the BYD app on your phone.

**No data on the Status screen after a successful fetch.**
Make sure you are logged in to your Solid Pod (status bar at the bottom shows
"Logged In") and that the security key is cached. Tap the key indicator if it
shows as missing.

---

## License

GNU General Public License v3. See `LICENSE` or
<https://opensource.org/license/gpl-3-0>.

Copyright (C) 2026, Togaware Pty Ltd.
