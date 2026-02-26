import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/history_entity.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<HistoryEntity>>> getHistory();
  Stream<List<HistoryEntity>> watchHistory(String userId);
}
