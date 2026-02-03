import '../../domain/entities/style_entity.dart';
import '../models/style_model.dart';
import '../../../../core/constants/app_data.dart';

abstract class HomeLocalDataSource {
  Future<List<StyleModel>> getHaircuts();
  Future<List<StyleModel>> getBeardStyles();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  @override
  Future<List<StyleModel>> getHaircuts() async {
    return AppData.haircuts
        .map((item) => StyleModel.fromMap(item, StyleType.haircut))
        .toList();
  }

  @override
  Future<List<StyleModel>> getBeardStyles() async {
    return AppData.beardStyles
        .map((item) => StyleModel.fromMap(item, StyleType.beard))
        .toList();
  }
}
