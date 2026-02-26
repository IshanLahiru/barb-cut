import '../../../../services/firebase_data_service.dart';
import 'products_remote_data_source.dart';

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> getProducts() =>
      FirebaseDataService.fetchProducts();
}
