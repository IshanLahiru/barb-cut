import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ai_job_status.dart';
import 'ai_job_remote_data_source.dart';

class AiJobRemoteDataSourceImpl implements AiJobRemoteDataSource {
  AiJobRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<AiJobStatus> watchJobStatus(String jobId) {
    return _firestore.collection('aiJobs').doc(jobId).snapshots().asyncMap((
      snapshot,
    ) async {
      if (!snapshot.exists) {
        final history = await _firestore
            .collection('history')
            .where('parentJobId', isEqualTo: jobId)
            .limit(1)
            .get();

        if (history.docs.isNotEmpty) {
          return AiJobStatus(jobId: jobId, status: 'completed');
        }

        return AiJobStatus(jobId: jobId, status: 'queued');
      }

      final data = snapshot.data();
      final status = data?['status']?.toString() ?? 'queued';
      final errorMessage = data?['errorMessage']?.toString();
      return AiJobStatus(
        jobId: jobId,
        status: status,
        errorMessage: errorMessage,
      );
    });
  }
}
