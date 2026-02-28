import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barbcut/core/di/service_locator.dart';
import 'package:barbcut/features/ai_generation/domain/repositories/ai_job_repository.dart';
import 'package:barbcut/features/ai_generation/presentation/cubit/generation_status_cubit.dart';
import 'package:barbcut/features/auth/domain/repositories/auth_repository.dart';
import 'package:barbcut/features/favourites/domain/usecases/add_favourite_usecase.dart';
import 'package:barbcut/features/favourites/domain/usecases/get_favourites_usecase.dart';
import 'package:barbcut/features/favourites/domain/usecases/remove_favourite_usecase.dart';
import 'package:barbcut/features/home/data/datasources/tab_categories_remote_data_source.dart';
import 'package:barbcut/features/home/domain/usecases/get_beard_styles_usecase.dart';
import 'package:barbcut/features/home/domain/usecases/get_cached_styles_usecase.dart';
import 'package:barbcut/features/home/domain/usecases/get_haircuts_usecase.dart';
import 'package:barbcut/features/home/presentation/bloc/home_bloc.dart';
import 'package:barbcut/features/home/presentation/pages/home_page.dart';
import 'package:barbcut/features/history/domain/repositories/history_repository.dart';
import 'package:barbcut/features/history/domain/usecases/get_history_usecase.dart';
import 'package:barbcut/features/history/presentation/bloc/history_bloc.dart';
import 'package:barbcut/features/history/presentation/pages/history_page.dart';
import 'package:barbcut/features/products/domain/usecases/get_products_usecase.dart';
import 'package:barbcut/features/products/presentation/bloc/products_bloc.dart';
import 'package:barbcut/features/products/presentation/pages/products_page.dart';
import 'package:barbcut/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:barbcut/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:barbcut/features/profile/presentation/pages/profile_page.dart';
import '../theme/theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return Icon(icon);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      Center(
        key: const PageStorageKey('home_tab'),
        child: HomePage(
          currentIndex: _selectedIndex,
          tabIndex: 0,
          onNavigateToHistory: () => _onItemTapped(1),
        ),
      ),
      Center(
        key: const PageStorageKey('history_tab'),
        child: HistoryPage(
          currentIndex: _selectedIndex,
          tabIndex: 1,
        ),
      ),
      Center(
        key: const PageStorageKey('products_tab'),
        child: ProductsPage(
          currentIndex: _selectedIndex,
          tabIndex: 2,
        ),
      ),
      Center(
        key: const PageStorageKey('profile_tab'),
        child: ProfilePage(
          currentIndex: _selectedIndex,
          tabIndex: 3,
        ),
      ),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<GenerationStatusCubit>(
          create: (_) =>
              GenerationStatusCubit(aiJobRepository: getIt<AiJobRepository>()),
        ),
        BlocProvider<HomeBloc>(
          create: (_) => HomeBloc(
            getHaircutsUseCase: getIt<GetHaircutsUseCase>(),
            getBeardStylesUseCase: getIt<GetBeardStylesUseCase>(),
            getCachedStylesUseCase: getIt<GetCachedStylesUseCase>(),
            getFavouritesUseCase: getIt<GetFavouritesUseCase>(),
            addFavouriteUseCase: getIt<AddFavouriteUseCase>(),
            removeFavouriteUseCase: getIt<RemoveFavouriteUseCase>(),
            authRepository: getIt<AuthRepository>(),
            tabCategoriesDataSource: getIt<TabCategoriesRemoteDataSource>(),
          ),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(
            getHistoryUseCase: getIt<GetHistoryUseCase>(),
            historyRepository: getIt<HistoryRepository>(),
            authRepository: getIt<AuthRepository>(),
          ),
        ),
        BlocProvider<ProductsBloc>(
          create: (_) => ProductsBloc(
            getProductsUseCase: getIt<GetProductsUseCase>(),
          ),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            getProfileUseCase: getIt<GetProfileUseCase>(),
          ),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AdaptiveThemeColors.backgroundSecondary(context),
            boxShadow: [
              BoxShadow(
                color: AdaptiveThemeColors.neonCyan(
                  context,
                ).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home, 0),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.history, 1),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.shopping_bag, 2),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.manage_accounts, 3),
                label: 'Manage',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AdaptiveThemeColors.neonCyan(context),
            unselectedItemColor: AdaptiveThemeColors.textSecondary(context),
            backgroundColor: AdaptiveThemeColors.backgroundSecondary(context),
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedIconTheme: IconThemeData(size: 28),
            unselectedIconTheme: IconThemeData(size: 24),
          ),
        ),
      ),
    );
  }
}
