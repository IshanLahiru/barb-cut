import '../../domain/repositories/favourites_repository.dart';
import '../datasources/favourites_remote_data_source.dart';

class FavouritesRepositoryImpl implements FavouritesRepository {
  FavouritesRepositoryImpl({
    required FavouritesRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final FavouritesRemoteDataSource _remote;

  @override
  Future<List<Map<String, dynamic>>> getFavourites(String userId) =>
      _remote.getFavourites(userId);

  @override
  Future<void> addFavourite({
    required String userId,
    required Map<String, dynamic> style,
    required String styleType,
  }) =>
      _remote.addFavourite(
        userId: userId,
        style: style,
        styleType: styleType,
      );

  @override
  Future<void> removeFavourite({
    required String userId,
    required String styleId,
  }) =>
      _remote.removeFavourite(userId: userId, styleId: styleId);
}
