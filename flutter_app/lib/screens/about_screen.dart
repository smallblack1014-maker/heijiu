import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于软件'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // APP 图标（使用实际应用图标）
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/app_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 名称
            const Text(
              '黑酒',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // 描述
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '专业的葡萄酒品鉴记录工具',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Wine Journal Pro 是一款专为葡萄酒爱好者设计的品鉴记录应用。'
                      '无论您是WSET学员、葡萄酒专业人士还是热情爱好者，'
                      '都能通过它系统化地记录每一款酒的品鉴体验。',
                      style: TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      '— 供小黑的酒社群品鉴记录使用',
                      style: TextStyle(fontSize: 13, height: 1.4, color: AppTheme.wineRed, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 技术栈
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('技术栈', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 8),
                    _TechItem('框架', 'Flutter'),
                    _TechItem('语言', 'Dart'),
                    _TechItem('数据库', 'SQLite (sqflite)'),
                    _TechItem('图表', 'fl_chart'),
                    _TechItem('状态管理', 'Provider'),
                    _TechItem('文件选择', 'file_picker'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // WSET 声明
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppTheme.wineRed),
                        SizedBox(width: 8),
                        Text('WSET 声明', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '本应用的品鉴评分系统参考了WSET（葡萄酒与烈酒教育基金会）'
                      'Level 3 及以上的系统品鉴方法（SAT），但并非官方评分工具。'
                      '评分结果仅供参考，不构成任何专业评定或认证。',
                      style: TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 版权
            const Text(
              '© 2026 黑酒',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TechItem extends StatelessWidget {
  final String label;
  final String value;

  const _TechItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
