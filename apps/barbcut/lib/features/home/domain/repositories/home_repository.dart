import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/style_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<StyleEntity>>> getHaircuts();
  Future<Either<Failure, List<StyleEntity>>> getBeardStyles();
}
