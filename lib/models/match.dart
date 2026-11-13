import 'package:myalien/models/user.dart';

/// Represents a connection between two users in the dating app.
class MatchModel {
  MatchModel({
    required this.id,
    required this.user1,
    required this.user2,
    required this.matchedAt,
  });

  factory MatchModel.fromMap(Map<String, dynamic> m) => MatchModel(
    id: m['id'] as String,
    user1: UserProfile.fromMap(m['user1'] as Map<String, dynamic>),
    user2: UserProfile.fromMap(m['user2'] as Map<String, dynamic>),
    matchedAt: DateTime.parse(m['matchedAt'] as String),
  );

  final String id;
  final UserProfile user1;
  final UserProfile user2;
  final DateTime matchedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'user1': user1.toMap(),
    'user2': user2.toMap(),
    'matchedAt': matchedAt.toIso8601String(),
  };
}
