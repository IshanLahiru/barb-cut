import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../favourites/domain/usecases/add_favourite_usecase.dart';
import '../../../favourites/domain/usecases/get_favourites_usecase.dart';
import '../../../favourites/domain/usecases/remove_favourite_usecase.dart';
import '../../data/datasources/tab_categories_remote_data_source.dart';
import '../../domain/entities/tab_category_entity.dart';
import '../../domain/usecases/get_beard_styles_usecase.dart';
import '../../domain/usecases/get_haircuts_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHaircutsUseCase getHaircutsUseCase;
  final GetBeardStylesUseCase getBeardStylesUseCase;
  final GetFavouritesUseCase getFavouritesUseCase;
  final AddFavouriteUseCase addFavouriteUseCase;
  final RemoveFavouriteUseCase removeFavouriteUseCase;
  final AuthRepository authRepository;
  final TabCategoriesRemoteDataSource tabCategoriesDataSource;
  StreamSubscription<List<TabCategoryEntity>>? _tabCategoriesSubscription;

  HomeBloc({
    required this.getHaircutsUseCase,
    required this.getBeardStylesUseCase,
    required this.getFavouritesUseCase,
    required this.addFavouriteUseCase,
    required this.removeFavouriteUseCase,
    required this.authRepository,
    required this.tabCategoriesDataSource,
  }) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<FavouriteToggled>(_onFavouriteToggled);
    on<_TabCategoriesUpdated>(_onTabCategoriesUpdated);
  }

  static const Duration _loadTimeout = Duration(seconds: 45);

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final user = authRepository.currentUser;

    // Load haircuts, beards, and (when logged in) favourites in parallel
    final styleFutures = <Future>[
      getHaircutsUseCase(),
      getBeardStylesUseCase(),
    ];
    if (user != null) {
      styleFutures.add(getFavouritesUseCase(user.id));
    }

    List<dynamic> results;
    try {
      results = await Future.wait(styleFutures).timeout(
        _loadTimeout,
        onTimeout: () => throw TimeoutException('Styles failed to load'),
      );
    } on TimeoutException catch (e) {
      emit(HomeFailure(e.message ?? 'Request timed out. Check your connection.'));
      return;
    }

    final haircutsResult = results[0];
    final beardsResult = results[1];
    final haircuts = haircutsResult.fold((failure) => null, (data) => data);
    final beards = beardsResult.fold((failure) => null, (data) => data);

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

    Set<String> favouriteIds = {};
    String? favouritesError;
    if (user != null && results.length >= 3) {
      try {
        final favs = results[2] as List<Map<String, dynamic>>;
        favouriteIds = favs.map((f) => f['id'].toString()).toSet();
      } catch (e) {
        favouritesError = e.toString();
      }
    }

    final loaded = HomeLoaded(
      haircuts: haircuts,
      beardStyles: beards,
      favouriteIds: favouriteIds,
      favouritesError: favouritesError,
    );
    emit(loaded);

    _tabCategoriesSubscription?.cancel();
    _tabCategoriesSubscription =
        tabCategoriesDataSource.watchTabCategories().listen((categories) {
      final current = state;
      if (current is HomeLoaded && !isClosed) {
        add(_TabCategoriesUpdated(categories));
      }
    });
  }

  Future<void> _onFavouriteToggled(
    FavouriteToggled event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded) return;
    final user = authRepository.currentUser;
    if (user == null) return;

    final id = event.item['id']?.toString();
    if (id == null) return;

    final isFavourite = current.favouriteIds.contains(id);
    final newIds = Set<String>.from(current.favouriteIds);
    if (isFavourite) {
      newIds.remove(id);
      await removeFavouriteUseCase(userId: user.id, styleId: id);
    } else {
      newIds.add(id);
      await addFavouriteUseCase(
        userId: user.id,
        style: event.item,
        styleType: event.styleType,
      );
    }
    emit(HomeLoaded(
      haircuts: current.haircuts,
      beardStyles: current.beardStyles,
      favouriteIds: newIds,
      favouritesError: current.favouritesError,
      tabCategories: current.tabCategories,
    ));
  }

  void _onTabCategoriesUpdated(
    _TabCategoriesUpdated event,
    Emitter<HomeState> emit,
  ) {
    final current = state;
    if (current is HomeLoaded) {
      emit(HomeLoaded(
        haircuts: current.haircuts,
        beardStyles: current.beardStyles,
        favouriteIds: current.favouriteIds,
        favouritesError: current.favouritesError,
        tabCategories: event.categories,
      ));
    }
  }

  @override
  Future<void> close() {
    _tabCategoriesSubscription?.cancel();
    return super.close();
  }
}

class _TabCategoriesUpdated extends HomeEvent {
  final List<TabCategoryEntity> categories;
  const _TabCategoriesUpdated(this.categories);
  @override
  List<Object?> get props => [categories];
}
