import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/history_model.dart';
import '../../domain/entities/history_entity.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryModel>> getHistory();
  Future<void> addHistoryItem(HistoryEntity item);
  Future<void> deleteHistoryItem(String id);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  HistoryRemoteDataSourceImpl({required this.firestore, required this.auth});

  String get _userId {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  @override
  Future<List<HistoryModel>> getHistory() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(_userId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HistoryModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch history: $e');
    }
  }

  @override
  Future<void> addHistoryItem(HistoryEntity item) async {
    try {
      final historyModel = HistoryModel(
        id: item.id,
        imageUrl: item.imageUrl,
        haircut: item.haircut,
        beard: item.beard,
        timestamp: item.timestamp,
      );

      await firestore
          .collection('users')
          .doc(_userId)
          .collection('history')
          .doc(item.id)
          .set(historyModel.toMap());
    } catch (e) {
      throw Exception('Failed to add history item: $e');
    }
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    try {
      await firestore
          .collection('users')
          .doc(_userId)
          .collection('history')
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete history item: $e');
    }
  }
}
