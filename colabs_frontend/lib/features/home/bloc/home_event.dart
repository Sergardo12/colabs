import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends HomeEvent {
  const FeedLoadRequested();
}

class FeedLoadMoreRequested extends HomeEvent {
  const FeedLoadMoreRequested();
}