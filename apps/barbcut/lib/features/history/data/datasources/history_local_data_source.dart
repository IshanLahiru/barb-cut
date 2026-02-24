import '../../domain/entities/history_entity.dart';
import '../models/history_model.dart';
import '../../../../services/firebase_data_service.dart';

class HistoryLocalDataSource {
  Future<List<HistoryEntity>> getHistory() async {
    final history = await FirebaseDataService.fetchHistory(forceRefresh: true);
    return history.map((item) => HistoryModel.fromMap(item)).toList();
  }
}
