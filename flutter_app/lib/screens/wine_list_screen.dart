import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/wine.dart';
import '../utils/image_utils.dart';
import '../models/tasting.dart';
import '../theme/app_theme.dart';
import '../utils/wine_type_helper.dart';
import '../widgets/empty_state.dart';
import 'wine_detail_screen.dart';
import 'tasting_form_screen.dart';

class WineListScreen extends StatefulWidget {
  const WineListScreen({super.key});

  @override
  State<WineListScreen> createState() => _WineListScreenState();
}

class _WineListScreenState extends State<WineListScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Wine> _wines = [];
  List<Wine> _filteredWines = [];
  Map<int, int?> _wineScores = {};
  Map<int, String?> _winePhotos = {};
  final _searchController = TextEditingController();
  String _sortBy = 'date'; // date, score, price, name
  String? _filterType;
  String? _filterCountry;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWines() async {
    setState(() => _isLoading = true);
    final wines = await _db.getAllWines();
    // 加载每个酒的最新品鉴评分 和 第一张照片
    final Map<int, int?> scores = {};
    final wineIds = <int>[];
    for (final w in wines) {
      if (w.id != null) wineIds.add(w.id!);
    }
    if (wineIds.isNotEmpty) {
      final photos = await _db.getFirstPhotoForWines(wineIds);
      _winePhotos = photos;
    }
    for (final w in wines) {
      if (w.id != null) {
        final tastings = await _db.getTastingsForWine(w.id!);
        scores[w.id!] = tastings.isNotEmpty ? tastings.first.score100 : null;
      }
    }
    setState(() {
      _wines = wines;
      _wineScores = scores;
      _isLoading = false;
      _applyFilters();
    });
  }

  void _applyFilters() {
    var list = List<Wine>.from(_wines);

    // 搜索
    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      list = list.where((w) =>
        w.name.toLowerCase().contains(query) ||
        (w.winery?.toLowerCase().contains(query) ?? false) ||
        (w.country?.toLowerCase().contains(query) ?? false) ||
        (w.region?.toLowerCase().contains(query) ?? false) ||
        (w.variety?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    // 类型筛选
    if (_filterType != null) {
      list = list.where((w) => w.wineType == _filterType).toList();
    }

    // 国家筛选
    if (_filterCountry != null) {
      list = list.where((w) => w.country == _filterCountry).toList();
    }

    // 排序
    switch (_sortBy) {
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'score':
        list.sort((a, b) {
          final sa = _wineScores[a.id] ?? 0;
          final sb = _wineScores[b.id] ?? 0;
          return sb.compareTo(sa);
        });
        break;
      case 'price':
        list.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'date':
      default:
        list.sort((a, b) => (b.updatedAt ?? DateTime(2000)).compareTo(a.updatedAt ?? DateTime(2000)));
        break;
    }

    setState(() => _filteredWines = list);
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('排序方式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: _sortBy == 'date' ? AppTheme.wineRed : null),
              title: Text('按日期'),
              trailing: _sortBy == 'date' ? const Icon(Icons.check, color: AppTheme.wineRed) : null,
              onTap: () { setState(() => _sortBy = 'date'); Navigator.pop(ctx); _applyFilters(); },
            ),
            ListTile(
              leading: Icon(Icons.star, color: _sortBy == 'score' ? AppTheme.wineRed : null),
              title: Text('按评分'),
              trailing: _sortBy == 'score' ? const Icon(Icons.check, color: AppTheme.wineRed) : null,
              onTap: () { setState(() => _sortBy = 'score'); Navigator.pop(ctx); _applyFilters(); },
            ),
            ListTile(
              leading: Icon(Icons.attach_money, color: _sortBy == 'price' ? AppTheme.wineRed : null),
              title: Text('按价格'),
              trailing: _sortBy == 'price' ? const Icon(Icons.check, color: AppTheme.wineRed) : null,
              onTap: () { setState(() => _sortBy = 'price'); Navigator.pop(ctx); _applyFilters(); },
            ),
            ListTile(
              leading: Icon(Icons.sort_by_alpha, color: _sortBy == 'name' ? AppTheme.wineRed : null),
              title: Text('按名称'),
              trailing: _sortBy == 'name' ? const Icon(Icons.check, color: AppTheme.wineRed) : null,
              onTap: () { setState(() => _sortBy = 'name'); Navigator.pop(ctx); _applyFilters(); },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterMenu() {
    final countries = _wines.map((w) => w.country).where((c) => c != null && c.isNotEmpty).toSet().toList()..sort();
    final types = ['red', 'white', 'rose', 'sparkling', 'sweet'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('筛选条件', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('酒类型', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: types.map((t) => ChoiceChip(
                  label: Text(WineTypeHelper.getLabel(t)),
                  selected: _filterType == t,
                  selectedColor: AppTheme.wineRed,
                  labelStyle: TextStyle(color: _filterType == t ? Colors.white : null),
                  onSelected: (v) {
                    setState(() => _filterType = v ? t : null);
                    Navigator.pop(ctx);
                    _applyFilters();
                  },
                )).toList(),
              ),
              if (countries.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('国家', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: countries.map((c) => ChoiceChip(
                    label: Text(c!),
                    selected: _filterCountry == c,
                    selectedColor: AppTheme.wineRed,
                    labelStyle: TextStyle(color: _filterCountry == c ? Colors.white : null),
                    onSelected: (v) {
                      setState(() => _filterCountry = v ? c : null);
                      Navigator.pop(ctx);
                      _applyFilters();
                    },
                  )).toList(),
                ),
              ],
              if (_filterType != null || _filterCountry != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () { setState(() { _filterType = null; _filterCountry = null; }); Navigator.pop(ctx); _applyFilters(); },
                  child: const Text('清除筛选'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('酒款列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortMenu,
            tooltip: '排序',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterMenu,
            tooltip: '筛选',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: '搜索酒名、酒庄、产区...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  ),
              ],
              onChanged: (_) => _applyFilters(),
            ),
          ),
          if (_filterType != null || _filterCountry != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_filterType != null)
                    Chip(
                      label: Text(WineTypeHelper.getLabel(_filterType!)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () { setState(() => _filterType = null); _applyFilters(); },
                    ),
                  if (_filterCountry != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_filterCountry!),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () { setState(() => _filterCountry = null); _applyFilters(); },
                    ),
                  ],
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredWines.isEmpty
                    ? EmptyState(
                        icon: Icons.local_bar,
                        message: '还没有酒款记录\n开始你的品鉴之旅吧！',
                        actionLabel: '新建品鉴',
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TastingFormScreen(wineType: 'red')),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadWines,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredWines.length,
                          itemBuilder: (_, i) => _WineCard(
                            wine: _filteredWines[i],
                            score: _wineScores[_filteredWines[i].id],
                            photoPath: _winePhotos[_filteredWines[i].id],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WineDetailScreen(wine: _filteredWines[i]),
                              ),
                            ).then((_) => _loadWines()),
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TastingFormScreen(wineType: 'red')),
        ).then((_) => _loadWines()),
        backgroundColor: AppTheme.wineRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _WineCard extends StatelessWidget {
  final Wine wine;
  final int? score;
  final String? photoPath;
  final VoidCallback onTap;

  const _WineCard({
    required this.wine,
    this.score,
    this.photoPath,
    required this.onTap,
  });

  Widget _wineIcon(Color typeColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.local_bar,
        color: typeColor,
        size: size * 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = WineTypeHelper.getColor(wine.wineType);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: typeColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: photoPath != null
                    ? WinePhoto(
                        path: photoPath!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _wineIcon(typeColor, 56),
                      )
                    : _wineIcon(typeColor, 56),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wine.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (wine.winery != null && wine.winery!.isNotEmpty) ...[
                          Text(
                            wine.winery!,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (wine.vintage != null)
                          Text(
                            '${wine.vintage}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            WineTypeHelper.getLabel(wine.wineType),
                            style: TextStyle(fontSize: 10, color: typeColor),
                          ),
                        ),
                        if (wine.country != null && wine.country!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            wine.country!,
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (score != null)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: score! >= 85
                        ? Colors.green.withValues(alpha: 0.1)
                        : score! >= 70
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: score! >= 85
                          ? Colors.green[700]
                          : score! >= 70
                              ? Colors.orange[700]
                              : Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
