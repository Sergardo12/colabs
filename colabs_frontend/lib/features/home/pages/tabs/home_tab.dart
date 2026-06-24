import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import '../../models/post_model.dart';
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
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is HomeError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size:  48,
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        ElevatedButton(
                          onPressed: () => context
                              .read<HomeBloc>()
                              .add(const FeedLoadRequested()),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is HomeSuccess) {
                  return ListView.builder(
                    controller:  _scrollController,
                    padding:     const EdgeInsets.only(
                      bottom: AppSizes.paddingXL,
                    ),
                    itemCount:   state.posts.length + 2,
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
                        return const Padding(
                          padding: EdgeInsets.all(AppSizes.paddingL),
                          child:   Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
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
        vertical:   AppSizes.paddingM,
      ),
      color: AppColors.white,
      child: Row(
        children: [
          // Avatar del usuario
          CircleAvatar(
            radius:          20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size:  20,
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),

          // Banner convertirse en colaborador
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical:   AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color:        AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
              child: const Text(
                '¿Deseas convertirte en colaborador?',
                style: TextStyle(
                  color:    AppColors.primary,
                  fontSize: AppSizes.fontM,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),

          // Ícono de mensajes
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}