import '../../domain/entities/history_entity.dart';
import '../models/history_model.dart';
import '../../../../core/constants/app_data.dart';

class HistoryLocalDataSource {
  List<HistoryEntity> getHistory() {
    return AppData.generateHistory()
        .map((item) => HistoryModel.fromMap(item))
        .toList();
  }
}
