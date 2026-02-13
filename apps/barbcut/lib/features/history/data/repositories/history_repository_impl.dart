import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HistoryEntity>>> getHistory() async {
    try {
      final history = await remoteDataSource.getHistory();
      return Right(history);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
