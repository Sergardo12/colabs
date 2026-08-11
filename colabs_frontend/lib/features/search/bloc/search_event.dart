import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchColabRequested extends SearchEvent {
  final String? query;

  const SearchColabRequested({this.query});

  @override
  List<Object?> get props => [query];
}

class SearchLoadMoreRequested extends SearchEvent {
  const SearchLoadMoreRequested();
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}