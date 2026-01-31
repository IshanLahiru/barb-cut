import 'package:flutter_bloc/flutter_bloc.dart';


















































import '../../domain/usecases/get_beard_styles_usecase.dart';
import '../../domain/usecases/get_haircuts_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHaircutsUseCase getHaircutsUseCase;
  final GetBeardStylesUseCase getBeardStylesUseCase;

  HomeBloc({
    required this.getHaircutsUseCase,
    required this.getBeardStylesUseCase,
  }) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final haircutsResult = await getHaircutsUseCase();
    final beardsResult = await getBeardStylesUseCase();

    final haircuts = haircutsResult.fold(
      (failure) => null,
      (data) => data,
    );
    final beards = beardsResult.fold(
      (failure) => null,
      (data) => data,
    );

    if (haircuts == null || beards == null) {
      final message = haircutsResult.fold(
        (failure) => failure.message,
        (_) => beardsResult.fold(
          (failure) => failure.message,
          (_) => 'Failed to load styles',
        ),
      );
      emit(HomeFailure(message));
      return;
    }

    emit(HomeLoaded(haircuts: haircuts, beardStyles: beards));
  }
}
