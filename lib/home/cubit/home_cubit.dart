import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/discover/models/discovery_filters.dart';
import 'package:myalien/home/cubit/home_state.dart';
import 'package:myalien/home/models/profile_model.dart';
import 'package:myalien/home/repository/home_profile_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required HomeProfileRepository repo})
    : _repo = repo,
      super(const HomeState());
  final HomeProfileRepository _repo;
  StreamSubscription<List<Profile>>? _sub;

  void loadProfiles() {
    emit(state.copyWith(status: HomeStatus.loading));
    _sub?.cancel();
    _sub = _repo.streamCandidates().listen(
      (profiles) {
        final filtered = filterProfiles(profiles, state.filters);
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            allProfiles: profiles,
            profiles: filtered,
            index: 0,
          ),
        );
      },
      onError: (Object e) {
        emit(
          state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
        );
      },
    );
  }

  void applyFilters(DiscoveryFilters filters) {
    final filtered = filterProfiles(state.allProfiles, filters);
    emit(
      state.copyWith(
        filters: filters,
        profiles: filtered,
        index: 0,
        status: HomeStatus.loaded,
      ),
    );
  }

  void resetFilters() {
    applyFilters(DiscoveryFilters.defaultFilters());
  }

  void toggleRole(String role) {
    final newRole = state.filters.role == role ? 'All' : role;
    applyFilters(state.filters.copyWith(role: newRole));
  }

  void toggleNearby() {
    applyFilters(
      state.filters.copyWith(
        nearbyOnly: !state.filters.nearbyOnly,
      ),
    );
  }

  void toggleAvailableToday() {
    applyFilters(
      state.filters.copyWith(
        availableTodayOnly: !state.filters.availableTodayOnly,
      ),
    );
  }

  void toggleVerifiedOnly() {
    applyFilters(
      state.filters.copyWith(
        verifiedOnly: !state.filters.verifiedOnly,
      ),
    );
  }

  static List<Profile> filterProfiles(
    List<Profile> candidates,
    DiscoveryFilters filters,
  ) {
    final result = candidates.where((p) {
      // 1. Role filter
      if (filters.role == 'Earner' && !p.isEarner) return false;
      if (filters.role == 'Sponsor' && !p.isSponsor) return false;

      // 2. Gender filter
      if (filters.genders.isNotEmpty) {
        final matchesGender = filters.genders.any(
          (g) => g.toLowerCase() == p.gender.toLowerCase(),
        );
        if (!matchesGender) return false;
      }

      // 3. Age filter
      final profileAge = p.age;
      if (profileAge != null) {
        if (profileAge < filters.minAge || profileAge > filters.maxAge) {
          return false;
        }
      }

      // 4. GPS Nearby / City filter
      if (filters.nearbyOnly) {
        // User's current location detected in Jubilee Hills / Hyderabad
        final isNearby = p.location.toLowerCase().contains('hyderabad') ||
            p.location.toLowerCase().contains('jubilee') ||
            p.location.toLowerCase().contains('banjara') ||
            p.location.toLowerCase().contains('gachibowli') ||
            p.location.toLowerCase().contains('madhapur') ||
            p.location.toLowerCase().contains('nearby');
        if (!isNearby) return false;
      } else if (filters.city != 'All Cities') {
        if (!p.location.toLowerCase().contains(filters.city.toLowerCase())) {
          return false;
        }
      }

      // 5. Intentions / Looking For
      if (filters.intentions.isNotEmpty) {
        final pIntentions = (p.lookingFor ?? '').toLowerCase();
        final matchesIntention = filters.intentions.any(
          (i) => pIntentions.contains(i.toLowerCase()),
        );
        if (!matchesIntention) return false;
      }

      // 6. Coins per hour budget (Earners only)
      if (p.isEarner && p.coinsPerHour != null) {
        if (p.coinsPerHour! < filters.minCoinsPerHour ||
            p.coinsPerHour! > filters.maxCoinsPerHour) {
          return false;
        }
      }

      // 7. Availability toggles
      if (filters.availableTodayOnly && !p.availability.isAvailableToday) {
        return false;
      }

      // 8. Verified profiles only
      if (filters.verifiedOnly && !p.isVerified) {
        return false;
      }

      // 9. Flexible location only
      if (filters.flexibleLocationOnly && !p.isLocationFlexible) {
        return false;
      }

      return true;
    }).toList();

    // 10. Sorting
    switch (filters.sortBy) {
      case 'Highest Rated':
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Rate: Low to High':
        result.sort((a, b) => (a.coinsPerHour ?? 999999).compareTo(
              b.coinsPerHour ?? 999999,
            ));
      case 'Rate: High to Low':
        result.sort((a, b) => (b.coinsPerHour ?? -1).compareTo(
              a.coinsPerHour ?? -1,
            ));
      case 'Recommended':
      default:
        // Keep natural discovery order
        break;
    }

    return result;
  }

  Future<void> takeAction(String targetUid, String actionType) async {
    emit(state.copyWith(status: HomeStatus.actionInProgress));
    try {
      await _repo.recordAction(targetUid: targetUid, type: actionType);
      nextProfile();
    } on Exception catch (e) {
      emit(
        state.copyWith(status: HomeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void nextProfile() {
    if (state.profiles.isEmpty) return;
    final nextIndex = (state.index + 1) % state.profiles.length;
    emit(state.copyWith(status: HomeStatus.loaded, index: nextIndex));
  }

  void previousProfile() {
    if (state.profiles.isEmpty) return;
    final prevIndex =
        (state.index - 1 + state.profiles.length) % state.profiles.length;
    emit(state.copyWith(status: HomeStatus.loaded, index: prevIndex));
  }

  void goToProfile() {
    emit(NavigateToProfileScreen());
  }

  void goToDiscover() {
    emit(NavigateToDiscoverScreen());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
