import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/colab_search_model.dart';

class ColabCard extends StatelessWidget {
  final ColabSearchModel colab;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onTap;

  const ColabCard({
    super.key,
    required this.colab,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: [
              BoxShadow(
                color: context.colors.textSecondary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: context.colors.primary.withOpacity(0.1),
                backgroundImage: colab.user.imageProfile != null
                    ? NetworkImage(colab.user.imageProfile!)
                    : null,
                child: colab.user.imageProfile == null
                    ? Icon(
                        Icons.person,
                        color: Theme.of(context).iconTheme.color,
                        size: 28,
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
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: AppSizes.fontL,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (colab.occupations.isNotEmpty)
                      Text(
                        colab.occupations.map((o) => o.name).join(' · '),
                        style: TextStyle(
                          color: context.colors.primary,
                          fontSize: AppSizes.fontM,
                        ),
                      ),
                  ],
                ),
              ),

              // Verificado
              if (colab.verificationStatus == 'verified')
                Icon(
                  Icons.verified,
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),

              // Favorito + rating
              Column(
                children: [
                  InkWell(
                    onTap: onToggleFavorite,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.paddingXS),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: context.colors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingXS),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        colab.avgRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: AppSizes.fontS,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
