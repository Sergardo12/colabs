import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/review_model.dart';

/// Tarjeta de reseña del perfil público de un colaborador.
class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final author = review.author;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical:   AppSizes.paddingS,
      ),
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color:      context.colors.textSecondary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — autor, ocupación y fecha
          Row(
            children: [
              CircleAvatar(
                radius:          20,
                backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                backgroundImage: author?.imageProfile != null
                    ? NetworkImage(author!.imageProfile!)
                    : null,
                child: author?.imageProfile == null
                    ? Icon(
                        Icons.person,
                        color: Theme.of(context).iconTheme.color,
                        size:  20,
                      )
                    : null,
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author != null
                          ? '${author.name} ${author.lastName}'
                          : 'Cliente',
                      style: TextStyle(
                        color:      context.colors.textPrimary,
                        fontSize:   AppSizes.fontM,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (review.occupationName.isNotEmpty)
                      Text(
                        review.occupationName,
                        style: TextStyle(
                          color:    context.colors.primary,
                          fontSize: AppSizes.fontS,
                        ),
                      ),
                  ],
                ),
              ),
              if (review.creationDate.isNotEmpty)
                Text(
                  _formatDate(review.creationDate),
                  style: TextStyle(
                    color:    context.colors.textSecondary,
                    fontSize: AppSizes.fontS,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingM),

          // Rating
          Row(
            children: [
              ...List.generate(5, (index) {
                final filled = index < review.rating;
                return Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: filled
                      ? const Color(0xFFF9A825)
                      : context.colors.textSecondary,
                  size: 18,
                );
              }),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                review.rating.toString(),
                style: TextStyle(
                  color:    context.colors.textSecondary,
                  fontSize: AppSizes.fontM,
                ),
              ),
            ],
          ),

          // Comentario
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingS),
            Text(
              review.comment!,
              style: TextStyle(
                color:    context.colors.textPrimary,
                fontSize: AppSizes.fontM,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final d = DateTime.parse(date);
    return '${d.day}/${d.month}/${d.year}';
  }
}
