import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/matches/models/match_entry.dart';
import 'package:myalien/matches/repository/matches_repository.dart';

enum MatchesStatus { initial, loading, loaded, error }

class MatchesState extends Equatable {
  const MatchesState({
    this.status = MatchesStatus.initial,
    this.selectedFilter = MatchFilter.all,
    this.searchQuery = '',
    this.entries = const [],
    this.errorMessage,
  });

  final MatchesStatus status;
  final MatchFilter selectedFilter;
  final String searchQuery;
  final List<MatchEntry> entries;
  final String? errorMessage;

  List<MatchEntry> get mutuallyLikedMatches => entries
      .where((e) => e.relation == MatchRelationType.mutuallyLiked)
      .toList();

  List<MatchEntry> get mutuallySuperlikedMatches => entries
      .where((e) => e.relation == MatchRelationType.mutuallySuperliked)
      .toList();

  List<MatchEntry> get likedYouMatches => entries
      .where((e) => e.relation == MatchRelationType.receivedLike)
      .toList();

  List<MatchEntry> get superlikedYouMatches => entries
      .where((e) => e.relation == MatchRelationType.receivedSuperlike)
      .toList();

  List<MatchEntry> get youLikedMatches =>
      entries.where((e) => e.relation == MatchRelationType.sentLike).toList();

  List<MatchEntry> get youSuperlikedMatches => entries
      .where((e) => e.relation == MatchRelationType.sentSuperlike)
      .toList();

  int get mutuallyLikedCount => mutuallyLikedMatches.length;
  int get mutuallySuperlikedCount => mutuallySuperlikedMatches.length;
  int get likedYouCount => likedYouMatches.length;
  int get superlikedYouCount => superlikedYouMatches.length;
  int get youLikedCount => youLikedMatches.length;
  int get youSuperlikedCount => youSuperlikedMatches.length;

  List<MatchEntry> get visibleEntries {
    List<MatchEntry> list;
    switch (selectedFilter) {
      case MatchFilter.all:
        list = entries;
      case MatchFilter.mutuallyLiked:
        list = mutuallyLikedMatches;
      case MatchFilter.mutuallySuperliked:
        list = mutuallySuperlikedMatches;
      case MatchFilter.likedYou:
        list = likedYouMatches;
      case MatchFilter.superlikedYou:
        list = superlikedYouMatches;
      case MatchFilter.youLiked:
        list = youLikedMatches;
      case MatchFilter.youSuperliked:
        list = youSuperlikedMatches;
    }

    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return list;

    return list.where((e) {
      final p = e.profile;
      final nameMatches = p.name.toLowerCase().contains(query);
      final locationMatches = p.location.toLowerCase().contains(query);
      final taglineMatches = p.tagline?.toLowerCase().contains(query) ?? false;
      return nameMatches || locationMatches || taglineMatches;
    }).toList();
  }

  MatchesState copyWith({
    MatchesStatus? status,
    MatchFilter? selectedFilter,
    String? searchQuery,
    List<MatchEntry>? entries,
    String? errorMessage,
  }) {
    return MatchesState(
      status: status ?? this.status,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      entries: entries ?? this.entries,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedFilter,
    searchQuery,
    entries,
    errorMessage,
  ];
}

class MatchesCubit extends Cubit<MatchesState> {
  MatchesCubit({MatchesRepository? repository})
    : _repo = repository ?? MatchesRepository.instance,
      super(const MatchesState()) {
    _init();
  }

  final MatchesRepository _repo;
  StreamSubscription<List<MatchEntry>>? _subscription;

  void _init() {
    emit(state.copyWith(status: MatchesStatus.loading));
    _subscription = _repo.matchesStream.listen(
      (entries) {
        emit(
          state.copyWith(
            status: MatchesStatus.loaded,
            entries: entries,
          ),
        );
      },
      onError: (Object err) {
        emit(
          state.copyWith(
            status: MatchesStatus.error,
            errorMessage: err.toString(),
          ),
        );
      },
    );
  }

  void selectFilter(MatchFilter filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> likeBack(Profile profile) async {
    await _repo.likeBack(profile);
  }

  Future<void> superlikeBack(Profile profile) async {
    await _repo.superlikeBack(profile);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
