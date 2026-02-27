import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_data.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/style_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/style_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<Either<Failure, List<StyleEntity>>> _getStylesWithFallback({
    required Future<List<StyleModel>> Function() remoteLoader,
    required Future<List<StyleModel>> Function() localLoader,
    required String kind,
  }) async {
    // 1) Try remote (Firestore) first
    try {
      final remoteStyles = await remoteLoader();
      if (remoteStyles.isNotEmpty) {
        return Right(remoteStyles.cast<StyleEntity>());
      }
    } catch (_) {
      // Ignore here and fall back to local/JSON below.
    }

    // 2) Fallback to local JSON-backed AppData
    try {
      if (!AppData.isLoaded) {
        await AppData.loadAppData();
      }
      final localStyles = await localLoader();
      if (localStyles.isNotEmpty) {
        return Right(localStyles.cast<StyleEntity>());
      }
      return Left(
        UnknownFailure('No $kind styles available from local data.'),
      );
    } catch (error) {
      return Left(
        UnknownFailure('Failed to load $kind styles: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, List<StyleEntity>>> getHaircuts() {
    return _getStylesWithFallback(
      remoteLoader: () => remoteDataSource.getHaircuts(),
      localLoader: () => localDataSource.getHaircuts(),
      kind: 'haircut',
    );
  }

  @override
  Future<Either<Failure, List<StyleEntity>>> getBeardStyles() {
    return _getStylesWithFallback(
      remoteLoader: () => remoteDataSource.getBeardStyles(),
      localLoader: () => localDataSource.getBeardStyles(),
      kind: 'beard',
    );
  }
}
