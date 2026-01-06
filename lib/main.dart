import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Screens
import 'splash/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'ascension/ascension_screen.dart';

// Navigation Shell (WITH CURVED NAVBAR)
import 'navigation/app_shell.dart';

// Controllers
import 'controllers/theme_controller.dart';
import 'controllers/xp_controller.dart';
import 'controllers/task_controller.dart';
import 'selection/mode_controller.dart';

// Theme
import 'theme/app_theme.dart'; // Ensure this file exists from the previous step

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => XpController()),
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => ModeController()),
      ],
      child: const StrideApp(),
    ),
  );
}

class StrideApp extends StatelessWidget {
  const StrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the controller for changes in ThemeMode (System/Light/Dark)
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stride',

      // THEMES (Now using AppTheme class)
      themeMode: themeController.themeMode,
      theme: AppTheme.lightTheme,   // Uses the Light colors defined in AppTheme
      darkTheme: AppTheme.darkTheme, // Uses the Dark colors defined in AppTheme

      // ROUTING
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const LoginScreen(),

        // ⚠️ IMPORTANT:
        // Home now goes to AppShell (NOT dashboard directly)
        '/home': (context) => const AppShell(),

        '/ascension': (context) => const AscensionScreen(),
      },
    );
  }
}