import '../repositories/favourites_repository.dart';

class AddFavouriteUseCase {
  AddFavouriteUseCase(this._repository);
  final FavouritesRepository _repository;

  Future<void> call({
    required String userId,
    required Map<String, dynamic> style,
    required String styleType,
  }) =>
      _repository.addFavourite(
        userId: userId,
        style: style,
        styleType: styleType,
      );
}
