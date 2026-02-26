import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ai_job_status.dart';
import '../../domain/repositories/ai_job_repository.dart';

/// State for the generation status (AI job in progress).
class GenerationStatusState {
  final bool isGenerating;
  final Map<String, dynamic>? generatedStyleData;

  const GenerationStatusState({
    this.isGenerating = false,
    this.generatedStyleData,
  });
}

class GenerationStatusCubit extends Cubit<GenerationStatusState> {
  GenerationStatusCubit({required AiJobRepository aiJobRepository})
      : _aiJobRepository = aiJobRepository,
        super(const GenerationStatusState());

  final AiJobRepository _aiJobRepository;
  StreamSubscription<AiJobStatus>? _jobSubscription;

  void startWatchingJob(String jobId, Map<String, dynamic> initialStyleData) {
    _jobSubscription?.cancel();
    emit(GenerationStatusState(
      isGenerating: true,
      generatedStyleData: {...?initialStyleData, 'jobId': jobId},
    ));
    _jobSubscription = _aiJobRepository.watchJobStatus(jobId).listen(
      (status) {
        if (isClosed) return;
        final data = {
          ...?state.generatedStyleData,
          'jobId': status.jobId,
          'status': status.status,
          'errorMessage': status.errorMessage,
        };
        if (status.isCompleted) {
          emit(GenerationStatusState(
            isGenerating: false,
            generatedStyleData: {...data, 'status': 'completed'},
          ));
          _jobSubscription?.cancel();
        } else if (status.isError) {
          emit(GenerationStatusState(
            isGenerating: false,
            generatedStyleData: {
              ...data,
              'status': 'error',
              'errorMessage': status.errorMessage ?? 'Generation failed.',
            },
          ));
          _jobSubscription?.cancel();
        } else {
          emit(GenerationStatusState(
            isGenerating: true,
            generatedStyleData: data,
          ));
        }
      },
      onError: (e, st) {
        if (!isClosed) {
          emit(GenerationStatusState(
            isGenerating: false,
            generatedStyleData: {
              ...?state.generatedStyleData,
              'status': 'error',
              'errorMessage': e.toString(),
            },
          ));
        }
      },
    );
  }

  void clearGeneration() {
    _jobSubscription?.cancel();
    emit(const GenerationStatusState());
  }

  @override
  Future<void> close() {
    _jobSubscription?.cancel();
    return super.close();
  }
}
