import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'favourites_remote_data_source.dart';

class FavouritesRemoteDataSourceImpl implements FavouritesRemoteDataSource {
  FavouritesRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _getProjectId() {
    try {
      final projectId = _firestore.app.options.projectId;
      return projectId ?? 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFavourites(String userId) async {
    final projectId = _getProjectId();
    final path = 'users/$userId/favourites';

    try {
      if (kDebugMode)
        print(
          '[FavouritesDataSource] getFavourites START - Project: $projectId, Path: $path, UserId: $userId',
        );

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favourites')
          .orderBy('addedAt', descending: true)
          .get();

      if (kDebugMode)
        print(
          '[FavouritesDataSource] getFavourites SUCCESS - Found ${snapshot.docs.length} documents',
        );
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      if (kDebugMode)
        print('[FavouritesDataSource] getFavourites ERROR - Exception: $e');
      rethrow;
    }
  }

  @override
  Future<void> addFavourite({
    required String userId,
    required Map<String, dynamic> style,
    required String styleType,
  }) async {
    final projectId = _getProjectId();
    final styleId = style['id']?.toString();
    final path = 'users/$userId/favourites/$styleId';

    try {
      if (kDebugMode)
        print(
          '[FavouritesDataSource] addFavourite START - Project: $projectId, Path: $path, UserId: $userId, StyleId: $styleId, StyleType: $styleType',
        );

      final ref = _firestore
          .collection('users')
          .doc(userId)
          .collection('favourites')
          .doc(styleId);

      await ref.set({
        ...style,
        'styleType': styleType,
        'addedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode)
        print(
          '[FavouritesDataSource] addFavourite SUCCESS - Document written to: $path',
        );
    } catch (e) {
      if (kDebugMode)
        print(
          '[FavouritesDataSource] addFavourite ERROR - Path: $path, Exception: $e, ExceptionType: ${e.runtimeType}',
        );
      rethrow;
    }
  }

  @override
  Future<void> removeFavourite({
    required String userId,
    required String styleId,
  }) async {
    final projectId = _getProjectId();
    final path = 'users/$userId/favourites/$styleId';

    try {
      if (kDebugMode)
        print(
          '[FavouritesDataSource] removeFavourite START - Project: $projectId, Path: $path, UserId: $userId, StyleId: $styleId',
        );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favourites')
          .doc(styleId)
          .delete();

      if (kDebugMode)
        print(
          '[FavouritesDataSource] removeFavourite SUCCESS - Document deleted from: $path',
        );
    } catch (e) {
      if (kDebugMode)
        print(
          '[FavouritesDataSource] removeFavourite ERROR - Path: $path, Exception: $e, ExceptionType: ${e.runtimeType}',
        );
      rethrow;
    }
  }
}
