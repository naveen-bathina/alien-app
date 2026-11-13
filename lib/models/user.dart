/// Simplified user profile used throughout the app.
/// (some fields mirror `Profile` from the existing profile module).
class UserProfile {
  UserProfile({
    required this.uid,
    required this.name,
    this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    uid: m['uid'] as String,
    name: m['name'] as String,
    photoUrl: m['photoUrl'] as String?,
  );

  final String uid;
  final String name;
  final String? photoUrl;

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'photoUrl': photoUrl,
  };
}
