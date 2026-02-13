import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/style_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StyleEntity>>> getHaircuts() async {
    try {
      final data = await remoteDataSource.getHaircuts();
      return Right(data);
    } catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StyleEntity>>> getBeardStyles() async {
    try {
      final data = await remoteDataSource.getBeardStyles();
      return Right(data);
    } catch (error) {
      return Left(UnknownFailure(error.toString()));
    }
  }
}
