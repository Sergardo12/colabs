import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/public_colab_model.dart';

/// Encabezado del perfil público: banda con gradiente, botón de retorno,
/// avatar, nombre y ocupaciones del colaborador.
class ProfileHeader extends StatelessWidget {
  /// Ancho del IconButton de retorno para centrar el título "Perfil"
  static const double _backButtonWidth = 48.0;

  final PublicColabModel profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banda con gradiente y botón de retorno
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin:  Alignment.centerLeft,
              end:    Alignment.centerRight,
              colors: [
                Color(0xFF0119DD),
                Color(0xFF0064D8),
                Color(0xFF3697EB),
              ],
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingS,
                vertical:   AppSizes.paddingS,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  const Expanded(
                    child: Text(
                      'Perfil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:      AppColors.white,
                        fontSize:   AppSizes.fontXL,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Compensa el botón de retorno para centrar el título
                  const SizedBox(width: _backButtonWidth),
                ],
              ),
            ),
          ),
        ),

        // Avatar, nombre y ocupaciones
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Row(
            children: [
              CircleAvatar(
                radius:          40,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: profile.imageProfile != null
                    ? NetworkImage(profile.imageProfile!)
                    : null,
                child: profile.imageProfile == null
                    ? const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size:  40,
                      )
                    : null,
              ),
              const SizedBox(width: AppSizes.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.name} ${profile.lastName}',
                      style: const TextStyle(
                        color:      AppColors.textPrimary,
                        fontSize:   AppSizes.fontL,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (profile.occupations.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.paddingXS),
                      Text(
                        profile.occupations.map((o) => o.name).join(' · '),
                        style: const TextStyle(
                          color:    AppColors.primary,
                          fontSize: AppSizes.fontM,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Botón compartir — placeholder: se implementará
              // en una futura actualización.
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
