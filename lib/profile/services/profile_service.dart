import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myalien/profile/models/profile_model.dart';

class ProfileService {
  ProfileService({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore,
        _storageRef = storage;

  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storageRef;

  FirebaseFirestore get _fs => _firestore ?? FirebaseFirestore.instance;
  FirebaseStorage get _storage => _storageRef ?? FirebaseStorage.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfileDoc(String uid) {
    return _fs.collection('users').doc(uid).get();
  }

  Future<bool> profileExists(String uid) async {
    try {
      final doc = await getProfileDoc(uid);
      return doc.exists && isComplete(doc.data());
    } on Object {
      return false;
    }
  }

  bool isComplete(Map<String, dynamic>? data) {
    if (data == null) return false;

    // Check name / displayName / fullName
    final name = data['displayName'] ?? data['fullName'] ?? data['name'];
    if (name is! String || name.trim().isEmpty) return false;

    // Check gender
    final gender = data['gender'];
    if (gender is! String || gender.trim().isEmpty) return false;

    // Check location
    final location = data['location'];
    if (location is! String || location.trim().isEmpty) return false;

    // Check age / dob
    final dobValue = data['dob'];
    if (dobValue is! String) return false;
    final dob = DateTime.tryParse(dobValue);
    if (dob == null) return false;

    final today = DateTime.now();
    final eighteenthBirthday = DateTime(
      today.year - 18,
      today.month,
      today.day,
    );
    if (dob.isAfter(eighteenthBirthday)) return false;

    // Check profile picture
    final photoUrl = data['photoUrl'];
    final photos = data['photos'];
    final hasPhoto = (photoUrl is String && photoUrl.trim().isNotEmpty) ||
        (photos is List &&
            photos.any((p) => p is String && p.trim().isNotEmpty));
    if (!hasPhoto) return false;

    return true;
  }

  Future<String?> uploadProfileImage(
    String uid,
    File file, {
    void Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child('profile_pics')
          .child('$uid-${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(file);
      uploadTask.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0 && onProgress != null) {
          onProgress(snap.bytesTransferred / snap.totalBytes);
        }
      }, onError: (_) {});
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on Object {
      // Storage is optional: convert to binary base64
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    }
  }

  Future<void> saveProfile(Profile profile) async {
    await _fs
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }
}
