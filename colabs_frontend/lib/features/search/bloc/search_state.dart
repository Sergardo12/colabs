import 'package:equatable/equatable.dart';
import '../models/colab_search_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<ColabSearchModel> results;
  final bool                   hasMore;
  final int                    currentPage;
  final String?                query;

  const SearchSuccess({
    required this.results,
    required this.hasMore,
    required this.currentPage,
    this.query,
  });

  @override
  List<Object?> get props => [results, hasMore, currentPage, query];
}

class SearchLoadingMore extends SearchSuccess {
  const SearchLoadingMore({
    required super.results,
    required super.hasMore,
    required super.currentPage,
    super.query,
  });
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}