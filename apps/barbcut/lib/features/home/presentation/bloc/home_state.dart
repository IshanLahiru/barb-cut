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
  /// UI-ready mapped representations of [haircuts] and [beardStyles].
  /// This avoids repeating mapping work inside the widget tree.
  final List<Map<String, dynamic>> haircutMaps;
  final List<Map<String, dynamic>> beardStyleMaps;
  final Set<String> favouriteIds;
  final bool favouritesLoading;
  final String? favouritesError;
  final List<TabCategoryEntity> tabCategories;

  const HomeLoaded({
    required this.haircuts,
    required this.beardStyles,
    required this.haircutMaps,
    required this.beardStyleMaps,
    this.favouriteIds = const {},
    this.favouritesLoading = false,
    this.favouritesError,
    this.tabCategories = const [],
  });

  @override
  List<Object?> get props => [
        haircuts,
        beardStyles,
        haircutMaps,
        beardStyleMaps,
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
