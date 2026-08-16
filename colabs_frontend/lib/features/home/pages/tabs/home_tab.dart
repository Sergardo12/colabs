import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/routes/app_router.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import '../../../chat/bloc/chat_bloc.dart';
import '../../../chat/bloc/chat_state.dart';
import '../widgets/post_card.dart';
import '../widgets/occupation_carousel.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const FeedLoadRequested());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeBloc>().add(const FeedLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _HomeHeader(),

          // Contenido scrolleable
          Expanded(
            child: BlocListener<ChatBloc, ChatState>(
              listenWhen: (previous, current) =>
                  current is ConversationCreated && previous is! ConversationCreated,
              listener: (context, state) {
                if (state is ConversationCreated && context.mounted) {
                  Navigator.pushNamed(
                    context,
                    AppRouter.chat,
                    arguments: {
                      'conversation': state.conversation,
                      'post':         state.post,
                    },
                  );
                }
              },
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.colors.primary,
                      ),
                    );
                  }

                  if (state is HomeError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: context.colors.error,
                            size: 48,
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingM),
                          ElevatedButton(
                            onPressed: () => context.read<HomeBloc>().add(
                              const FeedLoadRequested(),
                            ),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is HomeSuccess) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        bottom: AppSizes.paddingXL,
                      ),
                      itemCount: state.posts.length + 2,
                      itemBuilder: (context, index) {
                        // Carrusel de ocupaciones
                        if (index == 0) {
                          return const OccupationCarousel();
                        }

                        // Posts
                        if (index <= state.posts.length) {
                          return PostCard(post: state.posts[index - 1]);
                        }

                        // Loader de infinite scroll
                        if (state is HomeLoadingMore) {
                          return Padding(
                            padding: const EdgeInsets.all(AppSizes.paddingL),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: context.colors.primary,
                              ),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      color: context.colors.surface,
      child: Row(
        children: [
          // Avatar del usuario
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: context.colors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: Theme.of(context).iconTheme.color,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),

          // Banner convertirse en colaborador
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
              child: Text(
                '¿Deseas convertirte en colaborador?',
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: AppSizes.fontM,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),

          // Ícono de mensajes
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.conversations),
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ],
      ),
    );
  }
}
