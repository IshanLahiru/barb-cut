import '../../domain/entities/ai_job_status.dart';
import '../../domain/repositories/ai_job_repository.dart';
import '../datasources/ai_job_remote_data_source.dart';

class AiJobRepositoryImpl implements AiJobRepository {
  AiJobRepositoryImpl({required AiJobRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final AiJobRemoteDataSource _remote;

  @override
  Stream<AiJobStatus> watchJobStatus(String jobId) =>
      _remote.watchJobStatus(jobId);
}
