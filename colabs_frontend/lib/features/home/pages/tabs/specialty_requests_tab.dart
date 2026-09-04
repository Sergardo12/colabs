import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class SpecialtyRequestsTab extends StatelessWidget {
  const SpecialtyRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Text(
          'Solicitudes según tu especialidad',
          style: TextStyle(
            color:      context.colors.textPrimary,
            fontSize:   AppSizes.fontXL,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
