import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_beard_styles_usecase.dart';
import '../../features/home/domain/usecases/get_haircuts_usecase.dart';
import '../../features/history/data/datasources/history_local_data_source.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_history_usecase.dart';
import '../../features/products/data/datasources/products_local_data_source.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
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

  // Add more registrations here as features are added
  // Example pattern:
  _setupHomeFeature();
  _setupHistoryFeature();
  _setupProductsFeature();
  _setupProfileFeature();
  // etc.
}

// Feature setup functions will go here
// Example:
void _setupHomeFeature() {
  getIt.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(localDataSource: getIt<HomeLocalDataSource>()),
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

  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(localDataSource: getIt<HistoryLocalDataSource>()),
  );

  getIt.registerLazySingleton<GetHistoryUseCase>(
    () => GetHistoryUseCase(getIt<HistoryRepository>()),
  );
}

void _setupProductsFeature() {
  getIt.registerLazySingleton<ProductsLocalDataSource>(
    () => ProductsLocalDataSource(),
  );

  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(localDataSource: getIt<ProductsLocalDataSource>()),
  );

  getIt.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(getIt<ProductsRepository>()),
  );
}

void _setupProfileFeature() {
  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSource(),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(localDataSource: getIt<ProfileLocalDataSource>()),
  );

  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(getIt<ProfileRepository>()),
  );
}
