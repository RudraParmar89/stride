import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Screens
import 'splash/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'home/home_dashboard_page.dart';
import 'ascension/ascension_screen.dart';


// Controllers
import 'controllers/theme_controller.dart';
import 'controllers/xp_controller.dart';
import 'controllers/task_controller.dart';
import 'selection/mode_controller.dart';

void main() async {
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
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      themeMode: themeController.themeMode,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),

      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const LoginScreen(),
        '/ascension': (context) => AscensionScreen(),
        '/home': (context) => const HomeDashboardPage(),
      },
    );
  }
}
