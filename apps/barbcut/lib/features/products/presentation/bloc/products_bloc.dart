import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase getProductsUseCase;

  ProductsBloc({required this.getProductsUseCase})
    : super(const ProductsInitial()) {
    on<ProductsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProductsLoadRequested event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    final result = await getProductsUseCase();

    result.fold(
      (failure) => emit(ProductsFailure(message: failure.toString())),
      (products) => emit(ProductsLoaded(products: products)),
    );
  }
}
