import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/colab_search_model.dart';

class ColabCard extends StatelessWidget {
  final ColabSearchModel colab;

  const ColabCard({super.key, required this.colab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color:      AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius:          28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: colab.user.imageProfile != null
                ? NetworkImage(colab.user.imageProfile!)
                : null,
            child: colab.user.imageProfile == null
                ? const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size:  28,
                  )
                : null,
          ),
          const SizedBox(width: AppSizes.paddingM),

          // Nombre y ocupación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${colab.user.name} ${colab.user.lastName}',
                  style: const TextStyle(
                    color:      AppColors.textPrimary,
                    fontSize:   AppSizes.fontL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (colab.occupations.isNotEmpty)
                Text(
                  colab.occupations.map((o) => o.name).join(' · '),
                  style: const TextStyle(
                    color:    AppColors.primary,
                    fontSize: AppSizes.fontM,
                  ),
                ),
              ],
            ),
          ),

          // Verificado
          if (colab.verificationStatus == 'verified')
            const Icon(
              Icons.verified,
              color: AppColors.primary,
              size:  20,
            ),
        ],
      ),
    );
  }
}