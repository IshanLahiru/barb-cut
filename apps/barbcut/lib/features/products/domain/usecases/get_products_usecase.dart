import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call() async {
    return repository.getProducts();
  }
}
