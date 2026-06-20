import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../models/wine.dart';
import '../models/tasting.dart';
import '../models/tasting_appearance.dart';
import '../models/tasting_aroma.dart';
import '../models/tasting_palate.dart';
import '../models/tasting_overall.dart';
import '../theme/app_theme.dart';
import '../utils/wine_type_helper.dart';
import 'cellar_add_screen.dart';
import 'tasting_form_screen.dart';

class WineArchiveScreen extends StatefulWidget {
  final Wine wine;

  const WineArchiveScreen({super.key, required this.wine});

  @override
  State<WineArchiveScreen> createState() => _WineArchiveScreenState();
}

class _WineArchiveScreenState extends State<WineArchiveScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Tasting> _tastings = [];
  List<Map<String, dynamic>> _tastingDetails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tastings = await _db.getTastingsForWine(widget.wine.id!);
    final List<Map<String, dynamic>> details = [];
    for (final t in tastings) {
      final appearance = await _db.getAppearance(t.id!);
      final aroma = await _db.getAroma(t.id!);
      final palate = await _db.getPalate(t.id!);
      final overall = await _db.getOverall(t.id!);
      details.add({
        'tasting': t,
        'appearance': appearance,
        'aroma': aroma,
        'palate': palate,
        'overall': overall,
      });
    }
    setState(() {
      _tastings = tastings;
      _tastingDetails = details;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('酒款档案')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final typeColor = WineTypeHelper.getColor(widget.wine.wineType);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.wine.name} 档案'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 酒款标题
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.local_bar, color: typeColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.wine.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (widget.wine.winery != null)
                        Text(widget.wine.winery!, style: const TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 评分趋势折线图
            if (_tastings.length >= 2) ...[
              const Text('评分趋势', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: _ScoreTrendChart(tastings: _tastings),
              ),
              const SizedBox(height: 20),
            ],

            // 品鉴记录时间线
            const Text('品鉴时间线', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_tastings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('暂无品鉴记录', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              )
            else
              ..._tastings.asMap().entries.map((entry) {
                final i = entry.key;
                final t = entry.value;
                final isLast = i == _tastings.length - 1;
                return _TimelineItem(
                  isLast: isLast,
                  tasting: t,
                  details: _tastingDetails.length > i ? _tastingDetails[i] : {},
                );
              }),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_tasting',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TastingFormScreen(wineType: widget.wine.wineType),
              ),
            ).then((_) => _loadData()),
            backgroundColor: AppTheme.wineRed,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'add_cellar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CellarAddScreen(prefilledWine: widget.wine),
              ),
            ),
            backgroundColor: AppTheme.wineRedLight,
            child: const Icon(Icons.inventory_2, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ScoreTrendChart extends StatelessWidget {
  final List<Tasting> tastings;

  const _ScoreTrendChart({required this.tastings});

  @override
  Widget build(BuildContext context) {
    final reversed = tastings.reversed.toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < reversed.length; i++) {
      if (reversed[i].score100 != null) {
        spots.add(FlSpot(i.toDouble(), reversed[i].score100!.toDouble()));
      }
    }

    if (spots.length < 2) {
      return const Center(child: Text('数据不足', style: TextStyle(color: AppTheme.textSecondary)));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 10,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minY: 50,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppTheme.wineRed,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: AppTheme.wineRed,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.wineRed.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final bool isLast;
  final Tasting tasting;
  final Map<String, dynamic> details;

  const _TimelineItem({
    required this.isLast,
    required this.tasting,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final appearance = details['appearance'] as TastingAppearance?;
    final aroma = details['aroma'] as TastingAroma?;
    final palate = details['palate'] as TastingPalate?;
    final overall = details['overall'] as TastingOverall?;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppTheme.wineRed,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.wineRed.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tasting.drinkingDate != null
                                ? '${tasting.drinkingDate!.year}-${tasting.drinkingDate!.month.toString().padLeft(2, '0')}-${tasting.drinkingDate!.day.toString().padLeft(2, '0')}'
                                : '日期未记录',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (tasting.score100 != null)
                          Text(
                            '${tasting.score100}/100',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.wineRed,
                            ),
                          ),
                      ],
                    ),
                    if (tasting.notes != null && tasting.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(tasting.notes!, style: const TextStyle(fontSize: 12, height: 1.4)),
                    ],
                    if (tasting.venue != null && tasting.venue!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(tasting.venue!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
