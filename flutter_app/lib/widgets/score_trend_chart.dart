import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/tasting.dart';

/// Line chart showing score trends over time (compatible with fl_chart 0.69.x)
class ScoreTrendChart extends StatelessWidget {
  final List<_ScorePoint> points;
  final double height;

  const ScoreTrendChart({
    super.key,
    required this.points,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('暂无评分数据', style: TextStyle(color: AppTheme.textSecondary))),
      );
    }

    // Sort by date
    final sorted = List<_ScorePoint>.from(points)..sort((a, b) => a.date.compareTo(b.date));

    final minScore = sorted.map((p) => p.score).reduce(math.min);
    final maxScore = sorted.map((p) => p.score).reduce(math.max);
    final yMin = (minScore - 5).clamp(0, 100).toDouble();
    final yMax = (maxScore + 5).clamp(0, 100).toDouble();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 10,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < sorted.length) {
                    final date = sorted[idx].date;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        '${date.month}/${date.day}',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: yMin,
          maxY: yMax,
          lineBarsData: [
            LineChartBarData(
              spots: sorted.asMap().entries.map(
                (e) => FlSpot(e.key.toDouble(), e.value.score.toDouble()),
              ).toList(),
              isCurved: true,
              color: AppTheme.wineRed,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.wineRed.withValues(alpha: 0.08),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final idx = spot.spotIndex;
                  final date = sorted[idx].date;
                  return LineTooltipItem(
                    '${date.year}-${_pad(date.month)}-${_pad(date.day)}\n${spot.y.toInt()}分',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

/// A data point for the score trend chart
class _ScorePoint {
  final DateTime date;
  final int score;

  const _ScorePoint({required this.date, required this.score});
}

/// Helper to create score points from tasting data
class ScoreTrendData {
  static List<_ScorePoint> fromTastingMaps(List<Map<String, dynamic>> maps) {
    return maps.map((m) {
      final tasting = m['tasting'];
      return _ScorePoint(
        date: tasting.drinkingDate ?? tasting.createdAt ?? DateTime.now(),
        score: tasting.score100 ?? 0,
      );
    }).toList();
  }
}
