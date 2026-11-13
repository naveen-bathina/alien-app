// profile_state.dart
import 'package:equatable/equatable.dart';
import 'package:myalien/profile/models/profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);

  final Profile? profile;

  @override
  List<Object?> get props => [profile];
}

class ProfileSaving extends ProfileState {
  // 0.0 - 1.0 for image upload
  const ProfileSaving({this.progress = 0.0});
  final double progress;
  @override
  List<Object?> get props => [progress];
}

class ProfileSaved extends ProfileState {}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
