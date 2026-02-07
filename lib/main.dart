import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

// Services
import 'services/notification_service.dart';

// Screens
import 'splash/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'onboarding/identity_protocol_screen.dart';
import 'auth/login_screen.dart';
import 'ascension/ascension_screen.dart';
import 'navigation/app_shell.dart';

// Controllers
import 'controllers/xp_controller.dart';
import 'controllers/task_controller.dart';
import 'selection/mode_controller.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';

// Models
import 'models/user_profile.dart';
import 'models/task.dart'; // ✅ IMPORT THE MODEL

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Force Close to prevent "Box already open" errors during hot restart
  try { await Hive.close(); } catch (_) {}

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Hive.initFlutter();

    // --- 2. REGISTER ADAPTERS (CRITICAL STEP) ---
    // These MUST be registered before opening any boxes

    // Adapter 0: UserProfile
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }

    // Adapter 2: Task (typeId 2 - UserProfile uses 1)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskAdapter());
    }

    // --- 3. OPEN BOXES ---
    await Hive.openBox('stepBox');
    await Hive.openBox('settingsBox');
    await Hive.openBox('statsBox');

    await Hive.openBox<UserProfile>('userBox');

    // ✅ Open 'tasks' box WITH the type
    await Hive.openBox<Task>('tasks');

    await Hive.openBox('chatHistory');
    await Hive.openBox('alarmsBox');
    await Hive.openBox('calendar_events');

    await NotificationService.init();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeManager()),
          ChangeNotifierProvider(create: (_) => XpController()),
          ChangeNotifierProvider(create: (_) => TaskController()),
          ChangeNotifierProvider(create: (_) => ModeController()),
        ],
        child: const StrideApp(),
      ),
    );
  } catch (e) {
    debugPrint("CRITICAL STARTUP ERROR: $e");
    runApp(ErrorApp(error: e.toString()));
  }
}

class StrideApp extends StatelessWidget {
  const StrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeManager themeManager;
    try { themeManager = context.watch<ThemeManager>(); } catch(_) { themeManager = ThemeManager(); }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stride',
      themeMode: themeManager.isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const LoginScreen(),
        '/identity': (context) => const IdentityProtocolScreen(),
        '/home': (context) => const AppShell(),
        '/ascension': (context) => AscensionScreen(
          onComplete: () => Navigator.of(context).pushReplacementNamed('/home'),
        ),
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Startup Error:\n$error", style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
              )
          )
      ),
    );
  }
}