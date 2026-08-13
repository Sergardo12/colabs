import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../home/pages/widgets/post_card.dart';
import '../bloc/public_profile_bloc.dart';
import '../bloc/public_profile_event.dart';
import '../bloc/public_profile_state.dart';
import 'widgets/empty_state.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats_selector.dart';
import 'widgets/review_card.dart';

/// Perfil público de un colaborador con selector de secciones
/// (POST | CALIFICACIÓN | LIKES) en una sola pantalla.
class PublicProfilePage extends StatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  /// 0 = POST, 1 = CALIFICACIÓN, 2 = LIKES
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context
        .read<PublicProfileBloc>()
        .add(PublicProfileLoadRequested(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocBuilder<PublicProfileBloc, PublicProfileState>(
        builder: (context, state) {
          if (state is PublicProfileLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            );
          }

          if (state is PublicProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: context.colors.error,
                    size:  48,
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
                    onPressed: () => context
                        .read<PublicProfileBloc>()
                        .add(PublicProfileLoadRequested(userId: widget.userId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is PublicProfileSuccess) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeader(profile: state.profile),
                ),
                SliverToBoxAdapter(
                  child: ProfileStatsSelector(
                    stats:         state.stats,
                    selectedIndex: _selectedTab,
                    onSelected:    (index) =>
                        setState(() => _selectedTab = index),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildTabContent(state),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTabContent(PublicProfileSuccess state) {
    // POST (0) y LIKES (2) muestran las publicaciones del colaborador
    if (_selectedTab == 0 || _selectedTab == 2) {
      return ListView(
        key: ValueKey('posts-$_selectedTab'),
        shrinkWrap:     true,
        physics:        const NeverScrollableScrollPhysics(),
        padding:        const EdgeInsets.only(
          top:    AppSizes.paddingS,
          bottom: AppSizes.paddingXL,
        ),
        children: state.posts.isEmpty
            ? const [
                EmptyState(
                  icon:        Icons.post_add,
                  title:       'No hay publicaciones',
                  buttonLabel: 'Crear Post',
                ),
              ]
            : state.posts.map((post) => PostCard(post: post)).toList(),
      );
    }

    return ListView(
      key:         const ValueKey('reviews'),
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      padding:     const EdgeInsets.only(
        top:    AppSizes.paddingS,
        bottom: AppSizes.paddingXL,
      ),
      children: state.reviews.isEmpty
          ? const [
              EmptyState(
                icon:  Icons.rate_review_outlined,
                title: 'No hay reseñas',
              ),
            ]
          : state.reviews.map((review) => ReviewCard(review: review)).toList(),
    );
  }
}
