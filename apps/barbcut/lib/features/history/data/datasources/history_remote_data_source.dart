import '../../domain/entities/history_entity.dart';

/// Remote data source for history (Firestore history collection).
abstract class HistoryRemoteDataSource {
  Stream<List<HistoryEntity>> watchHistory(String userId);
}
