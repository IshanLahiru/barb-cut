import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<HistoryEntity>>> getHistory() async {
    try {
      final history = await localDataSource.getHistory();
      return Right(history);
    } catch (e) {
      return Left(UnknownFailure());
    }
  }

  @override
  Stream<List<HistoryEntity>> watchHistory(String userId) =>
      remoteDataSource.watchHistory(userId);
}
