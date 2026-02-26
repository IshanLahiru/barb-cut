import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_data_source.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remoteDataSource;

  ProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final list = await remoteDataSource.getProducts();
      return Right(list.map((m) => ProductModel.fromMap(m)).toList());
    } catch (e, stackTrace) {
      developer.log(
        'getProducts failed',
        name: 'ProductsRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(e.toString()));
    }
  }
}
