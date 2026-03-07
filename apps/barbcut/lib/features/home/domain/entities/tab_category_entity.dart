import 'package:equatable/equatable.dart';

class TabCategoryEntity extends Equatable {
  final String title;
  final String type;

  const TabCategoryEntity({required this.title, required this.type});

  /// Default panel tabs when Firestore tabCategories are not yet loaded or empty.
  /// Keeps the swipe-up panel (Recent, Favourites, Hair, Beard) always visible.
  static const List<TabCategoryEntity> defaultPanelTabs = [
    TabCategoryEntity(title: 'Recent', type: 'recent'),
    TabCategoryEntity(title: 'Favourites', type: 'favourites'),
    TabCategoryEntity(title: 'Hair', type: 'hair'),
    TabCategoryEntity(title: 'Beard', type: 'beard'),
  ];

  @override
  List<Object> get props => [title, type];
}
