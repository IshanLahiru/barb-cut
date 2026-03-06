import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../../../services/firebase_storage_helper.dart';
import '../../domain/entities/history_entity.dart';
import '../models/history_model.dart';

import 'history_remote_data_source.dart';

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  HistoryRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const int _pageSize = 20;

  @override
  Stream<List<HistoryEntity>> watchHistory(String userId) {
    developer.log(
      'Setting up history stream for userId: $userId',
      name: 'HistoryRemoteDataSource',
    );

    return _firestore
        .collection('history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(_pageSize)
        .snapshots()
        .asyncMap((snapshot) async {
          developer.log(
            'Received ${snapshot.docs.length} history documents from Firestore',
            name: 'HistoryRemoteDataSource',
          );

          final items = await Future.wait(
            snapshot.docs.map((doc) async {
              final data = {'id': doc.id, ...doc.data()};
              final imagePath =
                  data['imageUrl']?.toString() ?? data['image']?.toString();
              var resolvedUrl = imagePath ?? '';
              if (resolvedUrl.isNotEmpty &&
                  (resolvedUrl.startsWith('gs://') ||
                      !resolvedUrl.startsWith('http'))) {
                try {
                  resolvedUrl = await FirebaseStorageHelper.getDownloadUrl(
                    resolvedUrl,
                  );
                } catch (e) {
                  developer.log(
                    'Failed to resolve image URL: $e',
                    name: 'HistoryRemoteDataSource',
                    error: e,
                  );
                }
              }
              return HistoryModel.fromMap({...data, 'imageUrl': resolvedUrl});
            }),
          );

          developer.log(
            'Processed ${items.length} history items',
            name: 'HistoryRemoteDataSource',
          );

          return items;
        });
  }
}
