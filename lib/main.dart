import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen_v2.dart';
import 'presentation/screens/home/home_screen_v2.dart';
import 'services/permission_service.dart';
import 'services/intent_handler_service.dart';

// Global navigator key for intent handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize intent handler with navigator key
    IntentHandlerService.initialize(navigatorKey: navigatorKey);

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    runApp(const PDFEpubReaderV2());
  } catch (e) {
    debugPrint('Main initialization error: $e');
    runApp(const PDFEpubReaderV2());
  }
}

class PDFEpubReaderV2 extends StatelessWidget {
  const PDFEpubReaderV2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreenV2(),
        '/onboarding': (context) => const OnboardingScreenV2(),
        '/app-initializer': (context) => const AppInitializer(),
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Request storage permissions early
      await _requestPermissions();

      // Mark app as initialized (skip onboarding completely)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.firstLaunchKey, false);
      await prefs.setBool(AppConstants.onboardingCompletedKey, true);

      // Set navigator key for intent handling
      IntentHandlerService.setNavigatorKey(navigatorKey);

      setState(() {
        _isInitializing = false;
      });

      // Check for pending file intents after navigator is ready
      await Future.delayed(const Duration(milliseconds: 500));
      await IntentHandlerService.checkPendingIntents();
    } catch (e) {
      debugPrint('App initialization error: $e');
      // If there's an error, still go to home
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await PermissionService.requestStoragePermission();
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Always go directly to home screen (no onboarding)
    return const HomeScreenV2();
  }
}

// Global error handler
class AppErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    // Log error for debugging
    debugPrint('App Error: $error');
    debugPrint('Stack Trace: $stackTrace');
  }
}

// Global app state (if needed for simple state management)
class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  bool _isDarkMode = false;
  String _currentTheme = AppConstants.lightMode;

  bool get isDarkMode => _isDarkMode;
  String get currentTheme => _currentTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode
        ? AppConstants.darkMode
        : AppConstants.lightMode;
    notifyListeners();
  }

  void setTheme(String theme) {
    _currentTheme = theme;
    _isDarkMode = theme == AppConstants.darkMode;
    notifyListeners();
  }
}
