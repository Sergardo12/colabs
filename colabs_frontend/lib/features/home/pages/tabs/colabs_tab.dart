import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../favorites/bloc/favorites_bloc.dart';
import '../../../favorites/bloc/favorites_event.dart';
import '../../../favorites/bloc/favorites_state.dart';
import '../../../search/bloc/search_bloc.dart';
import '../../../search/bloc/search_event.dart';
import '../../../search/bloc/search_state.dart';
import '../../../search/pages/widgets/colab_card.dart';

class ColabsTab extends StatefulWidget {
  const ColabsTab({super.key});

  @override
  State<ColabsTab> createState() => _ColabsTabState();
}

class _ColabsTabState extends State<ColabsTab> {
  final TextEditingController _searchCtrl    = TextEditingController();
  final ScrollController      _scrollCtrl    = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SearchBloc>().add(const SearchColabRequested());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<SearchBloc>().add(const SearchLoadMoreRequested());
    }
  }

  /// Búsqueda en tiempo real mientras se escribe
  void _onSearchChanged(String value) {
    context.read<SearchBloc>().add(SearchQueryChanged(value));
  }

  /// Limpia el texto y restaura la lista completa
  void _onClearSearch() {
    _searchCtrl.clear();
    context.read<SearchBloc>().add(const SearchQueryChanged(''));
  }

  /// Lista de resultados (compartida por SearchSuccess y SearchFiltering)
  Widget _buildResultsList(SearchSuccess state) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding:    const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
      ),
      itemCount:  state.results.length + 1,
      itemBuilder: (context, index) {
        if (index < state.results.length) {
          final colab = state.results[index];
          return BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, favState) {
              final isFavorite = favState is FavoritesLoaded
                  ? favState.isFavorite(colab.id)
                  : false;
              return ColabCard(
                colab:      colab,
                isFavorite: isFavorite,
                onToggleFavorite: () => context
                    .read<FavoritesBloc>()
                    .add(ToggleFavorite(colab.id, colab: colab)),
              );
            },
          );
        }

        if (state is SearchLoadingMore) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child:   Center(
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: TextField(
              controller: _searchCtrl,
              onChanged:  _onSearchChanged,
              decoration: InputDecoration(
                hintText:   'Busca por nombre u ocupación...',
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textSecondary,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchCtrl,
                  builder: (context, value, _) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: context.colors.textSecondary,
                            ),
                            onPressed: _onClearSearch,
                          )
                        : const SizedBox.shrink();
                  },
                ),
                filled:       true,
                fillColor:    context.colors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSizes.paddingM,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  borderSide:   BorderSide(
                    color: context.colors.textSecondary.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          // Resultados
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  );
                }

                if (state is SearchEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: context.colors.textSecondary,
                          size:  48,
                        ),
                        const SizedBox(height: AppSizes.paddingM),
                        Text(
                          'No se encontraron colaboradores para "${state.query}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is SearchError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: TextStyle(color: context.colors.error),
                    ),
                  );
                }

                // Búsqueda en curso — mantiene resultados previos con overlay
                if (state is SearchFiltering) {
                  return Stack(
                    children: [
                      _buildResultsList(state),
                      Positioned(
                        top:    0,
                        left:   0,
                        right:  0,
                        child:  LinearProgressIndicator(
                          color:  context.colors.primary,
                          backgroundColor: context.colors.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }

                if (state is SearchSuccess) {
                  return _buildResultsList(state);
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