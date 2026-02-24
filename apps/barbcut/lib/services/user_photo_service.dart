import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPhotoService {
  UserPhotoService._();

  static final _storage = FirebaseStorage.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Upload a face photo for the user
  /// [position] should be one of: 'front', 'left', 'right', 'back'
  /// [imageFile] is the file to upload
  static Future<String> uploadFacePhoto({
    required String position,
    required File imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    if (!['front', 'left', 'right', 'back'].contains(position)) {
      throw Exception('Invalid position. Must be: front, left, right, or back');
    }

    try {
      // Upload to Storage: user-photos/{userId}/{position}.jpg
      final ref = _storage.ref('user-photos/${user.uid}/$position.jpg');
      final uploadTask = ref.putFile(imageFile);
      await uploadTask;

      // Get the download URL (for reference)
      final downloadUrl = await ref.getDownloadURL();

      // Update Firestore: userPhotos/{userId} with the GS URL
      final gsUrl = 'gs://${ref.bucket}/${ref.fullPath}';
      await _firestore.collection('userPhotos').doc(user.uid).set({
        position: gsUrl,
      }, SetOptions(merge: true));

      return gsUrl;
    } catch (e) {
      throw Exception('Failed to upload face photo: $e');
    }
  }

  /// Get user's uploaded face photos
  static Future<Map<String, String?>> getUserPhotos({String? userId}) async {
    final targetUserId = userId ?? _auth.currentUser?.uid;
    if (targetUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final doc = await _firestore
          .collection('userPhotos')
          .doc(targetUserId)
          .get();
      if (!doc.exists) {
        return {'front': null, 'left': null, 'right': null, 'back': null};
      }

      final data = doc.data() ?? {};
      return {
        'front': data['front'] as String?,
        'left': data['left'] as String?,
        'right': data['right'] as String?,
        'back': data['back'] as String?,
      };
    } catch (e) {
      throw Exception('Failed to fetch user photos: $e');
    }
  }

  /// Delete a face photo for the user
  static Future<void> deleteFacePhoto(String position) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Delete from Storage
      final ref = _storage.ref('user-photos/${user.uid}/$position.jpg');
      await ref.delete();

      // Remove from Firestore
      await _firestore.collection('userPhotos').doc(user.uid).update({
        position: FieldValue.delete(),
      });
    } catch (e) {
      throw Exception('Failed to delete face photo: $e');
    }
  }

  /// Check if user has at least one photo
  static Future<bool> hasPhotoUploaded({String? userId}) async {
    try {
      final photos = await getUserPhotos(userId: userId);
      return photos.values.any((url) => url != null);
    } catch (e) {
      return false;
    }
  }
}
