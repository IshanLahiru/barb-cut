import 'package:cloud_firestore/cloud_firestore.dart';

import 'favourites_remote_data_source.dart';

class FavouritesRemoteDataSourceImpl implements FavouritesRemoteDataSource {
  FavouritesRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<Map<String, dynamic>>> getFavourites(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .orderBy('addedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  @override
  Future<void> addFavourite({
    required String userId,
    required Map<String, dynamic> style,
    required String styleType,
  }) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .doc(style['id']?.toString());
    await ref.set({
      ...style,
      'styleType': styleType,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeFavourite({
    required String userId,
    required String styleId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favourites')
        .doc(styleId)
        .delete();
  }
}
