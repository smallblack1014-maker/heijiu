import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Palate scoring section widget with rating sliders
class PalateSection extends StatelessWidget {
  final double? acidity;
  final double? tannin;
  final double? body;
  final double? balance;
  final double? complexity;
  final double? finishLength;
  final double? texture;
  final double? character;
  final double? alcohol;
  final String scoringMode;
  final String wineType;
  final ValueChanged<double> onAcidityChanged;
  final ValueChanged<double> onTanninChanged;
  final ValueChanged<double> onBodyChanged;
  final ValueChanged<double> onBalanceChanged;
  final ValueChanged<double> onComplexityChanged;
  final ValueChanged<double> onFinishLengthChanged;
  final ValueChanged<double>? onTextureChanged;
  final ValueChanged<double>? onCharacterChanged;
  final ValueChanged<double>? onAlcoholChanged;

  const PalateSection({
    super.key,
    this.acidity,
    this.tannin,
    this.body,
    this.balance,
    this.complexity,
    this.finishLength,
    this.texture,
    this.character,
    this.alcohol,
    required this.scoringMode,
    required this.wineType,
    required this.onAcidityChanged,
    required this.onTanninChanged,
    required this.onBodyChanged,
    required this.onBalanceChanged,
    required this.onComplexityChanged,
    required this.onFinishLengthChanged,
    this.onTextureChanged,
    this.onCharacterChanged,
    this.onAlcoholChanged,
  });

  bool get _isProfessional => scoringMode == 'professional';
  bool get _showTannin => wineType == 'red';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlider(context, label: '酸度', value: acidity, onChanged: onAcidityChanged),
            if (_showTannin)
              _buildSlider(context, label: '单宁', value: tannin, onChanged: onTanninChanged),
            _buildSlider(context, label: '酒体', value: body, onChanged: onBodyChanged),
            _buildSlider(context, label: '平衡感', value: balance, onChanged: onBalanceChanged),
            _buildSlider(context, label: '复杂度', value: complexity, onChanged: onComplexityChanged),
            _buildSlider(context, label: '余味长度', value: finishLength, onChanged: onFinishLengthChanged),
            if (_isProfessional && onTextureChanged != null)
              _buildSlider(context, label: '口感质地', value: texture, onChanged: onTextureChanged!),
            if (_isProfessional && onCharacterChanged != null)
              _buildSlider(context, label: '品种特色', value: character, onChanged: onCharacterChanged!),
            if (_isProfessional && onAlcoholChanged != null)
              _buildSlider(context, label: '酒精感', value: alcohol, onChanged: onAlcoholChanged!),
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
}
