import '../repositories/favourites_repository.dart';

class RemoveFavouriteUseCase {
  RemoveFavouriteUseCase(this._repository);
  final FavouritesRepository _repository;

  Future<void> call({
    required String userId,
    required String styleId,
  }) =>
      _repository.removeFavourite(userId: userId, styleId: styleId);
}
