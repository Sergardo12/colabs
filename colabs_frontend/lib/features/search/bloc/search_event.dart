import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchColabRequested extends SearchEvent {
  final String? name;
  final String? occupation;

  const SearchColabRequested({
    this.name,
    this.occupation,
  });

  @override
  List<Object?> get props => [name, occupation];
}

class SearchLoadMoreRequested extends SearchEvent {
  const SearchLoadMoreRequested();
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}