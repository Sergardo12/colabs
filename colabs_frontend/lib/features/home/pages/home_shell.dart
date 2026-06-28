import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'tabs/home_tab.dart';
import 'tabs/colabs_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/favorites_tab.dart';
import 'widgets/bottom_nav_bar.dart';
import '../../../features/profile/pages/widgets/app_drawer.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeTab(),
    ColabsTab(),
    SearchTab(),
    HistoryTab(),
    FavoritesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index:    _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: ColabsBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      drawer: const AppDrawer(),
    );
  }
}