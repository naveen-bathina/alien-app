part of 'discover_cubit.dart';

sealed class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object> get props => [];
}

final class DiscoverInitial extends DiscoverState {
  const DiscoverInitial();

  @override
  List<Object> get props => [];
}

final class DiscoverLoading extends DiscoverState {
  const DiscoverLoading();

  @override
  List<Object> get props => [];
}

final class DiscoverLoaded extends DiscoverState {
  const DiscoverLoaded({required this.items});
  final List<String> items;

  @override
  List<Object> get props => [items];
}

final class DiscoverError extends DiscoverState {
  const DiscoverError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
