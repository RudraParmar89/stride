import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StrideApp());
}

class StrideApp extends StatelessWidget {
  const StrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;
  double _scale = 0.98;
  bool _darkBackground = true;

  @override
  void initState() {
    super.initState();

    // Logo reveal
    Future.delayed(const Duration(milliseconds: 420), () {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _opacity = 1;
          _scale = 1.0;
        });
      }
    });

    // Background + logo transition
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _darkBackground = false;
        });
      }
    });

    // Splash → Onboarding
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (mounted) { // Check if the widget is still in the tree
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        color: _darkBackground ? Colors.black : Colors.white,
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: _opacity,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              scale: _scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _darkBackground ? 1 : 0,
                    child: Image.asset(
                      'assets/logo/stride_light.png',
                      width: 250,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _darkBackground ? 0 : 1,
                    child: Image.asset(
                      'assets/logo/stride_dark.png',
                      width: 250,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
