import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart' as share;
import '../database/database_helper.dart';
import '../utils/image_utils.dart';
import '../models/wine.dart';
import '../models/tasting.dart';
import '../models/tasting_appearance.dart';
import '../models/tasting_aroma.dart';
import '../models/tasting_palate.dart';
import '../models/tasting_overall.dart';
import '../theme/app_theme.dart';
import '../utils/wine_type_helper.dart';
import 'wine_archive_screen.dart';
import 'cellar_add_screen.dart';
import 'tasting_form_screen.dart';
import '../widgets/palate_radar_chart.dart';
import '../widgets/score_trend_chart.dart';
import '../widgets/tasting_share_card.dart';

class WineDetailScreen extends StatefulWidget {
  final Wine wine;

  const WineDetailScreen({super.key, required this.wine});

  @override
  State<WineDetailScreen> createState() => _WineDetailScreenState();
}

class _WineDetailScreenState extends State<WineDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  Wine? _wine;
  List<Map<String, dynamic>> _tastings = [];
  List<Map<String, dynamic>> _allPhotos = [];
  bool _isLoading = true;
  int? _expandedTastingId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final wine = await _db.getWine(widget.wine.id!);
    final tastings = await _db.getTastingsForWine(widget.wine.id!);
    // 获取该酒款的全部照片（跨所有品鉴记录）
    final allPhotos = await _db.getAllPhotosForWine(widget.wine.id!);
    // 获取品鉴详情
    final List<Map<String, dynamic>> tastingDetails = [];
    for (final t in tastings) {
      final appearance = await _db.getAppearance(t.id!);
      final aroma = await _db.getAroma(t.id!);
      final palate = await _db.getPalate(t.id!);
      final overall = await _db.getOverall(t.id!);
      final flavorNames = await _db.getTastingFlavorNames(t.id!);
      final photos = await _db.getTastingPhotos(t.id!);
      tastingDetails.add({
        'tasting': t,
        'appearance': appearance,
        'aroma': aroma,
        'palate': palate,
        'overall': overall,
        'flavors': flavorNames,
        'photos': photos,
      });
    }
    setState(() {
      _wine = wine;
      _tastings = tastingDetails;
      _allPhotos = allPhotos;
      _isLoading = false;
    });
  }

  void _deleteWine() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${_wine?.name}"吗？所有品鉴记录也将被删除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              await _db.softDeleteWine(_wine!.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('酒款详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_wine == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('酒款详情')),
        body: const Center(child: Text('酒款已删除')),
      );
    }

    final wine = _wine!;
    final typeColor = WineTypeHelper.getColor(wine.wineType);
    final latestScore = _tastings.isNotEmpty
        ? (_tastings.first['tasting'] as Tasting).score100
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(wine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WineArchiveScreen(wine: wine),
              ),
            ),
            tooltip: '档案库',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteWine,
            tooltip: '删除',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 酒款头部
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.local_bar, color: typeColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wine.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (wine.winery != null)
                        Text(wine.winery!, style: const TextStyle(color: AppTheme.textSecondary)),
                      if (wine.vintage != null)
                        Text('${wine.vintage}年份', style: const TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                if (latestScore != null)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.wineRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$latestScore',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.wineRed,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 酒款信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('类型', WineTypeHelper.getLabel(wine.wineType)),
                    if (wine.country != null) _infoRow('国家', wine.country!),
                    if (wine.region != null) _infoRow('产区', wine.region!),
                    if (wine.variety != null) _infoRow('品种', wine.variety!),
                    if (wine.alcohol != null) _infoRow('酒精度', '${wine.alcohol}%'),
                    if (wine.price != null) _infoRow('价格', '¥${wine.price!.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 评分趋势图（多个品鉴记录时显示）
            if (_tastings.length >= 2) ...[
              _buildSectionTitle('评分趋势', icon: Icons.trending_up),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ScoreTrendChart(
                    points: ScoreTrendData.fromTastingMaps(_tastings),
                    height: 180,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 酒款照片聚合（来自所有品鉴记录）
            if (_allPhotos.isNotEmpty) ...[const SizedBox(height: 16)],
            if (_allPhotos.isNotEmpty)
              _PhotoGallery(photos: _allPhotos),
            if (_allPhotos.isNotEmpty) const SizedBox(height: 16),

            // 操作行
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TastingFormScreen(wineType: wine.wineType),
                        ),
                      ).then((_) => _loadData());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('新增品鉴'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.wineRed),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CellarAddScreen(prefilledWine: wine),
                      ),
                    ),
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('加入酒窖'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.wineRed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 品鉴记录列表
            const Text('品鉴记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_tastings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('暂无品鉴记录', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              )
            else
              ..._tastings.map((t) => _TastingRecordCard(
                data: t,
                wine: wine,
                isExpanded: _expandedTastingId == (t['tasting'] as Tasting).id,
                wineType: wine.wineType,
                onToggle: () {
                  final tid = (t['tasting'] as Tasting).id;
                  setState(() {
                    _expandedTastingId = _expandedTastingId == tid ? null : tid;
                  });
                },
              )),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Build a section title with optional icon
  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppTheme.wineRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          if (icon != null) ...[Icon(icon, size: 18, color: AppTheme.wineRed), const SizedBox(width: 6)],
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TastingRecordCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isExpanded;
  final String wineType;
  final Wine wine;
  final VoidCallback onToggle;

  const _TastingRecordCard({
    required this.data,
    required this.isExpanded,
    required this.wineType,
    required this.wine,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final tasting = data['tasting'] as Tasting;
    final appearance = data['appearance'] as TastingAppearance?;
    final aroma = data['aroma'] as TastingAroma?;
    final palate = data['palate'] as TastingPalate?;
    final overall = data['overall'] as TastingOverall?;
    final flavors = data['flavors'] as List<String>? ?? [];
    final photos = data['photos'] as List<Map<String, dynamic>>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tasting.drinkingDate != null
                              ? '${tasting.drinkingDate!.year}-${tasting.drinkingDate!.month.toString().padLeft(2, '0')}-${tasting.drinkingDate!.day.toString().padLeft(2, '0')}'
                              : '未记录日期',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        if (tasting.score100 != null)
                          Text(
                            '评分: ${tasting.score100}/100',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.wineRed,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (tasting.isBlind == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('盲品', style: TextStyle(fontSize: 11, color: Colors.orange)),
                    ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      tasting.scoringMode == 'quick' ? '快速' : tasting.scoringMode == 'professional' ? '专业' : '标准',
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const Divider(),
                if (photos.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final path = photos[i]['photoPath'] as String;
                          return GestureDetector(
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: InteractiveViewer(
                                  child: Image.memory(ImageUtils.dataUrlToBytes(path), fit: BoxFit.contain),
                                ),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                ImageUtils.dataUrlToBytes(path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (appearance != null)
                  _detailRow('外观', '颜色: ${appearance.color ?? "-"}, 清澈度: ${appearance.clarity ?? "-"}, 深浅: ${appearance.intensity ?? "-"}'),
                if (aroma != null)
                  _detailRow('香气', '强度: ${aroma.intensity}, 复杂度: ${aroma.complexity}, 纯净度: ${aroma.purity}'),
                if (flavors.isNotEmpty) _detailRow('风味', flavors.join(', ')),
                if (palate != null)
                  _detailRow('口感', '酸度: ${palate.acidity}, 单宁: ${palate.tannin}, 酒体: ${palate.body}, 余味: ${palate.finishLength}'),
                if (overall != null)
                  _detailRow('综合', '愉悦度: ${overall.enjoyment}, 性价比: ${overall.value}'),
                if (tasting.notes != null && tasting.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(tasting.notes!, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ),
                if (palate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: PalateRadarChart(palate: palate, size: 160, wineType: wineType),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      tooltip: '分享品鉴卡',
                      onPressed: () => _showShareCard(context, data),
                      color: AppTheme.wineRed,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: '编辑',
                      onPressed: () {
                        final tasting = data['tasting'] as Tasting;
                        final wineType = data['wineType'] as String? ?? 'red';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TastingFormScreen(
                              wineType: wineType,
                              tastingId: tasting.id,
                              existingWineId: tasting.wineId,
                            ),
                          ),
                        );
                      },
                      color: AppTheme.wineRed,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // ─── Share Card ───

  void _showShareCard(BuildContext context, Map<String, dynamic> data) {
    final tasting = data['tasting'] as Tasting;
    final appearance = data['appearance'] as TastingAppearance?;
    final aroma = data['aroma'] as TastingAroma?;
    final palate = data['palate'] as TastingPalate?;
    final overall = data['overall'] as TastingOverall?;
    final flavors = (data['flavors'] as List<dynamic>).cast<String>();

    final shareKey = GlobalKey();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TastingShareCard(
              wine: wine,
              tasting: tasting,
              appearance: appearance,
              aroma: aroma,
              palate: palate,
              overall: overall,
              flavors: flavors,
              repaintKey: shareKey,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                // Delay to let dialog close, then capture and share
                await Future.delayed(const Duration(milliseconds: 100));
                _captureAndShare(context, shareKey);
              },
              icon: const Icon(Icons.share),
              label: const Text('分享图片'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.wineRed,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndShare(BuildContext context, GlobalKey repaintKey) async {
    try {
      // We need to render off-screen to capture the card.
      // Since the dialog is already closed, we'll build a new overlay.
      final overlayEntry = OverlayEntry(
        builder: (_) => Material(
          color: Colors.black54,
          child: Center(
            child: RepaintBoundary(
              key: repaintKey,
              child: TastingShareCard(
                wine: wine,
                tasting: Tasting(wineId: wine.id ?? 0, score100: 0), // placeholder, real data set below
                repaintKey: repaintKey,
              ),
            ),
          ),
        ),
      );

      // Simpler approach: show a brief overlay, capture, then remove
      final overlay = Overlay.of(context);
      overlay.insert(overlayEntry);

      // Allow frame to render
      await Future.delayed(const Duration(milliseconds: 200));

      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        overlayEntry.remove();
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      overlayEntry.remove();

      if (bytes != null) {
        await share.Share.shareXFiles(
          [share.XFile.fromData(bytes, name: '${wine.name}_品鉴卡.png')],
          text: '来自黑酒的品鉴记录',
        );
      }
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }
}

/// 酒款照片聚合画廊 — 展示所有品鉴记录中拍摄的照片
class _PhotoGallery extends StatelessWidget {
  final List<Map<String, dynamic>> photos;

  const _PhotoGallery({required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return const SizedBox.shrink();

    // 按饮用日期分组：最新拍摄的靠前
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final p in photos) {
      final label = (p['drinkingDate'] as String?) != null
          ? DateTime.tryParse(p['drinkingDate'])?.toIso8601String().substring(0, 10) ?? '其他'
          : '其他';
      grouped.putIfAbsent(label, () => []).add(p);
    }
    // 按日期降序排列日期组
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library, size: 18, color: AppTheme.wineRed),
                const SizedBox(width: 6),
                Text(
                  '照片记录（${photos.length}张）',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...sortedDates.map((date) {
              final groupPhotos = grouped[date]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: groupPhotos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final path = groupPhotos[i]['photoPath'] as String;
                          return GestureDetector(
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: InteractiveViewer(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: WinePhoto(
                                      path: path,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: WinePhoto(
                                path: path,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
