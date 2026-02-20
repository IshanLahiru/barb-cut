import '../../../../services/firebase_data_service.dart';
import '../../domain/entities/style_entity.dart';
import '../models/style_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<StyleModel>> getHaircuts();
  Future<List<StyleModel>> getBeardStyles();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  @override
  Future<List<StyleModel>> getHaircuts() async {
    final data = await FirebaseDataService.fetchHaircuts();
    return data
        .map((item) => StyleModel.fromMap(item, StyleType.haircut))
        .toList();
  }

  @override
  Future<List<StyleModel>> getBeardStyles() async {
    final data = await FirebaseDataService.fetchBeardStyles();
    return data
        .map((item) => StyleModel.fromMap(item, StyleType.beard))
        .toList();
  }
}
