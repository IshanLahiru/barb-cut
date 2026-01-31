import 'package:equatable/equatable.dart';
import '../../domain/entities/history_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<HistoryEntity> history;

  const HistoryLoaded({required this.history});

  @override
  List<Object> get props => [history];
}

class HistoryFailure extends HistoryState {
  final String message;

  const HistoryFailure({required this.message});

  @override
  List<Object> get props => [message];
}
