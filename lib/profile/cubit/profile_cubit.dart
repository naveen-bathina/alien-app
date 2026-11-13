// profile_cubit.dart
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/profile/cubit/profile_state.dart';
import 'package:myalien/profile/models/profile_model.dart';
import 'package:myalien/profile/repository/profile_repository.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required ProfileRepository repo})
    : _repo = repo,
      super(ProfileInitial());
  final ProfileRepository _repo;

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const ProfileError('User not authenticated'));
      return;
    }

    emit(ProfileLoading());
    try {
      emit(ProfileLoaded(await _repo.fetchProfile(user.uid)));
    } on Object catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Saves profile. Firebase Storage is optional; if unavailable,
  /// the image is encoded as binary and stored directly in Firestore.
  Future<void> saveProfile({
    required String name,
    required DateTime dob,
    required String gender,
    required String location,
    String? fullName,
    String? displayName,
    String lookingFor = '',
    String bio = '',
    String? tagline,
    String role = 'Earner',
    int? coinsPerHour = 80,
    bool isDiscoveryActive = true,
    bool isLocationFlexible = true,
    ProfileAvailability availability = const ProfileAvailability(),
    String? existingPhotoUrl,
    List<String> existingPhotos = const [],
    File? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const ProfileError('User not authenticated'));
      return;
    }

    emit(const ProfileSaving());

    try {
      var photoUrl = existingPhotoUrl;
      final photos = List<String>.from(existingPhotos);

      if (imageFile != null) {
        try {
          photoUrl = await _repo.uploadProfileImage(
            user.uid,
            imageFile,
            onProgress: (p) {
              emit(ProfileSaving(progress: p));
            },
          );
        } on Object {
          final bytes = await imageFile.readAsBytes();
          photoUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        }

        if (photoUrl != null && !photos.contains(photoUrl)) {
          photos.insert(0, photoUrl);
        }
      } else if (photoUrl != null && !photos.contains(photoUrl)) {
        photos.add(photoUrl);
      }

      final effectiveDisplayName = (displayName?.trim().isNotEmpty ?? false)
          ? displayName!.trim()
          : name.trim();
      final effectiveFullName = (fullName?.trim().isNotEmpty ?? false)
          ? fullName!.trim()
          : name.trim();

      final profile = Profile(
        uid: user.uid,
        name: effectiveDisplayName,
        fullName: effectiveFullName,
        displayName: effectiveDisplayName,
        dob: dob,
        gender: gender,
        location: location.trim(),
        lookingFor: lookingFor,
        bio: bio.trim(),
        tagline: tagline?.trim(),
        photoUrl: photoUrl ?? (photos.isNotEmpty ? photos.first : null),
        photos: photos,
        role: role,
        coinsPerHour: coinsPerHour,
        isDiscoveryActive: isDiscoveryActive,
        isLocationFlexible: isLocationFlexible,
        availability: availability,
      );

      await _repo.saveProfile(profile);

      emit(ProfileSaved());
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        emit(
          const ProfileError(
            'Permission denied while saving profile. '
            'Please verify you are signed in.',
          ),
        );
      } else {
        emit(ProfileError(e.message ?? e.toString()));
      }
    } on Object catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
