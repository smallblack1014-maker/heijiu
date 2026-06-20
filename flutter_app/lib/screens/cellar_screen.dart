import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'cellar_detail_screen.dart';
import 'cellar_add_screen.dart';

class CellarScreen extends StatefulWidget {
  const CellarScreen({super.key});

  @override
  State<CellarScreen> createState() => _CellarScreenState();
}

class _CellarScreenState extends State<CellarScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _cellarItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _groupBy = 'none'; // none, location

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await _db.getCellarItems();
    setState(() {
      _cellarItems = items;
      _isLoading = false;
      _applyFilter();
    });
  }

  void _applyFilter() {
    var list = List<Map<String, dynamic>>.from(_cellarItems);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((item) {
        final name = (item['wineName'] as String?)?.toLowerCase() ?? '';
        return name.contains(q);
      }).toList();
    }
    setState(() => _filteredItems = list);
  }

  int get _totalBottles =>
      _cellarItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 0));

  double get _totalValue =>
      _cellarItems.fold<double>(0.0, (sum, item) {
        final qty = item['quantity'] as int? ?? 0;
        final price = (item['purchasePrice'] as num?)?.toDouble() ?? 0;
        return sum + qty * price;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('酒窖库存'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.view_list),
            onSelected: (v) => setState(() => _groupBy = v),
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                value: 'none',
                checked: _groupBy == 'none',
                child: const Text('不分组'),
              ),
              CheckedPopupMenuItem(
                value: 'location',
                checked: _groupBy == 'location',
                child: const Text('按位置分组'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索酒款...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (v) { _searchQuery = v; _applyFilter(); },
            ),
          ),

          // 统计行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Column(
                        children: [
                          const Text('总瓶数', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('$_totalBottles', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.wineRed)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Column(
                        children: [
                          const Text('总价值', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('¥${_totalValue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.wineRed)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? const EmptyState(
                        icon: Icons.inventory_2,
                        message: '酒窖是空的\n去添加一些酒款吧！',
                        actionLabel: '新增入库',
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: _groupBy == 'location'
                            ? _buildGroupedList()
                            : _buildSimpleList(),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CellarAddScreen()),
        ).then((_) => _loadData()),
        backgroundColor: AppTheme.wineRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSimpleList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredItems.length,
      itemBuilder: (_, i) => _CellarItemCard(
        item: _filteredItems[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CellarDetailScreen(
              cellarId: _filteredItems[i]['id'] as int,
              wineName: _filteredItems[i]['wineName'] as String? ?? '',
            ),
          ),
        ).then((_) => _loadData()),
      ),
    );
  }

  Widget _buildGroupedList() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final item in _filteredItems) {
      final loc = item['locationName'] as String? ?? '未分类';
      grouped.putIfAbsent(loc, () => []).add(item);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: sortedKeys.map((loc) {
        final items = grouped[loc]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$loc (${items.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            ...items.map((item) => _CellarItemCard(
              item: item,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CellarDetailScreen(
                    cellarId: item['id'] as int,
                    wineName: item['wineName'] as String? ?? '',
                  ),
                ),
              ).then((_) => _loadData()),
            )),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}

class _CellarItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _CellarItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = item['wineName'] as String? ?? '未知酒款';
    final vintage = item['wineVintage'] as int?;
    final quantity = item['quantity'] as int? ?? 1;
    final location = item['locationName'] as String? ?? '未设位置';
    final price = (item['purchasePrice'] as num?)?.toDouble();
    final wineType = item['wineType'] as String? ?? 'red';
    final typeColor = wineType == 'red'
        ? const Color(0xFF722F37)
        : wineType == 'white'
            ? const Color(0xFFE8D5A3)
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_bar, color: typeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text('x$quantity', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 8),
                        Icon(Icons.location_on, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 2),
                        Text(location, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              if (vintage != null)
                Text('$vintage', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              if (price != null) ...[
                const SizedBox(width: 8),
                Text('¥${price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
