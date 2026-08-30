import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Text(
          'Notificaciones',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: AppSizes.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Próximamente',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: AppSizes.fontL,
          ),
        ),
      ),
    );
  }
}
