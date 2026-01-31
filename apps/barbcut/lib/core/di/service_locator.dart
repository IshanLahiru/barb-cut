import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/data/datasources/home_local_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_beard_styles_usecase.dart';
import '../../features/home/domain/usecases/get_haircuts_usecase.dart';

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
  // _setupProductsFeature();
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
