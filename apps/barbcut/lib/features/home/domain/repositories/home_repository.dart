import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/style_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<StyleEntity>>> getHaircuts();
  Future<Either<Failure, List<StyleEntity>>> getBeardStyles();

  /// Returns cached styles from in-memory cache (e.g. for rehydration after hot reload).
  /// Null when cache is incomplete or empty.
  Future<(List<StyleEntity>, List<StyleEntity>)?> getCachedStyles();
}
