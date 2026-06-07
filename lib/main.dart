import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'firebase/firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/project_provider.dart';
import 'providers/worker_provider.dart';
import 'providers/labour_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/dashboard_provider.dart';
import 'services/update_service.dart';
import 'themes/app_theme.dart';
import 'utils/constants.dart';
import 'app_router.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for Windows Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Initialize window manager for custom title bar & size
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1440, 900),
    minimumSize: Size(1024, 680),
    center: true,
    title: 'SZ Construction Management',
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Color(0xFF0F0F1A),
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase not configured - run in offline/demo mode
    debugPrint('Firebase init failed: $e');
  }

  runApp(const SZConstructionApp());
}

class SZConstructionApp extends StatelessWidget {
  const SZConstructionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => LabourProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            onGenerateRoute: (settings) =>
                AppRouter.generateRoute(settings, authProvider),
            home: const _SplashScreen(),
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check for updates in background
      final updateService = UpdateService.instance;
      if (await updateService.shouldCheckForUpdates()) {
        updateService.checkForUpdates();
      }
      
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isInitialized) {
        _navigate(auth.isLoggedIn);
      } else {
        auth.addListener(_onAuthInit);
      }
    });
  }

  void _onAuthInit() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isInitialized) {
      auth.removeListener(_onAuthInit);
      _navigate(auth.isLoggedIn);
    }
  }

  void _navigate(bool isLoggedIn) {
    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppConstants.kDashboardRoute);
    } else {
      Navigator.pushReplacementNamed(context, AppConstants.kLoginRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF2196F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.construction, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'SZ Construction',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Management System',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Color(0xFF6C63FF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
