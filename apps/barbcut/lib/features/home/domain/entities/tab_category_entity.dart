import 'package:equatable/equatable.dart';

class TabCategoryEntity extends Equatable {
  final String title;
  final String type;

  const TabCategoryEntity({required this.title, required this.type});

  @override
  List<Object> get props => [title, type];
}
