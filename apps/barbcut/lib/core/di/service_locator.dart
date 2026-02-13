import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_beard_styles_usecase.dart';
import '../../features/home/domain/usecases/get_haircuts_usecase.dart';
import '../../features/history/data/datasources/history_remote_data_source.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_history_usecase.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
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

  // Firebase instances
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

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
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
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
  getIt.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
  );

  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      remoteDataSource: getIt<HistoryRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetHistoryUseCase>(
    () => GetHistoryUseCase(getIt<HistoryRepository>()),
  );
}

void _setupProductsFeature() {
  getIt.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
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
    () => ProfileRemoteDataSourceImpl(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
    ),
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
