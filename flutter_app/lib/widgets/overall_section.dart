import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/wine_type_helper.dart';

/// Overall scoring section widget
class OverallSection extends StatelessWidget {
  final double? typicality;
  final double? enjoyment;
  final double? value;
  final double? agingPotential;
  final double? repurchase;
  final String? agingAdvice;
  final String scoringMode;
  final ValueChanged<double> onTypicalityChanged;
  final ValueChanged<double> onEnjoymentChanged;
  final ValueChanged<double> onValueChanged;
  final ValueChanged<double> onAgingChanged;
  final ValueChanged<double> onRepurchaseChanged;
  final ValueChanged<String?>? onAgingAdviceChanged;

  const OverallSection({
    super.key,
    this.typicality,
    this.enjoyment,
    this.value,
    this.agingPotential,
    this.repurchase,
    this.agingAdvice,
    required this.scoringMode,
    required this.onTypicalityChanged,
    required this.onEnjoymentChanged,
    required this.onValueChanged,
    required this.onAgingChanged,
    required this.onRepurchaseChanged,
    this.onAgingAdviceChanged,
  });

  bool get _isProfessional => scoringMode == 'professional';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlider(context, label: '典型性', value: typicality, onChanged: onTypicalityChanged),
            _buildSlider(context, label: '享受程度', value: enjoyment, onChanged: onEnjoymentChanged),
            _buildSlider(context, label: '性价比', value: value, onChanged: onValueChanged),
            _buildSlider(context, label: '陈年潜力', value: agingPotential, onChanged: onAgingChanged),
            _buildSlider(context, label: '回购意愿', value: repurchase, onChanged: onRepurchaseChanged),
            if (_isProfessional && onAgingAdviceChanged != null) ...[
              const SizedBox(height: 8),
              _buildDropdown(
                label: '陈年建议',
                value: agingAdvice,
                options: WineTypeHelper.getAgingAdviceOptions(),
                onChanged: onAgingAdviceChanged!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context, {
    required String label,
    required double? value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppTheme.wineRed,
                inactiveTrackColor: AppTheme.wineRed.withValues(alpha: 0.2),
                thumbColor: AppTheme.wineRed,
                overlayColor: AppTheme.wineRed.withValues(alpha: 0.1),
                valueIndicatorColor: AppTheme.wineRed,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
              ),
              child: Slider(
                value: (value ?? 0),
                min: 0, max: 10, divisions: 10,
                label: (value ?? 0).toStringAsFixed(0),
                onChanged: (v) => onChanged(v),
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              width: 36, height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (value ?? 0) > 0 ? AppTheme.wineRed.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                (value ?? 0).toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold,
                  color: (value ?? 0) > 0 ? AppTheme.wineRed : Colors.grey,
                ),
              ),
            ),
          ),
        ],
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
