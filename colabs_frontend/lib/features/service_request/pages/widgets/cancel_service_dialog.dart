import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// PopUp de advertencia antes de cancelar un servicio aceptado.
/// Devuelve `true` si el usuario confirma y `false`/`null` si elige "No".
Future<bool> showCancelServiceDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: dialogContext.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      title: Text(
        '¿Estás seguro de cancelar el servicio?',
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
            backgroundColor: dialogContext.colors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sí'),
        ),
      ],
    ),
  );

  return result ?? false;
}
