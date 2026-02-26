import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/ai_generation/data/datasources/ai_job_remote_data_source.dart';
import '../../features/ai_generation/data/datasources/ai_job_remote_data_source_impl.dart';
import '../../features/ai_generation/data/repositories/ai_job_repository_impl.dart';
import '../../features/ai_generation/domain/repositories/ai_job_repository.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/favourites/data/datasources/favourites_remote_data_source.dart';
import '../../features/favourites/data/datasources/favourites_remote_data_source_impl.dart';
import '../../features/favourites/data/repositories/favourites_repository_impl.dart';
import '../../features/favourites/domain/repositories/favourites_repository.dart';
import '../../features/favourites/domain/usecases/add_favourite_usecase.dart';
import '../../features/favourites/domain/usecases/get_favourites_usecase.dart';
import '../../features/favourites/domain/usecases/remove_favourite_usecase.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/datasources/tab_categories_remote_data_source.dart';
import '../../features/home/data/datasources/tab_categories_remote_data_source_impl.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_beard_styles_usecase.dart';
import '../../features/home/domain/usecases/get_haircuts_usecase.dart';
import '../../features/history/data/datasources/history_local_data_source.dart';
import '../../features/history/data/datasources/history_remote_data_source.dart';
import '../../features/history/data/datasources/history_remote_data_source_impl.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_history_usecase.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/datasources/products_remote_data_source_impl.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source_impl.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies for the app
/// Call this in main() before running the app
Future<void> setupServiceLocator() async {
  // External packages / Singletons
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  _setupAuthFeature();
  _setupAiGenerationFeature();
  _setupFavouritesFeature();
  _setupHomeFeature();
  _setupHistoryFeature();
  _setupProductsFeature();
  _setupProfileFeature();
  // etc.
}

void _setupAuthFeature() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
  );
}

void _setupAiGenerationFeature() {
  getIt.registerLazySingleton<AiJobRemoteDataSource>(
    () => AiJobRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<AiJobRepository>(
    () => AiJobRepositoryImpl(
      remoteDataSource: getIt<AiJobRemoteDataSource>(),
    ),
  );
}

void _setupFavouritesFeature() {
  getIt.registerLazySingleton<FavouritesRemoteDataSource>(
    () => FavouritesRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<FavouritesRepository>(
    () => FavouritesRepositoryImpl(
      remoteDataSource: getIt<FavouritesRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<GetFavouritesUseCase>(
    () => GetFavouritesUseCase(getIt<FavouritesRepository>()),
  );
  getIt.registerLazySingleton<AddFavouriteUseCase>(
    () => AddFavouriteUseCase(getIt<FavouritesRepository>()),
  );
  getIt.registerLazySingleton<RemoveFavouriteUseCase>(
    () => RemoveFavouriteUseCase(getIt<FavouritesRepository>()),
  );
}

void _setupHomeFeature() {
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<TabCategoriesRemoteDataSource>(
    () => TabCategoriesRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: getIt<HomeRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetHaircutsUseCase>(
    () => GetHaircutsUseCase(getIt<HomeRepository>()),
  );

  getIt.registerLazySingleton<GetBeardStylesUseCase>(
    () => GetBeardStylesUseCase(getIt<HomeRepository>()),
  );
}

void _setupHistoryFeature() {
  getIt.registerLazySingleton<HistoryLocalDataSource>(
    () => HistoryLocalDataSource(),
  );
  getIt.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl() as HistoryRemoteDataSource,
  );

  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      localDataSource: getIt<HistoryLocalDataSource>(),
      remoteDataSource: getIt<HistoryRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetHistoryUseCase>(
    () => GetHistoryUseCase(getIt<HistoryRepository>()),
  );
}

void _setupProductsFeature() {
  getIt.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(
      remoteDataSource: getIt<ProductsRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(getIt<ProductsRepository>()),
  );
}

void _setupProfileFeature() {
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(getIt<ProfileRepository>()),
  );
}
