import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsLocalDataSource localDataSource;

  ProductsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final products = localDataSource.getProducts();
      return Right(products);
    } catch (e) {
      return Left(UnknownFailure());
    }
  }
}
