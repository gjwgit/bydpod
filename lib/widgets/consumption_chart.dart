/// Seven-day consumption chart built from the BYD energy endpoint.
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

import 'package:fl_chart/fl_chart.dart';

import 'package:bydpod/models/energy_history.dart';
import 'package:bydpod/theme/byd_theme.dart';

/// Bar chart of the last seven days of consumption, with the model average
/// drawn behind as a reference line.
///
/// BYD supplies the series in order but attaches no dates to it, so the bars
/// are labelled by how many days ago each reading is rather than by date.
class ConsumptionChart extends StatefulWidget {
  final EnergyHistory history;
  const ConsumptionChart({super.key, required this.history});

  @override
  State<ConsumptionChart> createState() => _ConsumptionChartState();
}

class _ConsumptionChartState extends State<ConsumptionChart> {
  int? _touched;

  /// Bars sit at the oldest-to-newest order BYD returns; the last entry is
  /// the most recent day, so index counts back from zero at the right.
  String _dayLabel(int i, int count) {
    final back = count - 1 - i;
    if (back == 0) return 'Today';
    return '-${back}d';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final series = widget.history.series;
    final baseline = widget.history.modelAverageMean;

    // Leave headroom above the tallest bar so its value label is not clipped,
    // and include the baseline so a high model average stays on-chart.
    final peak = [
      ...series,
      if (baseline != null) baseline,
    ].reduce((a, b) => a > b ? a : b);
    final maxY = (peak * 1.25).ceilToDouble();
    final interval = (maxY / 4).ceilToDouble().clamp(1.0, double.infinity);

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (g, _, __, ___) => BarTooltipItem(
                '${_dayLabel(g.x, series.length)}\n',
                TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '${series[g.x].toStringAsFixed(1)} '
                        '${widget.history.unit}',
                    style: const TextStyle(
                      color: BydColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            touchCallback: (_, r) =>
                setState(() => _touched = r?.spot?.touchedBarGroupIndex),
          ),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (v, _) => Text(
                  series[v.toInt()].toStringAsFixed(1),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _dayLabel(v.toInt(), series.length),
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: interval,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                ),
              ),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: cs.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          // The model average is the fleet figure for this model, drawn as a
          // reference so a day can be read as better or worse than typical.
          extraLinesData: baseline == null
              ? const ExtraLinesData()
              : ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: baseline,
                      color: BydColors.warning,
                      strokeWidth: 2,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          color: BydColors.warning,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        labelResolver: (_) => 'model avg',
                      ),
                    ),
                  ],
                ),
          barGroups: [
            for (var i = 0; i < series.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: series[i],
                    // Days above the fleet average are flagged amber so a
                    // heavy day stands out without reading the axis.
                    color: _touched == i
                        ? BydColors.primary
                        : (baseline != null && series[i] > baseline
                            ? BydColors.warning
                            : BydColors.accent),
                    width: series.length <= 7 ? 22 : 14,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
