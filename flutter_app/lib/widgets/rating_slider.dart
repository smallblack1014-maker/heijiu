import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RatingSlider extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const RatingSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
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
                value: value.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: value.toString(),
                onChanged: enabled ? (v) => onChanged(v.round()) : null,
              ),
            ),
          ),
          GestureDetector(
            onTap: enabled
                ? () => _showNumberInput(context)
                : null,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: value > 0 ? AppTheme.wineRed.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: value > 0 ? AppTheme.wineRed : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNumberInput(BuildContext context) {
    final controller = TextEditingController(text: value.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('输入$label分数'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '输入 0-10 的数字',
            suffixText: '/ 10',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 0 && val <= 10) {
                onChanged(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
