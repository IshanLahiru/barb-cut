import '../entities/ai_job_status.dart';

abstract class AiJobRepository {
  Stream<AiJobStatus> watchJobStatus(String jobId);
}
