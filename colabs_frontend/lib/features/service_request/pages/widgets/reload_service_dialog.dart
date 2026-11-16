import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// PopUp de confirmación antes de volver a solicitar un servicio cancelado.
/// Devuelve `true` si el usuario confirma y `false`/`null` si elige "No".
Future<bool> showReloadServiceDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: dialogContext.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      title: Text(
        '¿Deseas solicitar el mismo servicio?',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: dialogContext.colors.textPrimary,
          fontSize: AppSizes.fontL,
          fontWeight: FontWeight.bold,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'No',
            style: TextStyle(color: dialogContext.colors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: dialogContext.colors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sí'),
        ),
      ],
    ),
  );

  return result ?? false;
}
