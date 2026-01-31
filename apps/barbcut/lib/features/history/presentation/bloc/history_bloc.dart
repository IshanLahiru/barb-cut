import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;

  HistoryBloc({required this.getHistoryUseCase})
    : super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());

    final result = await getHistoryUseCase();

    result.fold(
      (failure) => emit(HistoryFailure(message: failure.toString())),
      (history) => emit(HistoryLoaded(history: history)),
    );
  }
}
