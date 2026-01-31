import 'package:equatable/equatable.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object> get props => [];
}

class ProductsLoadRequested extends ProductsEvent {
  const ProductsLoadRequested();
}
