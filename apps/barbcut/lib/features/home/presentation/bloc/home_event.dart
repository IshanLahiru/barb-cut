import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class FavouriteToggled extends HomeEvent {
  final Map<String, dynamic> item;
  final String styleType;

  const FavouriteToggled({required this.item, required this.styleType});

  @override
  List<Object?> get props => [item['id'], styleType];
}
