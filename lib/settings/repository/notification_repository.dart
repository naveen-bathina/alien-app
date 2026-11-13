import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:myalien/settings/models/notification_item.dart';

class NotificationRepository {
  NotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _fs = firestore,
        _auth = auth {
    _initSeededNotifications();
  }

  static final NotificationRepository instance = NotificationRepository();

  final FirebaseFirestore? _fs;
  final FirebaseAuth? _auth;

  final StreamController<List<NotificationItem>> _localController =
      StreamController<List<NotificationItem>>.broadcast();

  final List<NotificationItem> _inMemoryNotifications = [];
  Map<String, bool> _notificationSettings = {
    'push': true,
    'matches': true,
    'hangouts': true,
    'wallet': true,
  };

  void _initSeededNotifications() {
    final now = DateTime.now();
    _inMemoryNotifications.addAll([
      NotificationItem(
        id: 'notif_welcome',
        userId: 'current',
        title: 'Welcome Alien Bonus! 🪙',
        body: '100 free coins have been credited to your Wallet. Start connecting!',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        type: 'wallet',
        actionRoute: 'wallet',
      ),
      NotificationItem(
        id: 'notif_match',
        userId: 'current',
        title: 'New Mutual Match! ❤️',
        body: 'You and Maya Sharma mutually liked each other. Check out your matches!',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
        type: 'match',
        actionRoute: 'matches',
      ),
      NotificationItem(
        id: 'notif_hangout',
        userId: 'current',
        title: 'Hangout Slot Confirmed ☕',
        body: 'Coffee hangout scheduled for tomorrow at 4:00 PM at Jubilee Hills.',
        timestamp: now.subtract(const Duration(hours: 6)),
        isRead: true,
        type: 'hangout',
        actionRoute: 'hangouts',
      ),
      NotificationItem(
        id: 'notif_safety',
        userId: 'current',
        title: 'Community Safety Reminder 🛡️',
        body: 'Always meet in public places and keep your personal phone number private.',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        type: 'system',
      ),
    ]);
  }

  /// Real-time stream of notifications for the given [userId].
  Stream<List<NotificationItem>> notificationsStream(String userId) async* {
    yield List.unmodifiable(_inMemoryNotifications);

    try {
      final fs = _fs ?? FirebaseFirestore.instance;
      final firestoreStream = fs
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots();

      await for (final snapshot in firestoreStream) {
        if (snapshot.docs.isEmpty && _inMemoryNotifications.isNotEmpty) {
          _seedInitialToFirestore(userId, fs);
          yield List.unmodifiable(_inMemoryNotifications);
        } else {
          final items = snapshot.docs
              .map((doc) => NotificationItem.fromFirestore(doc))
              .toList();
          yield List.unmodifiable(items);
        }
      }
    } on Object catch (e) {
      debugPrint('Firestore uninitialized or stream notice: $e');
      yield* _localController.stream;
    }
  }

  Future<void> _seedInitialToFirestore(
      String userId, FirebaseFirestore fs) async {
    try {
      final batch = fs.batch();
      final collection =
          fs.collection('users').doc(userId).collection('notifications');

      for (final item in _inMemoryNotifications) {
        final docRef = collection.doc(item.id);
        batch.set(docRef, item.copyWith(userId: userId).toMap(),
            SetOptions(merge: true));
      }
      await batch.commit();
    } on Object catch (e) {
      debugPrint('Firestore seed notice: $e');
    }
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String userId, String notificationId) async {
    final index = _inMemoryNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _inMemoryNotifications[index] =
          _inMemoryNotifications[index].copyWith(isRead: true);
      _localController.add(List.unmodifiable(_inMemoryNotifications));
    }

    try {
      final fs = _fs ?? FirebaseFirestore.instance;
      await fs
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } on Object catch (e) {
      debugPrint('Firestore markAsRead notice: $e');
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead(String userId) async {
    for (var i = 0; i < _inMemoryNotifications.length; i++) {
      _inMemoryNotifications[i] =
          _inMemoryNotifications[i].copyWith(isRead: true);
    }
    _localController.add(List.unmodifiable(_inMemoryNotifications));

    try {
      final fs = _fs ?? FirebaseFirestore.instance;
      final docs = await fs
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (docs.docs.isNotEmpty) {
        final batch = fs.batch();
        for (final doc in docs.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } on Object catch (e) {
      debugPrint('Firestore markAllAsRead notice: $e');
    }
  }

  /// Delete a notification.
  Future<void> deleteNotification(String userId, String notificationId) async {
    _inMemoryNotifications.removeWhere((n) => n.id == notificationId);
    _localController.add(List.unmodifiable(_inMemoryNotifications));

    try {
      final fs = _fs ?? FirebaseFirestore.instance;
      await fs
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } on Object catch (e) {
      debugPrint('Firestore deleteNotification notice: $e');
    }
  }

  /// Add a new notification and persist it.
  Future<void> addNotification(NotificationItem notification) async {
    _inMemoryNotifications.insert(0, notification);
    _localController.add(List.unmodifiable(_inMemoryNotifications));

    try {
      final fs = _fs ?? FirebaseFirestore.instance;
      await fs
          .collection('users')
          .doc(notification.userId)
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap(), SetOptions(merge: true));
    } on Object catch (e) {
      debugPrint('Firestore addNotification notice: $e');
    }
  }

  /// Persist notification preferences in Firestore.
  Future<void> saveNotificationSettings(
      String userId, Map<String, bool> settings) async {
    _notificationSettings = Map.from(settings);

    try {
      final fs = _fs ?? FirebaseFirestore.instance;
      await fs
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set(_notificationSettings, SetOptions(merge: true));
    } on Object catch (e) {
      debugPrint('Firestore saveNotificationSettings notice: $e');
    }
  }

  /// Get current notification preferences.
  Map<String, bool> getNotificationSettings() {
    return Map.unmodifiable(_notificationSettings);
  }
}
