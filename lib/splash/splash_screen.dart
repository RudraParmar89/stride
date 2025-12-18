import 'dart:async';
import 'package:flutter/material.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  bool _darkBackground = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scale = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Silence
    Timer(const Duration(milliseconds: 600), () {
      _controller.forward();
    });

    // Unified background + logo transition
    Timer(const Duration(milliseconds: 1800), () {
      setState(() {
        _darkBackground = false;
      });
    });

    // Exit → Onboarding
    Timer(const Duration(milliseconds: 2600), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        color: _darkBackground ? Colors.black : Colors.white,
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // White logo (for black background)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _darkBackground ? 1 : 0,
                    child: Image.asset(
                      'assets/logo/stride_light.png',
                      width: 120,
                    ),
                  ),
                  // Dark logo (for white background)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _darkBackground ? 0 : 1,
                    child: Image.asset(
                      'assets/logo/stride_dark.png',
                      width: 120,
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
