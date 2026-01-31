import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/style_entity.dart';
import '../repositories/home_repository.dart';

class GetBeardStylesUseCase {
  final HomeRepository repository;

  GetBeardStylesUseCase(this.repository);

  Future<Either<Failure, List<StyleEntity>>> call() {
    return repository.getBeardStyles();
  }
}
