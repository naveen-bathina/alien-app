import 'package:equatable/equatable.dart';
import 'package:myalien/settings/models/notification_item.dart';

enum SettingsFilter { all, unread, matches, hangouts, wallet }

class SettingsState extends Equatable {
  const SettingsState({
    this.notifications = const [],
    this.filter = SettingsFilter.all,
    this.notificationPreferences = const {
      'push': true,
      'matches': true,
      'hangouts': true,
      'wallet': true,
    },
    this.isLoading = false,
  });

  final List<NotificationItem> notifications;
  final SettingsFilter filter;
  final Map<String, bool> notificationPreferences;
  final bool isLoading;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get filteredNotifications {
    switch (filter) {
      case SettingsFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case SettingsFilter.matches:
        return notifications.where((n) => n.type == 'match').toList();
      case SettingsFilter.hangouts:
        return notifications.where((n) => n.type == 'hangout').toList();
      case SettingsFilter.wallet:
        return notifications.where((n) => n.type == 'wallet').toList();
      case SettingsFilter.all:
      default:
        return notifications;
    }
  }

  SettingsState copyWith({
    List<NotificationItem>? notifications,
    SettingsFilter? filter,
    Map<String, bool>? notificationPreferences,
    bool? isLoading,
  }) {
    return SettingsState(
      notifications: notifications ?? this.notifications,
      filter: filter ?? this.filter,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        filter,
        notificationPreferences,
        isLoading,
      ];
}
