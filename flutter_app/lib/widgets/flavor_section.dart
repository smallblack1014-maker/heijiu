import 'dart:async';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/flavor.dart';
import '../theme/app_theme.dart';
import '../widgets/flavor_chip.dart';

/// Flavor selection section with search, category filter, and custom add
class FlavorSection extends StatefulWidget {
  final String wineType;
  final List<String> selectedFlavors;
  final ValueChanged<List<String>> onFlavorsChanged;

  const FlavorSection({
    super.key,
    required this.wineType,
    required this.selectedFlavors,
    required this.onFlavorsChanged,
  });

  @override
  State<FlavorSection> createState() => _FlavorSectionState();
}

class _FlavorSectionState extends State<FlavorSection> {
  final TextEditingController _newFlavorController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _flavorSearch = '';
  String _flavorCategory = '全部';
  List<Flavor> _flavors = [];
  final List<String> _flavorCategories = ['全部', '水果', '花香', '香料', '植物', '橡木'];

  @override
  void initState() {
    super.initState();
    _loadFlavors();
  }

  @override
  void dispose() {
    _newFlavorController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFlavors() async {
    final db = DatabaseHelper();
    final flavors = await db.getFlavorsForWineType(widget.wineType);
    if (mounted) {
      setState(() => _flavors = flavors);
    }
  }

  List<int> get _selectedFlavorIds {
    return _flavors
        .where((f) => f.id != null && widget.selectedFlavors.contains(f.name))
        .map((f) => f.id!)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索风味词...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _flavorSearch = v),
            ),
            const SizedBox(height: 8),
            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _flavorCategories.map((cat) {
                  final isSelected = _flavorCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : null)),
                      selected: isSelected,
                      selectedColor: AppTheme.wineRed,
                      onSelected: (v) => setState(() => _flavorCategory = cat),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Flavor chips
            FlavorChipBuilder(
              flavors: _flavors.where((f) {
                if (_flavorCategory != '全部' && f.category != _flavorCategory) return false;
                if (_flavorSearch.isNotEmpty &&
                    !f.name.toLowerCase().contains(_flavorSearch.toLowerCase())) return false;
                return true;
              }).toList(),
              selectedIds: _selectedFlavorIds,
              onSelectionChanged: (ids) {
                final updated = _flavors
                    .where((f) => f.id != null && ids.contains(f.id))
                    .map((f) => f.name)
                    .toList();
                widget.onFlavorsChanged(updated);
              },
              searchQuery: _flavorSearch,
              onAddCustom: _showAddCustomFlavorDialog,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCustomFlavorDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('自定义风味词'),
        content: TextField(
          controller: _newFlavorController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入风味词名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_newFlavorController.text.trim().isNotEmpty) {
                Navigator.pop(ctx, _newFlavorController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.wineRed),
            child: const Text('添加', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final db = DatabaseHelper();
        final newFlavor = Flavor(
          name: result,
          category: _flavorCategory == '全部' ? '水果' : _flavorCategory,
          subcategory: null,
          wineType: widget.wineType,
          isBuiltin: 0,
          createdAt: DateTime.now(),
        );
        final id = await db.insertFlavor(newFlavor);
        if (mounted) {
          setState(() {
            _flavors.add(Flavor(
              id: id,
              name: result,
              category: _flavorCategory == '全部' ? '水果' : _flavorCategory,
              wineType: widget.wineType,
              isBuiltin: 0,
              createdAt: DateTime.now(),
            ));
            widget.onFlavorsChanged([...widget.selectedFlavors, result]);
            _newFlavorController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加风味词失败: $e')),
          );
        }
      }
    }
  }
}
