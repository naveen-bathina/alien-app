import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/settings/models/notification_item.dart';
import 'package:myalien/settings/repository/notification_repository.dart';

void main() {
  group('NotificationRepository Tests', () {
    late NotificationRepository repo;

    setUp(() {
      repo = NotificationRepository();
    });

    test('streams seeded notifications', () async {
      final stream = repo.notificationsStream('test_user');
      final list = await stream.first;

      expect(list.isNotEmpty, isTrue);
      expect(list.any((n) => n.id == 'notif_welcome'), isTrue);
      expect(list.any((n) => n.id == 'notif_match'), isTrue);
    });

    test('markAsRead updates isRead to true', () async {
      final initial = await repo.notificationsStream('test_user').first;
      final unread = initial.firstWhere((n) => !n.isRead);

      await repo.markAsRead('test_user', unread.id);

      final updated = await repo.notificationsStream('test_user').first;
      final found = updated.firstWhere((n) => n.id == unread.id);
      expect(found.isRead, isTrue);
    });

    test('markAllAsRead marks all notifications as read', () async {
      await repo.markAllAsRead('test_user');

      final updated = await repo.notificationsStream('test_user').first;
      expect(updated.every((n) => n.isRead), isTrue);
    });

    test('deleteNotification removes notification from stream', () async {
      final initial = await repo.notificationsStream('test_user').first;
      final target = initial.first;

      await repo.deleteNotification('test_user', target.id);

      final updated = await repo.notificationsStream('test_user').first;
      expect(updated.any((n) => n.id == target.id), isFalse);
    });

    test('addNotification prepends new notification', () async {
      final newNotif = NotificationItem(
        id: 'new_test_1',
        userId: 'test_user',
        title: 'Test Notification',
        body: 'This is a test notification body',
        timestamp: DateTime.now(),
        type: 'wallet',
      );

      await repo.addNotification(newNotif);

      final updated = await repo.notificationsStream('test_user').first;
      expect(updated.any((n) => n.id == 'new_test_1'), isTrue);
      expect(updated.first.id, 'new_test_1');
    });

    test('saveNotificationSettings updates and returns preferences', () async {
      await repo.saveNotificationSettings('test_user', {
        'push': false,
        'matches': true,
        'hangouts': false,
        'wallet': true,
      });

      final settings = repo.getNotificationSettings();
      expect(settings['push'], isFalse);
      expect(settings['matches'], isTrue);
      expect(settings['hangouts'], isFalse);
    });
  });
}
