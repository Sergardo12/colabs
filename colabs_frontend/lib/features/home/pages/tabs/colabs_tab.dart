import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
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

  void _onSearch(String value) {
  context.read<SearchBloc>().add(
    SearchColabRequested(query: value.isEmpty ? null : value),
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
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText:   'Busca a un colaborador...',
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textSecondary,
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

                if (state is SearchSuccess) {
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding:    const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingL,
                    ),
                    itemCount:  state.results.length + 1,
                    itemBuilder: (context, index) {
                      if (index < state.results.length) {
                        return ColabCard(colab: state.results[index]);
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

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}