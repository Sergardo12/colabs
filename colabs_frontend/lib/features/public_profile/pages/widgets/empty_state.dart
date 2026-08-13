import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Estado vacío para las secciones del perfil público.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String?  subtitle;
  final String?  buttonLabel;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical:   AppSizes.paddingXXL,
      ),
      child: Column(
        children: [
          Icon(icon, color: context.colors.textSecondary, size: 48),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:      context.colors.textPrimary,
              fontSize:   AppSizes.fontL,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSizes.paddingXS),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:    context.colors.textSecondary,
                fontSize: AppSizes.fontM,
              ),
            ),
          ],
          if (buttonLabel != null) ...[
            const SizedBox(height: AppSizes.paddingL),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: ElevatedButton(
                // Placeholder: se conectará a la creación de posts
                // en una futura actualización.
                onPressed: () {},
                child: Text(buttonLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
