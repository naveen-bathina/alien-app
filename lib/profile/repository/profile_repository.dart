// profile_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myalien/profile/models/profile_model.dart';

class ProfileRepository {
  ProfileRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _fs = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;
  final FirebaseFirestore _fs;
  final FirebaseStorage _storage;

  /// Uploads profile image. Firebase Storage is optional.
  /// If storage is unreachable or fails, falls back to binary data URI stored
  /// directly in Firebase (Firestore).
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
      // Storage is optional: convert to binary for direct Firebase storage
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

  Future<Profile?> fetchProfile(String uid) async {
    final doc = await getProfileDoc(uid);
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return Profile.fromMap(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProfileDoc(String uid) {
    return _fs.collection('users').doc(uid).get();
  }
}
