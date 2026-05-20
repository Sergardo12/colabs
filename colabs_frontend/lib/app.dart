import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

class ColabsApp extends StatelessWidget {
  const ColabsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:                'Colabs',
      debugShowCheckedModeBanner: false,
      theme:                AppTheme.light,
      initialRoute:         AppRouter.splash,
      onGenerateRoute:      AppRouter.onGenerateRoute,
    );
  }
}