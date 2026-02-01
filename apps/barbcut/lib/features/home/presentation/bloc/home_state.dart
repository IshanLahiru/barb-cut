import 'package:equatable/equatable.dart';
import '../../domain/entities/style_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<StyleEntity> haircuts;
  final List<StyleEntity> beardStyles;

  const HomeLoaded({required this.haircuts, required this.beardStyles});

  @override
  List<Object?> get props => [haircuts, beardStyles];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
