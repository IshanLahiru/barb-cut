import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/style_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<StyleEntity>>> getHaircuts() async {
    try {
      final data = await localDataSource.getHaircuts();
      return Right(data);
    } catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StyleEntity>>> getBeardStyles() async {
    try {
      final data = await localDataSource.getBeardStyles();
      return Right(data);
    } catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }
}
