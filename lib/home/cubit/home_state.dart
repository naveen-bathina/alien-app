import 'package:equatable/equatable.dart';
import 'package:myalien/discover/models/discovery_filters.dart';
import 'package:myalien/home/models/profile_model.dart';

enum HomeStatus { initial, loading, loaded, actionInProgress, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.allProfiles = const [],
    this.profiles = const [],
    this.filters = const DiscoveryFilters(),
    this.index = 0,
    this.errorMessage,
  });

  final HomeStatus status;
  final List<Profile> allProfiles;
  final List<Profile> profiles;
  final DiscoveryFilters filters;
  final int index;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<Profile>? allProfiles,
    List<Profile>? profiles,
    DiscoveryFilters? filters,
    int? index,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      allProfiles: allProfiles ?? this.allProfiles,
      profiles: profiles ?? this.profiles,
      filters: filters ?? this.filters,
      index: index ?? this.index,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allProfiles,
    profiles,
    filters,
    index,
    errorMessage,
  ];
}

class NavigateToProfileScreen extends HomeState {}

class NavigateToDiscoverScreen extends HomeState {}
