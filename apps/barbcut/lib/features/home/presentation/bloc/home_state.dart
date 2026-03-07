import 'package:equatable/equatable.dart';
import '../../domain/entities/style_entity.dart';
import '../../domain/entities/tab_category_entity.dart';

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
  final Set<String> favouriteIds;
  final bool favouritesLoading;
  final String? favouritesError;
  final List<TabCategoryEntity> tabCategories;

  const HomeLoaded({
    required this.haircuts,
    required this.beardStyles,
    this.favouriteIds = const {},
    this.favouritesLoading = false,
    this.favouritesError,
    this.tabCategories = const [],
  });

  HomeLoaded copyWith({
    List<StyleEntity>? haircuts,
    List<StyleEntity>? beardStyles,
    Set<String>? favouriteIds,
    bool? favouritesLoading,
    String? favouritesError,
    bool clearFavouritesError = false,
    List<TabCategoryEntity>? tabCategories,
  }) {
    return HomeLoaded(
      haircuts: haircuts ?? this.haircuts,
      beardStyles: beardStyles ?? this.beardStyles,
      favouriteIds: favouriteIds ?? this.favouriteIds,
      favouritesLoading: favouritesLoading ?? this.favouritesLoading,
      favouritesError: clearFavouritesError
          ? null
          : (favouritesError ?? this.favouritesError),
      tabCategories: tabCategories ?? this.tabCategories,
    );
  }

  @override
  List<Object?> get props => [
    haircuts,
    beardStyles,
    favouriteIds,
    favouritesLoading,
    favouritesError,
    tabCategories,
  ];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
