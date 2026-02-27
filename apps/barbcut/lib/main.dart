import 'package:barbcut/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/style_selection_controller.dart';
import 'services/onboarding_service.dart';
import 'auth_screen.dart';
import 'theme/theme.dart';
import 'core/di/service_locator.dart';
import 'features/auth/domain/entities/auth_user.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'views/questionnaire_view.dart';

class MyApp extends StatefulWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  MyAppState createState() => MyAppState();
}

Future<ThemeController> _initializeThemeController() async {
  final themeController = ThemeController();
  await themeController.initialize();
  return themeController;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // dotenv MUST load first - firebase_options.dart reads FIREBASE_* from .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env: $e');
  }

  // Firebase must initialize before any Firebase-dependent code
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app' || e.code == 'core/duplicate-app') {
      // Already initialized; ignore.
    } else {
      debugPrint('Error setting up authentication: $e');
    }
  } catch (e) {
    debugPrint('Error setting up authentication: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await setupServiceLocator();
  } catch (e) {
    debugPrint('Service locator setup failed: $e');
  }

  final themeController = await _initializeThemeController();

  runApp(MyApp(themeController: themeController));
}

class MyAppState extends State<MyApp> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(getIt<AuthRepository>()),
        ),
        ChangeNotifierProvider.value(value: widget.themeController),
        ChangeNotifierProvider(create: (_) => StyleSelectionController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Barbcut',
            theme: BarbCutTheme.lightTheme,
            darkTheme: BarbCutTheme.darkTheme,
            themeMode: themeController.themeMode,
            debugShowCheckedModeBanner: false,
            home: StreamBuilder<AuthUser?>(
              stream: getIt<AuthRepository>().authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return const OnboardingGate();
                }
                return const AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool? _isCompleted;

  @override
  void initState() {
    super.initState();
    _loadCompletionState();
  }

  Future<void> _loadCompletionState() async {
    try {
      final completed = await OnboardingService()
          .isQuestionnaireCompleted()
          .timeout(const Duration(seconds: 5), onTimeout: () => false);
      if (mounted) {
        setState(() {
          _isCompleted = completed;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCompleted = false);
      }
    }
  }

  Future<void> _handleCompleted() async {
    await OnboardingService().markQuestionnaireCompleted();
    if (mounted) {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isCompleted == true) {
      return const MainScreen();
    }

    return QuestionnaireView(
      isOnboarding: true,
      allowBack: false,
      onCompleted: _handleCompleted,
    );
  }
}
