import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Aroma scoring section widget with rating sliders
class AromaSection extends StatelessWidget {
  final double? intensity;
  final double? complexity;
  final double? persistence;
  final String scoringMode;
  final ValueChanged<double> onIntensityChanged;
  final ValueChanged<double> onComplexityChanged;
  final ValueChanged<double> onPersistenceChanged;

  const AromaSection({
    super.key,
    this.intensity,
    this.complexity,
    this.persistence,
    required this.scoringMode,
    required this.onIntensityChanged,
    required this.onComplexityChanged,
    required this.onPersistenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlider(context, label: '香气浓度', value: intensity, onChanged: onIntensityChanged),
            _buildSlider(context, label: '香气复杂度', value: complexity, onChanged: onComplexityChanged),
            _buildSlider(context, label: '香气持久度', value: persistence, onChanged: onPersistenceChanged),
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
            width: 100,
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
          _scoreBadge(value),
        ],
      ),
    );
  }

  Widget _scoreBadge(double? value) {
    return GestureDetector(
      onTap: null,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: (value ?? 0) > 0 ? AppTheme.wineRed.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          (value ?? 0).toStringAsFixed(0),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: (value ?? 0) > 0 ? AppTheme.wineRed : Colors.grey,
          ),
        ),
      ),
    );
  }
}
