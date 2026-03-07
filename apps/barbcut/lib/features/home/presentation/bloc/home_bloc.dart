import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../favourites/domain/usecases/add_favourite_usecase.dart';
import '../../../favourites/domain/usecases/get_favourites_usecase.dart';
import '../../../favourites/domain/usecases/remove_favourite_usecase.dart';
import '../../data/datasources/tab_categories_remote_data_source.dart';
import '../../domain/entities/tab_category_entity.dart';
import '../../domain/usecases/get_beard_styles_usecase.dart';
import '../../domain/usecases/get_cached_styles_usecase.dart';
import '../../domain/usecases/get_haircuts_usecase.dart';
import '../../domain/entities/style_entity.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHaircutsUseCase getHaircutsUseCase;
  final GetBeardStylesUseCase getBeardStylesUseCase;
  final GetCachedStylesUseCase getCachedStylesUseCase;
  final GetFavouritesUseCase getFavouritesUseCase;
  final AddFavouriteUseCase addFavouriteUseCase;
  final RemoveFavouriteUseCase removeFavouriteUseCase;
  final AuthRepository authRepository;
  final TabCategoriesRemoteDataSource tabCategoriesDataSource;
  StreamSubscription<List<TabCategoryEntity>>? _tabCategoriesSubscription;

  HomeBloc({
    required this.getHaircutsUseCase,
    required this.getBeardStylesUseCase,
    required this.getCachedStylesUseCase,
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
    // Skip refetch when already loaded (e.g. user switched tabs and back)
    if (state is HomeLoaded) {
      return;
    }

    // Rehydrate from in-memory cache first (e.g. after hot reload)
    final cached = await getCachedStylesUseCase();
    if (cached != null) {
      final (haircuts, beards) = cached;
      Set<String> favouriteIds = {};
      String? favouritesError;
      final user = authRepository.currentUser;
      if (user != null) {
        try {
          if (kDebugMode)
            print(
              '[HomeBloc] _onLoadRequested (cached) - Loading favourites for ${user.id}',
            );
          final favs = await getFavouritesUseCase(user.id);
          favouriteIds = favs.map((f) => f['id'].toString()).toSet();
          if (kDebugMode)
            print(
              '[HomeBloc] _onLoadRequested (cached) - Loaded ${favouriteIds.length} favourites',
            );
        } catch (e) {
          if (kDebugMode)
            print(
              '[HomeBloc] _onLoadRequested (cached) - Favourites load failed: $e',
            );
          favouritesError = e.toString();
        }
      }
      emit(
        HomeLoaded(
          haircuts: haircuts,
          beardStyles: beards,
          favouriteIds: favouriteIds,
          favouritesError: favouritesError,
        ),
      );
      _startTabCategoriesStream();
      return;
    }

    emit(const HomeLoading());

    final user = authRepository.currentUser;
    if (kDebugMode)
      print(
        '[HomeBloc] _onLoadRequested - Starting load for user: ${user?.id ?? 'anonymous'}',
      );

    // Load haircuts and beards in parallel (CRITICAL PATH - must succeed)
    List<dynamic> criticalResults;
    try {
      if (kDebugMode)
        print('[HomeBloc] _onLoadRequested - Loading haircuts and beards');
      criticalResults =
          await Future.wait([
            getHaircutsUseCase(),
            getBeardStylesUseCase(),
          ]).timeout(
            _loadTimeout,
            onTimeout: () => throw TimeoutException('Styles failed to load'),
          );
      if (kDebugMode)
        print(
          '[HomeBloc] _onLoadRequested - Haircuts and beards loaded successfully',
        );
    } on TimeoutException catch (e) {
      if (kDebugMode)
        print('[HomeBloc] _onLoadRequested - CRITICAL TIMEOUT: ${e.message}');
      emit(
        HomeFailure(e.message ?? 'Request timed out. Check your connection.'),
      );
      return;
    } catch (e) {
      if (kDebugMode) print('[HomeBloc] _onLoadRequested - CRITICAL ERROR: $e');
      emit(HomeFailure('Failed to load styles: $e'));
      return;
    }

    final haircutsResult = criticalResults[0];
    final beardsResult = criticalResults[1];
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
      if (kDebugMode)
        print('[HomeBloc] _onLoadRequested - Style parsing failed: $message');
      emit(HomeFailure(message));
      return;
    }

    // Load favourites SEPARATELY (NON-CRITICAL - can fail independently)
    Set<String> favouriteIds = {};
    String? favouritesError;
    if (user != null) {
      try {
        if (kDebugMode)
          print(
            '[HomeBloc] _onLoadRequested - Loading favourites for ${user.id}',
          );
        final favs = await getFavouritesUseCase(user.id).timeout(
          _loadTimeout,
          onTimeout: () {
            if (kDebugMode)
              print(
                '[HomeBloc] _onLoadRequested - Favourites load TIMEOUT, continuing with empty set',
              );
            return [];
          },
        );
        favouriteIds = favs.map((f) => f['id'].toString()).toSet();
        if (kDebugMode)
          print(
            '[HomeBloc] _onLoadRequested - Loaded ${favouriteIds.length} favourites',
          );
      } catch (e) {
        if (kDebugMode)
          print(
            '[HomeBloc] _onLoadRequested - Favourites load FAILED (non-critical): $e',
          );
        favouritesError = 'Could not load favourites. ${e.toString()}';
      }
    }

    final loaded = HomeLoaded(
      haircuts: haircuts,
      beardStyles: beards,
      favouriteIds: favouriteIds,
      favouritesError: favouritesError,
    );
    if (kDebugMode)
      print(
        '[HomeBloc] _onLoadRequested - Emitting HomeLoaded state with ${haircuts.length} haircuts, ${beards.length} beards, ${favouriteIds.length} favourites',
      );
    emit(loaded);

    _startTabCategoriesStream();
  }

  void _startTabCategoriesStream() {
    _tabCategoriesSubscription?.cancel();
    _tabCategoriesSubscription = tabCategoriesDataSource
        .watchTabCategories()
        .distinct((previous, next) => previous == next)
        .listen((categories) {
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
    if (kDebugMode)
      print(
        '[HomeBloc] _onFavouriteToggled START - Event: ${event.runtimeType}, StyleType: ${event.styleType}',
      );

    final current = state;
    if (current is! HomeLoaded) {
      if (kDebugMode)
        print(
          '[HomeBloc] _onFavouriteToggled - State is not HomeLoaded, ignoring',
        );
      return;
    }
    if (current.favouritesLoading) {
      if (kDebugMode)
        print(
          '[HomeBloc] _onFavouriteToggled - Already loading, preventing concurrent toggle',
        );
      return;
    }

    final id = event.item['id']?.toString();
    if (id == null || id.isEmpty) {
      if (kDebugMode)
        print('[HomeBloc] _onFavouriteToggled - Invalid style ID: $id');
      emit(
        current.copyWith(
          favouritesLoading: false,
          favouritesError: 'Unable to update favourite: invalid style ID.',
        ),
      );
      return;
    }

    var user = authRepository.currentUser;
    if (kDebugMode)
      print(
        '[HomeBloc] _onFavouriteToggled - Initial user check: ${user != null ? user.id : 'null'}',
      );

    if (user == null) {
      try {
        if (kDebugMode)
          print(
            '[HomeBloc] _onFavouriteToggled - User null, calling ensureAuthenticated()',
          );
        await authRepository.ensureAuthenticated();
        user = authRepository.currentUser;
        if (kDebugMode)
          print(
            '[HomeBloc] _onFavouriteToggled - After ensureAuthenticated: ${user != null ? user.id : 'null'}',
          );
      } catch (e) {
        if (kDebugMode)
          print(
            '[HomeBloc] _onFavouriteToggled - ensureAuthenticated failed: $e',
          );
      }
    }
    if (user == null) {
      if (kDebugMode)
        print(
          '[HomeBloc] _onFavouriteToggled - User still null after auth attempt',
        );
      emit(
        current.copyWith(
          favouritesLoading: false,
          favouritesError: 'Please sign in before adding styles to favourites.',
        ),
      );
      return;
    }

    final isFavourite = current.favouriteIds.contains(id);
    if (kDebugMode)
      print(
        '[HomeBloc] _onFavouriteToggled - UserId: ${user.id}, StyleId: $id, IsFavourite: $isFavourite, Operation: ${isFavourite ? 'REMOVE' : 'ADD'}',
      );

    final optimisticIds = Set<String>.from(current.favouriteIds);
    if (isFavourite) {
      optimisticIds.remove(id);
    } else {
      optimisticIds.add(id);
    }

    emit(
      current.copyWith(
        favouriteIds: optimisticIds,
        favouritesLoading: true,
        clearFavouritesError: true,
      ),
    );
    if (kDebugMode)
      print(
        '[HomeBloc] _onFavouriteToggled - Emitted optimistic state, FavouritesLoading: true',
      );

    try {
      if (isFavourite) {
        if (kDebugMode)
          print(
            '[HomeBloc] _onFavouriteToggled - Calling removeFavouriteUseCase for $id',
          );
        await removeFavouriteUseCase(userId: user.id, styleId: id);
      } else {
        if (kDebugMode)
          print(
            '[HomeBloc] _onFavouriteToggled - Calling addFavouriteUseCase for $id',
          );
        await addFavouriteUseCase(
          userId: user.id,
          style: event.item,
          styleType: event.styleType,
        );
      }
      if (kDebugMode)
        print(
          '[HomeBloc] _onFavouriteToggled - Operation COMPLETED successfully',
        );

      emit(
        current.copyWith(
          favouriteIds: optimisticIds,
          favouritesLoading: false,
          clearFavouritesError: true,
        ),
      );
      if (kDebugMode)
        print('[HomeBloc] _onFavouriteToggled - Emitted success state');
    } catch (e) {
      if (kDebugMode)
        print(
          '[HomeBloc] _onFavouriteToggled - Operation FAILED with error: $e, Type: ${e.runtimeType}',
        );
      emit(
        current.copyWith(
          favouriteIds: Set<String>.from(current.favouriteIds),
          favouritesLoading: false,
          favouritesError: 'Failed to update favourite. ${e.toString()}',
        ),
      );
      if (kDebugMode)
        print(
          '[HomeBloc] _onFavouriteToggled - Emitted rollback state with error',
        );
    }
  }

  void _onTabCategoriesUpdated(
    _TabCategoriesUpdated event,
    Emitter<HomeState> emit,
  ) {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(tabCategories: event.categories));
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
