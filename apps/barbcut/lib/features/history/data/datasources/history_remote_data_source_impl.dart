import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/firebase_storage_helper.dart';
import '../../domain/entities/history_entity.dart';
import '../models/history_model.dart';

import 'history_remote_data_source.dart';

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  HistoryRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<HistoryEntity>> watchHistory(String userId) {
    return _firestore
        .collection('history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final items = await Future.wait(
            snapshot.docs.map((doc) async {
              final data = {'id': doc.id, ...doc.data()};
              final imagePath = data['imageUrl']?.toString() ?? data['image']?.toString();
              var resolvedUrl = imagePath ?? '';
              if (resolvedUrl.isNotEmpty &&
                  (resolvedUrl.startsWith('gs://') || !resolvedUrl.startsWith('http'))) {
                resolvedUrl = await FirebaseStorageHelper.getDownloadUrl(resolvedUrl);
              }
              return HistoryModel.fromMap({...data, 'imageUrl': resolvedUrl});
            }),
          );
          return items;
        });
  }
}
