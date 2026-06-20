import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/empty_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  bool _isLoading = true;

  int _totalTastings = 0;
  double _avgScore = 0;
  String _highestScoreInfo = '';
  double _totalSpent = 0;
  String? _favCountry;
  String? _favRegion;
  String? _favVariety;
  List<Map<String, dynamic>> _scoreTrend = [];
  List<Map<String, dynamic>> _countryDist = [];
  List<Map<String, dynamic>> _regionDist = [];
  List<Map<String, dynamic>> _varietyDist = [];
  List<Map<String, dynamic>> _priceScoreData = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final total = await _db.getTotalTastings();
    final avg = await _db.getAvgScore();
    final highest = await _db.getHighestScoreWine();
    final spent = await _db.getTotalSpent();
    final favCountry = await _db.getFavoriteCountry();
    final favRegion = await _db.getFavoriteRegion();
    final favVariety = await _db.getFavoriteVariety();
    final trend = await _db.getScoreTrend();
    final country = await _db.getCountryDistribution();
    final region = await _db.getRegionDistribution();
    final variety = await _db.getVarietyDistribution();
    final priceScore = await _db.getPriceScoreData();

    setState(() {
      _totalTastings = total;
      _avgScore = avg;
      _highestScoreInfo = highest != null
          ? '${highest['name']} (${highest['score100']})'
          : '-';
      _totalSpent = spent;
      _favCountry = favCountry;
      _favRegion = favRegion;
      _favVariety = favVariety;
      _scoreTrend = trend;
      _countryDist = country;
      _regionDist = region;
      _varietyDist = variety;
      _priceScoreData = priceScore;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('统计分析')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_totalTastings == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('统计分析')),
        body: const EmptyState(
          icon: Icons.bar_chart,
          message: '还没有品鉴数据\n开始品鉴后统计信息将自动生成',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('统计分析')),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 概览卡片
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  StatCard(
                    icon: Icons.local_bar,
                    title: '累计品鉴',
                    value: '$_totalTastings',
                  ),
                  StatCard(
                    icon: Icons.star,
                    title: '平均分',
                    value: _avgScore.toStringAsFixed(1),
                  ),
                  StatCard(
                    icon: Icons.emoji_events,
                    title: '最高分',
                    value: _highestScoreInfo,
                    color: Colors.amber,
                  ),
                  StatCard(
                    icon: Icons.attach_money,
                    title: '总消费',
                    value: '¥${_totalSpent.toStringAsFixed(0)}',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 偏好
              if (_favCountry != null || _favRegion != null || _favVariety != null) ...[
                const Text('偏好统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_favCountry != null)
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Text('最爱国家', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Text(_favCountry!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_favRegion != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Text('最爱产区', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Text(_favRegion!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_favVariety != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Text('最爱品种', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Text(_favVariety!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // 评分趋势
              if (_scoreTrend.length >= 2) ...[
                const Text('评分趋势', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: Card(
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
                                showTitles: true,
                                reservedSize: 28,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx >= 0 && idx < _scoreTrend.length) {
                                    final label = _scoreTrend[idx]['month'] as String;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        label.substring(5),
                                        style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
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
                              spots: _scoreTrend.asMap().entries.map((e) =>
                                FlSpot(e.key.toDouble(), (e.value['avgScore'] as num).toDouble()),
                              ).toList(),
                              isCurved: true,
                              color: AppTheme.wineRed,
                              barWidth: 3,
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
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 国家分布饼图
              if (_countryDist.isNotEmpty) ...[
                const Text('国家分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(_countryDist),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 产区分布饼图
              if (_regionDist.isNotEmpty) ...[
                const Text('产区分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(_regionDist),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 品种分布柱状图
              if (_varietyDist.isNotEmpty) ...[
                const Text('品种分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx >= 0 && idx < _varietyDist.length) {
                                    final label = _varietyDist[idx]['variety'] as String;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        label.length > 4 ? '${label.substring(0, 4)}...' : label,
                                        style: const TextStyle(fontSize: 9),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _varietyDist.asMap().entries.map((e) =>
                            BarChartGroupData(x: e.key, barRods: [
                              BarChartRodData(
                                toY: (e.value['count'] as num).toDouble(),
                                color: AppTheme.wineRed,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ]),
                          ).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 价格评分散点图
              if (_priceScoreData.length >= 3) ...[
                const Text('价格 vs 评分', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ScatterChart(
                        ScatterChartData(
                          scatterSpots: _priceScoreData.map<ScatterSpot>((d) =>
                            ScatterSpot(
                              (d['price'] as num).toDouble(),
                              (d['score100'] as num).toDouble(),
                            ),
                          ).toList(),
                          minY: 50,
                          maxY: 100,
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) => Text(
                                  '¥${value.toInt()}',
                                  style: const TextStyle(fontSize: 9),
                                ),
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(List<Map<String, dynamic>> data) {
    final colors = [
      AppTheme.wineRed, AppTheme.wineGold, Colors.blue, Colors.green,
      Colors.orange, Colors.purple, Colors.teal, Colors.pink,
    ];
    final total = data.fold<int>(0, (sum, d) => sum + (d['count'] as int));
    return data.asMap().entries.map((e) {
      final count = e.value['count'] as int;
      final label = (e.value.values.first as String?) ?? '未知';
      final pct = (count / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        color: colors[e.key % colors.length],
        value: count.toDouble(),
        title: '$pct%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}
