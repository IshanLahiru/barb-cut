/// Remote data source for user favourites (Firestore users/{userId}/favourites).
abstract class FavouritesRemoteDataSource {
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
