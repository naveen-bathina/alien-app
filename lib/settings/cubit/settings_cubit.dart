import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/settings/cubit/settings_state.dart';
import 'package:myalien/settings/models/notification_item.dart';
import 'package:myalien/settings/repository/notification_repository.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    NotificationRepository? repository,
    FirebaseAuth? auth,
  })  : _repo = repository ?? NotificationRepository.instance,
        _auth = auth,
        super(const SettingsState()) {
    _init();
  }

  final NotificationRepository _repo;
  final FirebaseAuth? _auth;
  StreamSubscription<List<NotificationItem>>? _subscription;

  String get _currentUserId {
    try {
      final user = _auth?.currentUser ?? FirebaseAuth.instance.currentUser;
      return user?.uid ?? 'current_user';
    } on Object {
      return 'current_user';
    }
  }

  void _init() {
    emit(state.copyWith(isLoading: true));
    final currentSettings = _repo.getNotificationSettings();
    emit(state.copyWith(notificationPreferences: currentSettings));

    _subscription = _repo.notificationsStream(_currentUserId).listen(
      (notifications) {
        emit(state.copyWith(
          notifications: notifications,
          isLoading: false,
        ));
      },
    );
  }

  void setFilter(SettingsFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  Future<void> markAsRead(String notificationId) async {
    await _repo.markAsRead(_currentUserId, notificationId);
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead(_currentUserId);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _repo.deleteNotification(_currentUserId, notificationId);
  }

  Future<void> updatePreference(String key, bool value) async {
    final updated = Map<String, bool>.from(state.notificationPreferences);
    updated[key] = value;
    emit(state.copyWith(notificationPreferences: updated));
    await _repo.saveNotificationSettings(_currentUserId, updated);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
