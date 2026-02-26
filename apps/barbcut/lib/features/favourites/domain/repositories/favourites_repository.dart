/// Repository for user favourites (haircut/beard styles).
abstract class FavouritesRepository {
  Future<List<Map<String, dynamic>>> getFavourites(String userId);
  Future<void> addFavourite({
    required String userId,
    required Map<String, dynamic> style,
    required String styleType,
  });
  Future<void> removeFavourite({
    required String userId,
    required String styleId,
  });
}
