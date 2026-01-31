import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/history_entity.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<Either<Failure, List<HistoryEntity>>> call() async {
    return repository.getHistory();
  }
}
