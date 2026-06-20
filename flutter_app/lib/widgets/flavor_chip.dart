import 'package:flutter/material.dart';
import '../models/flavor.dart';
import '../theme/app_theme.dart';

class FlavorChipBuilder extends StatelessWidget {
  final List<Flavor> flavors;
  final List<int> selectedIds;
  final ValueChanged<List<int>> onSelectionChanged;
  final String searchQuery;
  final VoidCallback? onAddCustom;

  const FlavorChipBuilder({
    super.key,
    required this.flavors,
    required this.selectedIds,
    required this.onSelectionChanged,
    this.searchQuery = '',
    this.onAddCustom,
  });

  @override
  Widget build(BuildContext context) {
    // 按分类分组
    final grouped = <String, List<Flavor>>{};
    for (final f in flavors) {
      if (searchQuery.isNotEmpty &&
          !f.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        continue;
      }
      grouped.putIfAbsent(f.category, () => []).add(f);
    }

    if (grouped.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('未找到匹配的风味词', style: TextStyle(color: Colors.grey)),
            if (onAddCustom != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onAddCustom,
                icon: const Icon(Icons.add),
                label: const Text('自定义新增'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...grouped.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: entry.value.map((flavor) {
                    final isSelected = selectedIds.contains(flavor.id);
                    return ChoiceChip(
                      label: Text(
                        flavor.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.wineRed,
                      backgroundColor: Colors.grey[100],
                      onSelected: (selected) {
                        final newSelection = List<int>.from(selectedIds);
                        if (selected) {
                          if (flavor.id != null) {
                            newSelection.add(flavor.id!);
                          }
                        } else {
                          newSelection.remove(flavor.id);
                        }
                        onSelectionChanged(newSelection);
                      },
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
        if (onAddCustom != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton.icon(
              onPressed: onAddCustom,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('自定义新增风味词'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.wineRed),
            ),
          ),
      ],
    );
  }
}
