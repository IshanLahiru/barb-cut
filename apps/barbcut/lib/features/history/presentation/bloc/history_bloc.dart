import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/usecases/get_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;
  final HistoryRepository historyRepository;
  final AuthRepository authRepository;
  StreamSubscription<List<HistoryEntity>>? _historySubscription;

  HistoryBloc({
    required this.getHistoryUseCase,
    required this.historyRepository,
    required this.authRepository,
  }) : super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<_HistoryStreamUpdated>(_onStreamUpdated);
    on<_HistoryStreamError>(_onStreamError);
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    final user = authRepository.currentUser;
    developer.log(
      'History load requested. User: ${user?.id ?? "null"}',
      name: 'HistoryBloc',
    );

    if (user == null) {
      developer.log(
        'No authenticated user found. Showing empty history.',
        name: 'HistoryBloc',
      );
      emit(const HistoryLoaded(history: []));
      return;
    }

    await _historySubscription?.cancel();
    emit(const HistoryLoading());

    developer.log(
      'Starting history stream for user: ${user.id}',
      name: 'HistoryBloc',
    );

    _historySubscription = historyRepository
        .watchHistory(user.id)
        .listen(
          (history) {
            developer.log(
              'Received ${history.length} history items from stream',
              name: 'HistoryBloc',
            );
            if (!isClosed) {
              add(_HistoryStreamUpdated(history));
            }
          },
          onError: (e, st) {
            developer.log(
              'Error in history stream: $e',
              name: 'HistoryBloc',
              error: e,
              stackTrace: st,
            );
            if (!isClosed) {
              add(_HistoryStreamError(e.toString()));
            }
          },
        );
  }

  void _onStreamUpdated(
    _HistoryStreamUpdated event,
    Emitter<HistoryState> emit,
  ) {
    emit(HistoryLoaded(history: event.history));
  }

  void _onStreamError(_HistoryStreamError event, Emitter<HistoryState> emit) {
    emit(HistoryFailure(message: event.message));
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}

class _HistoryStreamUpdated extends HistoryEvent {
  final List<HistoryEntity> history;
  const _HistoryStreamUpdated(this.history);
  @override
  List<Object> get props => [history];
}

class _HistoryStreamError extends HistoryEvent {
  final String message;
  const _HistoryStreamError(this.message);
  @override
  List<Object> get props => [message];
}
