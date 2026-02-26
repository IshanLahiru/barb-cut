import 'dart:async';

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
    if (user == null) {
      emit(const HistoryLoaded(history: []));
      return;
    }

    await _historySubscription?.cancel();
    emit(const HistoryLoading());

    _historySubscription = historyRepository.watchHistory(user.id).listen(
      (history) {
        if (!isClosed) {
          add(_HistoryStreamUpdated(history));
        }
      },
      onError: (e, st) {
        if (!isClosed) {
          add(_HistoryStreamError(e.toString()));
        }
      },
    );
  }

  void _onStreamUpdated(_HistoryStreamUpdated event, Emitter<HistoryState> emit) {
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
  _HistoryStreamUpdated(this.history);
  @override
  List<Object> get props => [history];
}

class _HistoryStreamError extends HistoryEvent {
  final String message;
  _HistoryStreamError(this.message);
  @override
  List<Object> get props => [message];
}
