import 'package:barbcut/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/auth_service.dart';
import 'auth_screen.dart';
import 'theme/app_theme.dart';

class MyApp extends StatefulWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  _MyAppState createState() => _MyAppState();
}

Future<ThemeController> _initializeThemeController() async {
  final themeController = ThemeController();
  await themeController.initialize();
  return themeController;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env: $e');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize ThemeController
  final themeController = await _initializeThemeController();

  runApp(MyApp(themeController: themeController));
}

class _MyAppState extends State<MyApp> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(AuthService())),
        ChangeNotifierProvider.value(value: widget.themeController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Barbcut',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            debugShowCheckedModeBanner: false,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  return const MainScreen();
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
