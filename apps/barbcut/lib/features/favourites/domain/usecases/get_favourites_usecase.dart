import '../repositories/favourites_repository.dart';

class GetFavouritesUseCase {
  GetFavouritesUseCase(this._repository);
  final FavouritesRepository _repository;

  Future<List<Map<String, dynamic>>> call(String userId) =>
      _repository.getFavourites(userId);
}
