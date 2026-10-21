import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format.dart';
import '../report_data.dart';

class VelocityChart extends StatelessWidget {
  const VelocityChart({
    super.key,
    required this.reps,
    required this.threshold,
    this.height = 196,
  });

  final List<RepReport> reps;
  final double threshold;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (reps.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            '—',
            style: TextStyle(color: AppColors.dim, fontSize: 24),
          ),
        ),
      );
    }
    final best = reps
        .map((rep) => rep.meanVelocity)
        .reduce((a, b) => a > b ? a : b);
    final maxY = math.max(0.8, best * 1.3);
    final thresholdY = best * (1 - threshold / 100);
    final interval = maxY / 4;
    final barWidth = reps.length <= 2
        ? 30.0
        : reps.length <= 4
        ? 22.0
        : reps.length > 10
        ? 8.0
        : (reps.length > 6 ? 12.0 : 16.0);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 6,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceHigh,
              tooltipBorderRadius: BorderRadius.circular(10),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final rep = reps[group.x - 1];
                return BarTooltipItem(
                  '${formatVelocity(rod.toY)} m/s\n',
                  const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'ROM ${rep.romCm.round()}cm · VL ${rep.velocityLoss.round()}%',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: thresholdY,
                color: AppColors.orange.withValues(alpha: 0.6),
                strokeWidth: 1,
                dashArray: const [4, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 2, bottom: 2),
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                  labelResolver: (_) => 'VL ${threshold.round()}%',
                ),
              ),
            ],
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 8.5,
                        color: AppColors.dim,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 1 || index > reps.length) {
                    return const SizedBox.shrink();
                  }
                  if (reps.length > 12 && index.isOdd) {
                    return const SizedBox.shrink();
                  }
                  final isBest = reps[index - 1].isBestRep;
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isBest ? FontWeight.w800 : FontWeight.w600,
                        color: isBest ? AppColors.green : AppColors.dim,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.045),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (var index = 0; index < reps.length; index++)
              BarChartGroupData(
                x: index + 1,
                barRods: [
                  BarChartRodData(
                    toY: reps[index].meanVelocity,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(4),
                    color: _colorFor(reps[index]),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: Colors.white.withValues(alpha: 0.025),
                    ),
                  ),
                ],
              ),
          ],
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Color _colorFor(RepReport rep) {
    if (rep.isBestRep) return AppColors.green;
    if (rep.velocityLoss >= threshold) return AppColors.orange;
    return AppColors.blue;
  }
}
