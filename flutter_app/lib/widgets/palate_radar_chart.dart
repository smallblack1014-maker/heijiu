import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/tasting_palate.dart';
import '../theme/app_theme.dart';
import '../utils/wine_type_helper.dart';

/// Radar chart showing palate scoring dimensions.
///
/// - Red wine: 6 axes (酒体, 平衡感, 复杂度, 余味, 酸度, 单宁) — solid line polygon
/// - Other wines (white, rosé, sparkling, sweet): 5 axes (酒体, 平衡感, 复杂度, 余味, 酸度) — no tannin
class PalateRadarChart extends StatelessWidget {
  final TastingPalate palate;
  final double size;
  final bool showLabels;
  final String wineType;

  const PalateRadarChart({
    super.key,
    required this.palate,
    this.size = 200,
    this.showLabels = true,
    this.wineType = 'red',
  });

  bool get _showTannin => WineTypeHelper.isTanninRelevant(wineType);

  @override
  Widget build(BuildContext context) {
    // Core dimensions (0-10 scale)
    final body = palate.body.toDouble();
    final balance = palate.balance.toDouble();
    final complexity = palate.complexity.toDouble();
    final finishLength = palate.finishLength.toDouble();
    final acidity = palate.acidity.toDouble();

    // Tannin (only for red wine)
    final tannin = palate.tannin.toDouble();

    // Build axis data entries (tannin last, or skip if not red)
    final List<RadarEntry> entries = [
      RadarEntry(value: body),
      RadarEntry(value: balance),
      RadarEntry(value: complexity),
      RadarEntry(value: finishLength),
      RadarEntry(value: acidity),
    ];
    if (_showTannin) {
      entries.add(RadarEntry(value: tannin));
    }

    return SizedBox(
      width: size,
      height: size,
      child: RadarChart(
        RadarChartData(
          radarTouchData: RadarTouchData(enabled: false),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          tickCount: 5,
          tickBorderData: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
          gridBorderData: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
          radarBackgroundColor: Colors.transparent,
          radarBorderData: BorderSide.none,
          getTitle: (index, angle) {
            if (!showLabels) return RadarChartTitle(text: '');
            switch (index) {
              case 0: return RadarChartTitle(text: '酒体');
              case 1: return RadarChartTitle(text: '平衡感');
              case 2: return RadarChartTitle(text: '复杂度');
              case 3: return RadarChartTitle(text: '余味');
              case 4: return RadarChartTitle(text: '酸度');
              case 5: return _showTannin ? RadarChartTitle(text: '单宁') : const RadarChartTitle(text: '');
              default: return RadarChartTitle(text: '');
            }
          },
          dataSets: [
            // Single unified polygon — solid wine-red fill
            RadarDataSet(
              fillColor: AppTheme.wineRed.withValues(alpha: 0.15),
              borderColor: AppTheme.wineRed,
              borderWidth: 2,
              entryRadius: 0,
              dataEntries: entries,
            ),
          ],
        ),
      ),
    );
  }
}
