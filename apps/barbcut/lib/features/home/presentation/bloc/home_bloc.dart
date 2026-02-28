import 'dart:async';

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

  List<Map<String, dynamic>> _mapStyles(List<StyleEntity> styles) {
    return styles
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'description': e.description,
            'image': e.imageUrl,
            // Full ordered list from styleImages so carousel gets all angles
            'images': e.styleImages.toList(),
            'imagesMap': {
              'front': e.styleImages.front,
              'left_side': e.styleImages.leftSide,
              'right_side': e.styleImages.rightSide,
              'back': e.styleImages.back,
            },
            'suitableFaceShapes': e.suitableFaceShapes,
            'maintenanceTips': e.maintenanceTips,
          },
        )
        .toList();
  }

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
          final favs = await getFavouritesUseCase(user.id);
          favouriteIds = favs.map((f) => f['id'].toString()).toSet();
        } catch (e) {
          favouritesError = e.toString();
        }
      }
      final mappedHaircuts = _mapStyles(haircuts);
      final mappedBeards = _mapStyles(beards);
      emit(HomeLoaded(
        haircuts: haircuts,
        beardStyles: beards,
        haircutMaps: mappedHaircuts,
        beardStyleMaps: mappedBeards,
        favouriteIds: favouriteIds,
        favouritesError: favouritesError,
      ));
      _startTabCategoriesStream();
      return;
    }

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

    final mappedHaircuts = _mapStyles(haircuts);
    final mappedBeards = _mapStyles(beards);

    final loaded = HomeLoaded(
      haircuts: haircuts,
      beardStyles: beards,
      haircutMaps: mappedHaircuts,
      beardStyleMaps: mappedBeards,
      favouriteIds: favouriteIds,
      favouritesError: favouritesError,
    );
    emit(loaded);

    _startTabCategoriesStream();
  }

  void _startTabCategoriesStream() {
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
    emit(
      HomeLoaded(
        haircuts: current.haircuts,
        beardStyles: current.beardStyles,
        haircutMaps: current.haircutMaps,
        beardStyleMaps: current.beardStyleMaps,
        favouriteIds: newIds,
        favouritesError: current.favouritesError,
        tabCategories: current.tabCategories,
      ),
    );
  }

  void _onTabCategoriesUpdated(
    _TabCategoriesUpdated event,
    Emitter<HomeState> emit,
  ) {
    final current = state;
    if (current is HomeLoaded) {
      emit(
        HomeLoaded(
          haircuts: current.haircuts,
          beardStyles: current.beardStyles,
          haircutMaps: current.haircutMaps,
          beardStyleMaps: current.beardStyleMaps,
          favouriteIds: current.favouriteIds,
          favouritesError: current.favouritesError,
          tabCategories: event.categories,
        ),
      );
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
