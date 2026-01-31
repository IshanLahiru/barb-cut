import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies for the app
/// Call this in main() before running the app
Future<void> setupServiceLocator() async {
  // External packages / Singletons
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Add more registrations here as features are added
  // Example pattern:
  // _setupHomeFeature();
  // _setupProductsFeature();
  // etc.
}

// Feature setup functions will go here
// Example:
// void _setupHomeFeature() {
//   // Data sources
//   getIt.registerSingleton<HomeRemoteDataSource>(
//     HomeRemoteDataSourceImpl(getIt<ApiClient>()),
//   );
//
//   // Repository
//   getIt.registerSingleton<HomeRepository>(
//     HomeRepositoryImpl(
//       remoteDataSource: getIt<HomeRemoteDataSource>(),
//       networkInfo: getIt<NetworkInfo>(),
//     ),
//   );
//
//   // Use cases
//   getIt.registerSingleton<GetHaircutsUseCase>(
//     GetHaircutsUseCase(getIt<HomeRepository>()),
//   );
//
//   // BLoC
//   getIt.registerSingleton<HomeBloc>(
//     HomeBloc(useCase: getIt<GetHaircutsUseCase>()),
//   );
// }
