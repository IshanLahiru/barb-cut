import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/style_model.dart';
import '../../domain/entities/style_entity.dart';

abstract class HomeRemoteDataSource {
  Future<List<StyleModel>> getHaircuts();
  Future<List<StyleModel>> getBeardStyles();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;

  HomeRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<StyleModel>> getHaircuts() async {
    try {
      final snapshot = await firestore.collection('haircuts').get();
      return snapshot.docs
          .map(
            (doc) => StyleModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }, StyleType.haircut),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch haircuts: $e');
    }
  }

  @override
  Future<List<StyleModel>> getBeardStyles() async {
    try {
      final snapshot = await firestore.collection('beard_styles').get();
      return snapshot.docs
          .map(
            (doc) => StyleModel.fromMap({
              ...doc.data(),
              'id': doc.id,
            }, StyleType.beard),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch beard styles: $e');
    }
  }
}
