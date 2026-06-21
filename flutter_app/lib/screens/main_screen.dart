import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'tasting_screen.dart';
import 'wine_list_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> _screens = [
    const TastingScreen(),
    const WineListScreen(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          body: _screens[appState.currentTab],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: appState.currentTab,
            onTap: appState.setTab,
            selectedItemColor: AppTheme.wineRed,
            unselectedItemColor: AppTheme.textSecondary,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.edit_note),
                label: '品鉴',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wine_bar),
                label: '酒款',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: '统计',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          ),
        );
      },
    );
  }
}
