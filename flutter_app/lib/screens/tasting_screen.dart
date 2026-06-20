import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tasting_form_screen.dart';

class TastingScreen extends StatelessWidget {
  const TastingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择酒类型'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _TypeCard(
                label: '红葡萄酒',
                subtitle: '赤霞珠、黑皮诺、西拉...',
                color: const Color(0xFF722F37),
                icon: Icons.wine_bar,
                onTap: () => _navigateToForm(context, 'red'),
              ),
              const SizedBox(height: 12),
              _TypeCard(
                label: '白葡萄酒',
                subtitle: '霞多丽、长相思、雷司令...',
                color: const Color(0xFFE8D5A3),
                icon: Icons.wine_bar,
                onTap: () => _navigateToForm(context, 'white'),
              ),
              const SizedBox(height: 12),
              _TypeCard(
                label: '桃红葡萄酒',
                subtitle: '普罗旺斯风格、清爽果味...',
                color: const Color(0xFFF4A6A6),
                icon: Icons.wine_bar,
                onTap: () => _navigateToForm(context, 'rose'),
              ),
              const SizedBox(height: 12),
              _TypeCard(
                label: '起泡酒',
                subtitle: '香槟、卡瓦、普洛赛克...',
                color: const Color(0xFFD4A853),
                icon: Icons.wine_bar,
                onTap: () => _navigateToForm(context, 'sparkling'),
              ),
              const SizedBox(height: 12),
              _TypeCard(
                label: '甜酒',
                subtitle: '贵腐、冰酒、晚收...',
                color: const Color(0xFFD4956A),
                icon: Icons.wine_bar,
                onTap: () => _navigateToForm(context, 'sweet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, String wineType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TastingFormScreen(wineType: wineType),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _TypeCard({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.1);
    final textColor = isDark ? Colors.white : color;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: textColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
