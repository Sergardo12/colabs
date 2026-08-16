import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/post_model.dart';
import '../../../chat/bloc/chat_bloc.dart';
import '../../../chat/bloc/chat_event.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical:   AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color:        context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color:      context.colors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header — avatar, nombre, ocupación y botón consultar
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius:          20,
                  backgroundColor: context.colors.primary.withOpacity(0.1),
                  backgroundImage: post.author.imageProfile != null
                      ? NetworkImage(post.author.imageProfile!)
                      : null,
                  child: post.author.imageProfile == null
                      ? Icon(
                          Icons.person,
                          color: Theme.of(context).iconTheme.color,
                          size:  20,
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
                        '${post.author.name} ${post.author.lastName}',
                        style: TextStyle(
                          color:      context.colors.textPrimary,
                          fontSize:   AppSizes.fontM,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        post.occupation.name,
                        style: TextStyle(
                          color:    context.colors.primary,
                          fontSize: AppSizes.fontS,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón consultar
                OutlinedButton(
                  onPressed: () {
                    context.read<ChatBloc>().add(
                      StartConversationRequested(
                        profileColabId: post.profileColabId,
                        postId:         post.id,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side:    BorderSide(color: context.colors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical:   AppSizes.paddingXS,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                  ),
                  child: Text(
                    'Consultar',
                    style: TextStyle(
                      color:    context.colors.primary,
                      fontSize: AppSizes.fontS,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Imagen del post
          if (post.media.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.network(
                post.media.first,
                width:     double.infinity,
                height:    220,
                fit:       BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color:  context.colors.background,
                  child:  Icon(
                    Icons.image_not_supported_outlined,
                    color: context.colors.textSecondary,
                    size:  48,
                  ),
                ),
              ),
            ),

          // Footer — likes, comentarios, precio
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Acciones y precio
                Row(
                  children: [
                    // Like
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: post.isLiked
                                ? context.colors.error
                                : context.colors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likesCount}',
                            style: TextStyle(
                              color:    context.colors.textSecondary,
                              fontSize: AppSizes.fontS,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingM),

                    // Comentarios
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: context.colors.textSecondary,
                          size:  20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.commentsCount}',
                          style: TextStyle(
                            color:    context.colors.textSecondary,
                            fontSize: AppSizes.fontS,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Precio
                    Text(
                      'S/ ${post.price}',
                      style: TextStyle(
                        color:      context.colors.primary,
                        fontSize:   AppSizes.fontL,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingS),

                // Descripción
                Text(
                  post.description,
                  style: TextStyle(
                    color:    context.colors.textPrimary,
                    fontSize: AppSizes.fontM,
                  ),
                  maxLines:  3,
                  overflow:  TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.paddingXS),

                // Tiempo
                Text(
                  _formatTime(post.createdAt),
                  style: TextStyle(
                    color:    context.colors.textSecondary,
                    fontSize: AppSizes.fontS,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String createdAt) {
    final date     = DateTime.parse(createdAt);
    final now      = DateTime.now();
    final diff     = now.difference(date);

    if (diff.inMinutes < 60)  return 'Hace ${diff.inMinutes} minutos';
    if (diff.inHours < 24)    return 'Hace ${diff.inHours} horas';
    if (diff.inDays < 7)      return 'Hace ${diff.inDays} días';
    return '${date.day}/${date.month}/${date.year}';
  }
}
