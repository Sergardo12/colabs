import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../favorites/bloc/favorites_bloc.dart';
import '../../favorites/bloc/favorites_event.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import 'tabs/home_tab.dart';
import 'tabs/colabs_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/favorites_tab.dart';
import 'widgets/bottom_nav_bar.dart';
import '../../../features/profile/pages/widgets/app_drawer.dart';
import '../../../core/routes/app_router.dart';

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
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
    context.read<FavoritesBloc>().add(const FavoritesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: IndexedStack(
        index:    _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: ColabsBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushNamed(context, AppRouter.requestMap);
            return;
          }
          setState(() => _currentIndex = index);

          // Re-sincroniza favoritos con el servidor cada vez que se abre el tab
          if (index == 4) {
            context
                .read<FavoritesBloc>()
                .add(const FavoritesLoadRequested());
          }
        },
      ),
      drawer: const AppDrawer(),
    );
  }
}