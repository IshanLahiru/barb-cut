import '../../domain/entities/ai_job_status.dart';

abstract class AiJobRemoteDataSource {
  Stream<AiJobStatus> watchJobStatus(String jobId);
}
