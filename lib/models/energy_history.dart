/// Seven-day consumption history and drive-mode split from the BYD API.
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

/// Where the energy of the last 50 km went, as whole percentages.
///
/// BYD splits consumption four ways on its energy page. The four values are
/// intended to total 100 but the cloud rounds each one independently, so do
/// not rely on the sum.
class DriveDistribution {
  final int? drive;
  final int? electronics;
  final int? climate;
  final int? other;

  const DriveDistribution({
    this.drive,
    this.electronics,
    this.climate,
    this.other,
  });

  /// True when at least one share was reported.
  bool get hasData =>
      drive != null || electronics != null || climate != null || other != null;

  /// The four shares as label/percentage pairs, largest first, skipping any
  /// the API did not report.
  List<MapEntry<String, int>> get shares {
    final rows = <MapEntry<String, int>>[
      if (drive != null) MapEntry('Drive motor', drive!),
      if (climate != null) MapEntry('Climate', climate!),
      if (electronics != null) MapEntry('Electronics', electronics!),
      if (other != null) MapEntry('Other', other!),
    ];
    rows.sort((a, b) => b.value.compareTo(a.value));
    return rows;
  }

  static DriveDistribution? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    int? i(String k) => (j[k] as num?)?.round();
    final d = DriveDistribution(
      drive: i('drive'),
      electronics: i('electronics'),
      climate: i('climate'),
      other: i('other'),
    );
    return d.hasData ? d : null;
  }

  Map<String, dynamic> toJson() => {
        'drive': drive,
        'electronics': electronics,
        'climate': climate,
        'other': other,
      };
}

/// The rolling consumption series BYD returns for the energy page.
///
/// [series] is this car's own consumption, oldest first, one entry per day
/// over the last week. [modelAverage] is the fleet average for the same
/// model, which BYD supplies as a comparison baseline. The API gives no dates
/// with either series — only their order.
class EnergyHistory {
  final List<double> series;
  final List<double> modelAverage;

  /// Unit the series is expressed in, e.g. `kWh/100km`.
  final String unit;

  /// Where the last 50 km of energy went.
  final DriveDistribution? distribution;

  const EnergyHistory({
    this.series = const [],
    this.modelAverage = const [],
    this.unit = 'kWh/100km',
    this.distribution,
  });

  bool get hasSeries => series.isNotEmpty;

  /// Mean of the recorded days, or null when the series is empty.
  double? get average =>
      series.isEmpty ? null : series.reduce((a, b) => a + b) / series.length;

  /// Best (lowest consumption) day in the series.
  double? get best =>
      series.isEmpty ? null : series.reduce((a, b) => a < b ? a : b);

  /// Worst (highest consumption) day in the series.
  double? get worst =>
      series.isEmpty ? null : series.reduce((a, b) => a > b ? a : b);

  /// Mean of the model-average baseline, or null when it was not supplied.
  double? get modelAverageMean => modelAverage.isEmpty
      ? null
      : modelAverage.reduce((a, b) => a + b) / modelAverage.length;

  static List<double> _doubles(dynamic v) => (v as List? ?? [])
      .map((e) => e is num ? e.toDouble() : double.tryParse('$e'))
      .whereType<double>()
      .toList();

  /// Builds from the `energy_history` / `drive_distribution` blocks emitted
  /// by byd_fetch.py. Returns null when neither block carries data, so the
  /// UI can fall back to its no-data placeholder.
  static EnergyHistory? fromJson(
    Map<String, dynamic>? history,
    Map<String, dynamic>? distribution,
  ) {
    final dist = DriveDistribution.fromJson(distribution);
    if (history == null) {
      return dist == null ? null : EnergyHistory(distribution: dist);
    }
    final h = EnergyHistory(
      series: _doubles(history['series']),
      modelAverage: _doubles(history['model_average']),
      unit: history['series_unit']?.toString().trim().isNotEmpty == true
          ? history['series_unit'].toString()
          : 'kWh/100km',
      distribution: dist,
    );
    return h.hasSeries || dist != null ? h : null;
  }

  Map<String, dynamic> toJson() => {
        'series': series,
        'model_average': modelAverage,
        'series_unit': unit,
      };
}
