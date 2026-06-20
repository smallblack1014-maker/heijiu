import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/weight_config.dart';
import '../theme/app_theme.dart';

class WeightSettingScreen extends StatefulWidget {
  const WeightSettingScreen({super.key});

  @override
  State<WeightSettingScreen> createState() => _WeightSettingScreenState();
}

class _WeightSettingScreenState extends State<WeightSettingScreen> {
  late double _aromaWeight;
  late double _palateWeight;
  late double _overallWeight;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _aromaWeight = appState.weightConfig.aromaWeight;
    _palateWeight = appState.weightConfig.palateWeight;
    _overallWeight = appState.weightConfig.overallWeight;
  }

  double get _sum => _aromaWeight + _palateWeight + _overallWeight;
  bool get _isValid => (_sum - 1.0).abs() < 0.001;

  void _save() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('权重总和必须为 100%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final config = WeightConfig(
      aromaWeight: _aromaWeight,
      palateWeight: _palateWeight,
      overallWeight: _overallWeight,
      updatedAt: DateTime.now(),
    );

    context.read<AppState>().updateWeights(config);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('权重已保存，所有品鉴评分已重新计算')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('评分权重设置'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 香气权重
                    _WeightSlider(
                      label: '香气权重',
                      value: _aromaWeight,
                      color: Colors.orange,
                      onChanged: (v) => setState(() => _aromaWeight = v),
                    ),
                    const SizedBox(height: 12),

                    // 口感权重
                    _WeightSlider(
                      label: '口感权重',
                      value: _palateWeight,
                      color: AppTheme.wineRed,
                      onChanged: (v) => setState(() => _palateWeight = v),
                    ),
                    const SizedBox(height: 12),

                    // 综合权重
                    _WeightSlider(
                      label: '综合权重',
                      value: _overallWeight,
                      color: Colors.blue,
                      onChanged: (v) => setState(() => _overallWeight = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 总和显示
            Card(
              color: _isValid ? null : Colors.red.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '权重总和',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(_sum * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isValid ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_isValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠ 权重总和必须等于 100% （当前 ${(_sum * 100).toStringAsFixed(0)}%）',
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),

            // 说明
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('说明', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 8),
                    Text(
                      '• 香气权重（${'\u0025'}）：影响最终得分的香气部分\n'
                      '• 口感权重（${'\u0025'}）：影响最终得分的口感部分\n'
                      '• 综合权重（${'\u0025'}）：影响最终得分的综合评价部分\n'
                      '\n'
                      '每个权重范围 10% - 60%，总和必须为 100%。\n'
                      '保存后将自动重新计算所有已有品鉴的总分。',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightSlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const _WeightSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: value,
              min: 0.10,
              max: 0.60,
              divisions: 10,
              label: '${(value * 100).toStringAsFixed(0)}%',
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
