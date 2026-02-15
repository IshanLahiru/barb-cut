import 'dart:io';
import 'package:barbcut/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/style_selection_controller.dart';
import 'controllers/subscription_controller.dart';
import 'services/auth_service.dart';
import 'services/revenue_cat_service.dart';
import 'auth_screen.dart';
import 'theme/theme.dart';
import 'core/di/service_locator.dart';
import 'core/constants/app_data.dart';

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

Future<void> _initializeRevenueCat() async {
  try {
    final revenueCatService = RevenueCatService();
    await revenueCatService.initialize();
    debugPrint('✅ RevenueCat SDK initialized');
  } catch (e) {
    debugPrint('❌ Failed to initialize RevenueCat: $e');
    // Don't throw - allow app to continue even if RevenueCat fails
  }
}

Future<void> _connectToEmulators() async {
  // For physical iOS/Android devices, use your Mac's local network IP
  // For iOS Simulator/Android Emulator, 127.0.0.1 works, but using your Mac's IP works for both
  // Find your Mac's IP: ifconfig | grep "inet " | grep -v 127.0.0.1

  // Use Mac's IP for all devices to work with both simulators and physical devices
  const emulatorHost = '192.168.31.108'; // Update this to your Mac's local IP

  try {
    // Connect to Firebase Auth Emulator
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    debugPrint('✅ Connected to Auth Emulator at $emulatorHost:9099');

    // Connect to Firestore Emulator
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8081);
    debugPrint('✅ Connected to Firestore Emulator at $emulatorHost:8081');

    // Connect to Storage Emulator
    await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
    debugPrint('✅ Connected to Storage Emulator at $emulatorHost:9199');
  } catch (e) {
    debugPrint('⚠️ Failed to connect to emulators: $e');
    debugPrint(
      'Make sure Firebase emulators are running: cd firebase && npm run emulator:start',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load .env: $e');
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Connect to Firebase Emulators in debug mode
  if (kDebugMode) {
    await _connectToEmulators();
  }

  // Load app data from JSON files
  try {
    await AppData.loadAppData();
  } catch (e) {
    debugPrint('Failed to load AppData: $e');
  }

  // Initialize service locator (core DI setup)
  await setupServiceLocator();

  // Initialize RevenueCat for subscriptions
  await _initializeRevenueCat();

  // Initialize ThemeController
  final themeController = await _initializeThemeController();

  runApp(MyApp(themeController: themeController));
}

class MyAppState extends State<MyApp> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController(AuthService())),
        ChangeNotifierProvider.value(value: widget.themeController),
        ChangeNotifierProvider(create: (_) => StyleSelectionController()),
        ChangeNotifierProvider(
          create: (_) => SubscriptionController(),
          lazy: false,
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Barbcut',
            theme: BarbCutTheme.lightTheme,
            darkTheme: BarbCutTheme.darkTheme,
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

                // Handle authentication state changes
                if (snapshot.hasData && snapshot.data != null) {
                  final user = snapshot.data!;
                  // Link RevenueCat with authenticated user
                  Future.microtask(() async {
                    final subscriptionCtrl =
                        Provider.of<SubscriptionController>(
                          context,
                          listen: false,
                        );
                    await subscriptionCtrl.setUserId(user.uid);
                    await subscriptionCtrl.loadSubscriptionStatus();
                  });
                  return const MainScreen();
                } else {
                  // User logged out
                  Future.microtask(() async {
                    final subscriptionCtrl =
                        Provider.of<SubscriptionController>(
                          context,
                          listen: false,
                        );
                    await subscriptionCtrl.logout();
                  });
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
