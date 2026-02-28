import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_data.dart';
import '../../../../core/errors/failure.dart';
import '../../../../services/firebase_data_service.dart';
import '../../domain/entities/style_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';
import '../datasources/styles_disk_cache.dart';
import '../models/style_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final StylesDiskCache diskCache;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.diskCache,
  });

  Future<Either<Failure, List<StyleEntity>>> _getStylesWithFallback({
    required Future<List<Map<String, dynamic>>?> Function() diskReader,
    required Future<List<StyleModel>> Function() remoteLoader,
    required Future<void> Function(List<StyleModel>) diskWriter,
    required Future<List<StyleModel>> Function() localLoader,
    required List<StyleEntity> Function(List<Map<String, dynamic>>) fromDiskMap,
    required String kind,
  }) async {
    // 1) Try disk cache first (cold start / offline)
    final diskData = await diskReader();
    if (diskData != null && diskData.isNotEmpty) {
      return Right(fromDiskMap(diskData));
    }

    // 2) Try remote (Firestore)
    try {
      final remoteStyles = await remoteLoader();
      if (remoteStyles.isNotEmpty) {
        await diskWriter(remoteStyles);
        return Right(remoteStyles.cast<StyleEntity>());
      }
    } catch (_) {
      // Ignore and fall back to local/JSON below.
    }

    // 3) Fallback to local JSON-backed AppData
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
      diskReader: () => diskCache.readHaircuts(),
      remoteLoader: () => remoteDataSource.getHaircuts(),
      diskWriter: (styles) => diskCache.writeHaircuts(
        styles.map((s) => s.toMap()).toList(),
      ),
      localLoader: () => localDataSource.getHaircuts(),
      fromDiskMap: (maps) => maps
          .map((m) => StyleModel.fromMap(m, StyleType.haircut))
          .cast<StyleEntity>()
          .toList(),
      kind: 'haircut',
    );
  }

  @override
  Future<Either<Failure, List<StyleEntity>>> getBeardStyles() {
    return _getStylesWithFallback(
      diskReader: () => diskCache.readBeardStyles(),
      remoteLoader: () => remoteDataSource.getBeardStyles(),
      diskWriter: (styles) => diskCache.writeBeardStyles(
        styles.map((s) => s.toMap()).toList(),
      ),
      localLoader: () => localDataSource.getBeardStyles(),
      fromDiskMap: (maps) => maps
          .map((m) => StyleModel.fromMap(m, StyleType.beard))
          .cast<StyleEntity>()
          .toList(),
      kind: 'beard',
    );
  }

  @override
  Future<(List<StyleEntity>, List<StyleEntity>)?> getCachedStyles() async {
    final haircuts = FirebaseDataService.cachedHaircuts;
    final beards = FirebaseDataService.cachedBeardStyles;
    if (haircuts == null ||
        beards == null ||
        haircuts.isEmpty ||
        beards.isEmpty) {
      return null;
    }
    final haircutEntities = haircuts
        .map((m) => StyleModel.fromMap(m, StyleType.haircut))
        .cast<StyleEntity>()
        .toList();
    final beardEntities = beards
        .map((m) => StyleModel.fromMap(m, StyleType.beard))
        .cast<StyleEntity>()
        .toList();
    return (haircutEntities, beardEntities);
  }
}
