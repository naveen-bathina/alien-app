import 'package:myalien/home/models/profile_model.dart';

/// Interaction categories for matches and likes.
enum MatchFilter {
  mutuallyLiked,
  mutuallySuperliked,
  likedYou,
  superlikedYou,
  youLiked,
  youSuperliked,
}

/// The specific relation type of a match entry.
enum MatchRelationType {
  mutuallyLiked,
  mutuallySuperliked,
  receivedLike,
  receivedSuperlike,
  sentLike,
  sentSuperlike,
}

/// A companion match or like entry in MyAlien.
class MatchEntry {
  const MatchEntry({
    required this.profile,
    required this.relation,
    required this.timestamp,
    this.unreadCount = 0,
    this.lastMessage,
  });

  final Profile profile;
  final MatchRelationType relation;
  final DateTime timestamp;
  final int unreadCount;
  final String? lastMessage;

  bool get isMutual =>
      relation == MatchRelationType.mutuallyLiked ||
      relation == MatchRelationType.mutuallySuperliked;

  bool get isReceived =>
      relation == MatchRelationType.receivedLike ||
      relation == MatchRelationType.receivedSuperlike;

  bool get isSent =>
      relation == MatchRelationType.sentLike ||
      relation == MatchRelationType.sentSuperlike;

  MatchEntry copyWith({
    Profile? profile,
    MatchRelationType? relation,
    DateTime? timestamp,
    int? unreadCount,
    String? lastMessage,
  }) {
    return MatchEntry(
      profile: profile ?? this.profile,
      relation: relation ?? this.relation,
      timestamp: timestamp ?? this.timestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
