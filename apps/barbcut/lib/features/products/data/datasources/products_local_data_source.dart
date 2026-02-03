import '../../domain/entities/product_entity.dart';
import '../models/product_model.dart';
import '../../../../core/constants/app_data.dart';

class ProductsLocalDataSource {
  List<ProductEntity> getProducts() {
    return AppData.products.map((item) => ProductModel.fromMap(item)).toList();
  }
}
