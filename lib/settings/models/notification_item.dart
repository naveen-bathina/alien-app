import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a realtime notification persisted in Firestore.
class NotificationItem extends Equatable {
  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'system',
    this.actionRoute,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final String? actionRoute;

  NotificationItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? actionRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
      'actionRoute': actionRoute,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedDate;
    final rawTimestamp = map['timestamp'];
    if (rawTimestamp is Timestamp) {
      parsedDate = rawTimestamp.toDate();
    } else if (rawTimestamp is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else if (rawTimestamp is String) {
      parsedDate = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return NotificationItem(
      id: (docId ?? map['id'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      body: (map['body'] ?? '') as String,
      timestamp: parsedDate,
      isRead: (map['isRead'] as bool?) ?? false,
      type: (map['type'] ?? 'system') as String,
      actionRoute: map['actionRoute'] as String?,
    );
  }

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return NotificationItem.fromMap(data, docId: doc.id);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        timestamp,
        isRead,
        type,
        actionRoute,
      ];
}
