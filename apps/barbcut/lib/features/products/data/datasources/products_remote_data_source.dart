import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final FirebaseFirestore firestore;

  ProductsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await firestore.collection('products').get();
      return snapshot.docs
          .map((doc) => ProductModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}
