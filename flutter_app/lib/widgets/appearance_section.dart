import 'package:flutter/material.dart';
import '../utils/wine_type_helper.dart';

/// Appearance scoring section widget
class AppearanceSection extends StatelessWidget {
  final String wineType;
  final String? color;
  final String? clarity;
  final String? intensity;
  final String? condition;
  final String? tears;
  final String? bubbleFineness;
  final String? bubblePersistence;
  final ValueChanged<String?> onColorChanged;
  final ValueChanged<String?> onClarityChanged;
  final ValueChanged<String?> onIntensityChanged;
  final ValueChanged<String?> onConditionChanged;
  final ValueChanged<String?>? onTearsChanged;
  final ValueChanged<String?>? onBubbleFinenessChanged;
  final ValueChanged<String?>? onBubblePersistenceChanged;

  const AppearanceSection({
    super.key,
    required this.wineType,
    this.color,
    this.clarity,
    this.intensity,
    this.condition,
    this.tears,
    this.bubbleFineness,
    this.bubblePersistence,
    required this.onColorChanged,
    required this.onClarityChanged,
    required this.onIntensityChanged,
    required this.onConditionChanged,
    this.onTearsChanged,
    this.onBubbleFinenessChanged,
    this.onBubblePersistenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSparkling = wineType == 'sparkling';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(label: '颜色', value: color, options: WineTypeHelper.getColorsForType(wineType), onChanged: onColorChanged),
            _buildDropdown(label: '清澈度', value: clarity, options: WineTypeHelper.getClarityOptions(), onChanged: onClarityChanged),
            _buildDropdown(label: '浓度', value: intensity, options: WineTypeHelper.getIntensityOptions(), onChanged: onIntensityChanged),
            _buildDropdown(label: '状态', value: condition, options: WineTypeHelper.getConditionOptions(), onChanged: onConditionChanged),
            if (!isSparkling && onTearsChanged != null)
              _buildDropdown(label: '挂杯', value: tears, options: WineTypeHelper.getTearsOptions(), onChanged: onTearsChanged!),
            if (isSparkling && onBubbleFinenessChanged != null) ...[
              _buildDropdown(label: '气泡细腻度', value: bubbleFineness, options: WineTypeHelper.getBubbleFinenessOptions(), onChanged: onBubbleFinenessChanged!),
              _buildDropdown(label: '气泡持久度', value: bubblePersistence, options: WineTypeHelper.getBubblePersistenceOptions(), onChanged: onBubblePersistenceChanged!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: options.contains(value) ? value : null,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
