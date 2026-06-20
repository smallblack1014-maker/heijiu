import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/cellar.dart';
import '../models/cellar_transaction.dart';
import '../theme/app_theme.dart';

class CellarDetailScreen extends StatefulWidget {
  final int cellarId;
  final String wineName;

  const CellarDetailScreen({
    super.key,
    required this.cellarId,
    required this.wineName,
  });

  @override
  State<CellarDetailScreen> createState() => _CellarDetailScreenState();
}

class _CellarDetailScreenState extends State<CellarDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  Map<String, dynamic>? _cellarItem;
  List<CellarTransaction> _transactions = [];
  List<Map<String, dynamic>> _relatedTastings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Get the item from all cellar items
    final items = await _db.getCellarItems();
    final item = items.firstWhere(
      (i) => i['id'] == widget.cellarId,
      orElse: () => {},
    );

    if (item.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final transactions = await _db.getTransactionsForCellar(widget.cellarId);
    final wineId = item['wineId'] as int?;

    List<Map<String, dynamic>> tastings = [];
    if (wineId != null) {
      final tList = await _db.getTastingsForWine(wineId);
      for (final t in tList) {
        final flavorNames = await _db.getTastingFlavorNames(t.id!);
        tastings.add({
          'tasting': t,
          'flavors': flavorNames,
        });
      }
    }

    setState(() {
      _cellarItem = item;
      _transactions = transactions;
      _relatedTastings = tastings;
      _isLoading = false;
    });
  }

  void _removeFromCellar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('出库/消费'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('确认从酒窖中移除？'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _confirmRemove('consume', 1);
                  },
                  child: const Text('饮用'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _confirmRemove('remove', 1);
                  },
                  child: const Text('移除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(String type, int qty) async {
    final now = DateTime.now();
    // Record transaction
    await _db.insertCellarTransaction(CellarTransaction(
      cellarId: widget.cellarId,
      transType: type,
      quantity: qty,
      transDate: now,
      notes: type == 'consume' ? '饮用消耗' : '手动移除',
    ));

    // Update quantity
    final current = _cellarItem!;
    final currentQty = current['quantity'] as int? ?? 1;
    final newQty = currentQty - qty;

    if (newQty <= 0) {
      await _db.deleteCellar(widget.cellarId);
    } else {
      await _db.updateCellar(Cellar(
        id: widget.cellarId,
        wineId: current['wineId'] as int,
        storageLocationId: current['storageLocationId'] as int,
        quantity: newQty,
        purchasePrice: (current['purchasePrice'] as num?)?.toDouble(),
        entryDate: current['entryDate'] != null ? DateTime.parse(current['entryDate'] as String) : null,
        purchaseDate: current['purchaseDate'] != null ? DateTime.parse(current['purchaseDate'] as String) : null,
        drinkFrom: current['drinkFrom'] as int?,
        drinkTo: current['drinkTo'] as int?,
        notes: current['notes'] as String?,
      ));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('库存已更新')),
      );
      _loadData();
    }
  }

  void _deleteCellar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条库存记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              await _db.deleteCellar(widget.cellarId);
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
        appBar: AppBar(title: Text(widget.wineName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cellarItem == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.wineName)),
        body: const Center(child: Text('库存记录不存在')),
      );
    }

    final item = _cellarItem!;
    final qty = item['quantity'] as int? ?? 0;
    final price = (item['purchasePrice'] as num?)?.toDouble();
    final location = item['locationName'] as String? ?? '未设置';
    final drinkFrom = item['drinkFrom'] as int?;
    final drinkTo = item['drinkTo'] as int?;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wineName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteCellar,
            tooltip: '删除',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 酒款信息
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.wineRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_bar, color: AppTheme.wineRed, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.wineName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (item['wineWinery'] != null)
                        Text(item['wineWinery'] as String, style: const TextStyle(color: AppTheme.textSecondary)),
                      if (item['wineVintage'] != null)
                        Text('年份: ${item['wineVintage']}', style: const TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 库存卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statColumn('数量', '$qty 瓶'),
                        _statColumn('单价', price != null ? '¥${price.toStringAsFixed(0)}' : '-'),
                        _statColumn('总价', price != null ? '¥${(qty * price).toStringAsFixed(0)}' : '-'),
                      ],
                    ),
                    const Divider(height: 24),
                    _infoItem('存储位置', location),
                    if (drinkFrom != null || drinkTo != null)
                      _infoItem('饮用窗口', '${drinkFrom ?? "?"} - ${drinkTo ?? "?"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _removeFromCellar,
                    icon: const Icon(Icons.remove_shopping_cart),
                    label: const Text('出库/消费'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 变动日志
            const Text('变动日志', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无变动记录', style: TextStyle(color: AppTheme.textSecondary)),
              )
            else
              ..._transactions.map((t) => ListTile(
                dense: true,
                leading: Icon(
                  t.transType == 'add' ? Icons.add_circle : t.transType == 'consume' ? Icons.wine_bar : Icons.remove_circle,
                  color: t.transType == 'add' ? Colors.green : t.transType == 'consume' ? Colors.orange : Colors.red,
                  size: 20,
                ),
                title: Text(
                  t.transType == 'add' ? '入库' : t.transType == 'consume' ? '饮用' : '移除',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  'x${t.quantity} · ${t.transDate != null ? '${t.transDate!.year}-${t.transDate!.month.toString().padLeft(2, '0')}-${t.transDate!.day.toString().padLeft(2, '0')}' : ''}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: t.notes != null ? Text(t.notes!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)) : null,
              )),

            // 关联品鉴记录
            if (_relatedTastings.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('关联品鉴', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._relatedTastings.map((t) {
                final tasting = t['tasting'];
                final flavors = t['flavors'] as List<dynamic>? ?? [];
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    title: Text(
                      '${tasting.drinkingDate != null ? "${tasting.drinkingDate!.year}-${tasting.drinkingDate!.month.toString().padLeft(2, '0')}-${tasting.drinkingDate!.day.toString().padLeft(2, '0')}" : "日期未记录"}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      '评分: ${tasting.score100 ?? "-"}/100',
                      style: const TextStyle(fontSize: 13, color: AppTheme.wineRed),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
