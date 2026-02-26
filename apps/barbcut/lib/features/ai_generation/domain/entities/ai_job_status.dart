import 'package:equatable/equatable.dart';

class AiJobStatus extends Equatable {
  final String jobId;
  final String status; // 'queued' | 'processing' | 'completed' | 'error'
  final String? errorMessage;

  const AiJobStatus({
    required this.jobId,
    required this.status,
    this.errorMessage,
  });

  bool get isCompleted => status == 'completed';
  bool get isError => status == 'error';
  bool get isGenerating => status == 'queued' || status == 'processing';

  @override
  List<Object?> get props => [jobId, status, errorMessage];
}
