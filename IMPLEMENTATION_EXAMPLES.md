# Clean Architecture Implementation Examples

## 1️⃣ CORE LAYER - Failure Handling

### File: `lib/core/errors/failure.dart`

```dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

// Specific failures
class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure(String message) : super(message);
}

// For Either type
import 'package:dartz/dartz.dart';
// Use: Either<Failure, SuccessType>
```

## 2️⃣ DOMAIN LAYER - Entities & Interfaces

### File: `lib/features/home/domain/entities/haircut_entity.dart`

```dart
// Pure Dart object - no Flutter dependencies
class HaircutEntity {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final Color accentColor;
  final double rating;

  HaircutEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.accentColor,
    required this.rating,
  });

  // Equality for testing
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HaircutEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
```

### File: `lib/features/home/domain/repositories/home_repository.dart`

```dart
// CONTRACT - Implementation details hidden
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<HaircutEntity>>> getHaircuts();
  Future<Either<Failure, List<HaircutEntity>>> getBeardStyles();
  Future<Either<Failure, void>> searchStyles(String query);
}
```

### File: `lib/features/home/domain/usecases/get_haircuts_usecase.dart`

```dart
import 'package:dartz/dartz.dart';

// UseCase orchestrates repository + validation + business logic
class GetHaircutsUseCase {
  final HomeRepository repository;

  GetHaircutsUseCase(this.repository);

  Future<Either<Failure, List<HaircutEntity>>> call() async {
    // Could add caching, validation, etc. here
    return await repository.getHaircuts();
  }
}
```

## 3️⃣ DATA LAYER - Repositories & Models

### File: `lib/features/home/data/models/haircut_model.dart`

```dart
// Extends entity + adds JSON serialization
import 'package:barbcut/features/home/domain/entities/haircut_entity.dart';

class HaircutModel extends HaircutEntity {
  HaircutModel({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required Color accentColor,
    required double rating,
  }) : super(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    accentColor: accentColor,
    rating: rating,
  );

  // From JSON (API response)
  factory HaircutModel.fromJson(Map<String, dynamic> json) {
    return HaircutModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      accentColor: Color(int.parse(json['accentColor'])),
      rating: (json['rating'] as num).toDouble(),
    );
  }

  // To JSON (for local storage)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'accentColor': accentColor.value.toString(),
    'rating': rating,
  };
}
```

### File: `lib/features/home/data/datasources/home_remote_datasource.dart`

```dart
// API calls - separate from repository logic
abstract class HomeRemoteDataSource {
  Future<List<HaircutModel>> getHaircuts();
  Future<List<HaircutModel>> getBeardStyles();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<HaircutModel>> getHaircuts() async {
    try {
      final response = await apiClient.get('/haircuts');
      final haircuts = (response as List)
          .map((json) => HaircutModel.fromJson(json))
          .toList();
      return haircuts;
    } catch (e) {
      throw ServerException('Failed to fetch haircuts');
    }
  }

  @override
  Future<List<HaircutModel>> getBeardStyles() async {
    // Similar implementation
    throw UnimplementedError();
  }
}
```

### File: `lib/features/home/data/datasources/home_local_datasource.dart`

```dart
// Local cache - separates caching logic
abstract class HomeLocalDataSource {
  Future<List<HaircutModel>> getCachedHaircuts();
  Future<void> cacheHaircuts(List<HaircutModel> haircuts);
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences prefs;
  static const HAIRCUTS_CACHE_KEY = 'cached_haircuts';

  HomeLocalDataSourceImpl(this.prefs);

  @override
  Future<List<HaircutModel>> getCachedHaircuts() async {
    final jsonString = prefs.getString(HAIRCUTS_CACHE_KEY);
    if (jsonString == null) {
      throw CacheException('No cached haircuts');
    }
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => HaircutModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> cacheHaircuts(List<HaircutModel> haircuts) async {
    final jsonList = haircuts.map((h) => h.toJson()).toList();
    await prefs.setString(
      HAIRCUTS_CACHE_KEY,
      jsonEncode(jsonList),
    );
  }
}
```

### File: `lib/features/home/data/repositories/home_repository_impl.dart`

```dart
// REPOSITORY IMPLEMENTATION - Combines datasources
import 'package:dartz/dartz.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<HaircutEntity>>> getHaircuts() async {
    // Strategy: Try remote → Cache it → Return
    // Fallback: Return cached → Return failure
    try {
      if (await networkInfo.isConnected) {
        final remoteHaircuts = await remoteDataSource.getHaircuts();
        // Cache for offline access
        await localDataSource.cacheHaircuts(remoteHaircuts);
        return Right(remoteHaircuts);
      } else {
        // No internet - try cache
        final cachedHaircuts = await localDataSource.getCachedHaircuts();
        return Right(cachedHaircuts);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<HaircutEntity>>> getBeardStyles() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> searchStyles(String query) async {
    throw UnimplementedError();
  }
}
```

## 4️⃣ PRESENTATION LAYER - BLoC State Management

### File: `lib/features/home/presentation/bloc/home_event.dart`

```dart
part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class GetHaircutsEvent extends HomeEvent {
  const GetHaircutsEvent();
}

class GetBeardStylesEvent extends HomeEvent {
  const GetBeardStylesEvent();
}

class SearchHaircutsEvent extends HomeEvent {
  final String query;
  const SearchHaircutsEvent(this.query);

  @override
  List<Object> get props => [query];
}
```

### File: `lib/features/home/presentation/bloc/home_state.dart`

```dart
part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<HaircutEntity> haircuts;
  const HomeLoaded(this.haircuts);

  @override
  List<Object> get props => [haircuts];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
```

### File: `lib/features/home/presentation/bloc/home_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHaircutsUseCase getHaircutsUseCase;

  HomeBloc({required this.getHaircutsUseCase}) 
    : super(const HomeInitial()) {
    on<GetHaircutsEvent>(_onGetHaircuts);
    on<SearchHaircutsEvent>(_onSearchHaircuts);
  }

  Future<void> _onGetHaircuts(
    GetHaircutsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    
    final result = await getHaircutsUseCase();
    
    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (haircuts) => emit(HomeLoaded(haircuts)),
    );
  }

  Future<void> _onSearchHaircuts(
    SearchHaircutsEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Search logic here
  }
}
```

### File: `lib/features/home/presentation/pages/home_page.dart`

```dart
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const GetHaircutsEvent()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Haircuts')),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return HaircutGrid(haircuts: state.haircuts);
            } else if (state is HomeError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
```

## 5️⃣ DEPENDENCY INJECTION - GetIt Setup

### File: `lib/core/di/service_locator.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External packages
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  final apiClient = ApiClient();
  getIt.registerSingleton<ApiClient>(apiClient);

  // FEATURE: Home
  _setupHomeFeature();
}

void _setupHomeFeature() {
  // Data sources
  getIt.registerSingleton<HomeRemoteDataSource>(
    HomeRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  
  getIt.registerSingleton<HomeLocalDataSource>(
    HomeLocalDataSourceImpl(getIt<SharedPreferences>()),
  );

  // Repository
  getIt.registerSingleton<HomeRepository>(
    HomeRepositoryImpl(
      remoteDataSource: getIt<HomeRemoteDataSource>(),
      localDataSource: getIt<HomeLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  // Use cases
  getIt.registerSingleton<GetHaircutsUseCase>(
    GetHaircutsUseCase(getIt<HomeRepository>()),
  );

  // BLoC
  getIt.registerSingleton<HomeBloc>(
    HomeBloc(getHaircutsUseCase: getIt<GetHaircutsUseCase>()),
  );
}
```

### File: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbcut',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}
```

## 6️⃣ SHARED WIDGETS - Atomic Design

### File: `lib/shared/widgets/atoms/app_button.dart`

```dart
// Atom: Smallest reusable unit - NO business logic
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? context.colors.primary,
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              label,
              style: TextStyle(color: textColor ?? Colors.white),
            ),
    );
  }
}
```

### File: `lib/shared/widgets/molecules/product_card.dart`

```dart
// Molecule: Combination of atoms + some UI logic
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isSelected;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? context.colors.primary : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Image.network(product.imageUrl),
            const SizedBox(height: 8),
            Text(product.name, style: context.textTheme.titleMedium),
            Text(product.price, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
```

### File: `lib/shared/widgets/organisms/image_carousel.dart`

```dart
// Organism: Complex component with multiple molecules
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final Function(int) onPageChanged;

  const ImageCarousel({
    Key? key,
    required this.images,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: widget.onPageChanged,
          itemCount: widget.images.length,
          itemBuilder: (context, index) => Image.network(widget.images[index]),
        ),
        const SizedBox(height: 16),
        DotsIndicator(count: widget.images.length),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
```

## 7️⃣ THEME CENTRALIZATION

### File: `lib/core/theme/app_theme.dart`

```dart
// NEVER: Colors.blue hardcoded in screens
// ALWAYS: Use this centralized theme

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      // ... more styles
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(Brightness brightness) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      // ... more styling
    );
  }
}

class AppColors {
  static const primary = Color(0xFF90CAF9);
  static const secondary = Color(0xFFD7AC61);
  static const error = Color(0xFFD94A4A);
  // ... more colors
}
```

### File: `lib/core/theme/theme_extensions.dart`

```dart
// Context extensions - use in any widget
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
}

// Usage in widgets:
// ✅ DO THIS:
Text('Hello', style: context.textTheme.titleMedium)
// ❌ DON'T DO THIS:
Text('Hello', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
```

## 📋 Testing Examples

### File: `test/features/home/domain/usecases/get_haircuts_usecase_test.dart`

```dart
void main() {
  late GetHaircutsUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetHaircutsUseCase(mockRepository);
  });

  test('Should return haircuts when successful', () async {
    // Arrange
    final haircuts = [HaircutEntity(...)];
    when(mockRepository.getHaircuts())
        .thenAnswer((_) async => Right(haircuts));

    // Act
    final result = await useCase();

    // Assert
    expect(result, Right(haircuts));
    verify(mockRepository.getHaircuts());
  });

  test('Should return failure when repository fails', () async {
    // Arrange
    final failure = ServerFailure('Error');
    when(mockRepository.getHaircuts())
        .thenAnswer((_) async => Left(failure));

    // Act
    final result = await useCase();

    // Assert
    expect(result, Left(failure));
  });
}
```

## 🔄 Benefits of This Architecture

| Aspect | Benefit |
|--------|---------|
| **Testability** | Each layer tested independently with mocks |
| **Scalability** | Add features without modifying existing code |
| **Maintainability** | Clear separation of concerns |
| **Reusability** | Shared widgets & utilities used everywhere |
| **Flexibility** | Swap Firebase → REST API without UI changes |
| **Team Collaboration** | Developers can work on features independently |

## 🚀 Next Steps

1. Create `/core` folder with base architecture
2. Migrate existing themes to `core/theme`
3. Move `ai_buttons.dart` to `shared/widgets/atoms`
4. Refactor one feature (`home`) as blueprint
5. Apply same pattern to other features
6. Add unit tests progressively
