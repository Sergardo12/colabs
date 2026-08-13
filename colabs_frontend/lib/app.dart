import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/bloc/theme/theme_bloc.dart';
import 'core/bloc/theme/theme_state.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

class ColabsApp extends StatelessWidget {
  const ColabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title:                'Colabs',
          debugShowCheckedModeBanner: false,
          theme:                AppTheme.light,
          darkTheme:            AppTheme.dark,
          themeMode:            state.isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute:         AppRouter.splash,
          onGenerateRoute:      AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
