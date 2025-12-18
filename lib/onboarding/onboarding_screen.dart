import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stride/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardData> pages = const [
    _OnboardData(
      title: 'Start With Focus.',
      description:
      'Discipline begins with clarity. Stride helps you focus on what truly matters without overwhelming your day.',
      asset: 'assets/illustrations/onboarding/step_1_focus.svg',
    ),
    _OnboardData(
      title: 'Complete Daily Quests.',
      description:
      'Turn everyday actions into meaningful quests. Each completed quest earns tokens that reflect real effort and progress.',
      asset: 'assets/illustrations/onboarding/step_2_daily_quests.svg',
    ),
    _OnboardData(
      title: 'Build Streaks & Momentum.',
      description:
      'Consistency compounds. Every completed task strengthens your streak and fuels long-term progress.',
      asset: 'assets/illustrations/onboarding/step_3_streaks.svg',
    ),
    _OnboardData(
      title: 'Choose Your Play Style.',
      description:
      'Pick Student, Normal, or Personalized mode and experience Stride in a way that fits your goals.',
      asset: 'assets/illustrations/onboarding/step_4_play_style.svg',
    ),
    _OnboardData(
      title: 'Become Your Next Version.',
      description:
      'Stride isn’t just about tasks—it’s about becoming a more focused, disciplined, and intentional version of yourself.',
      asset: 'assets/illustrations/onboarding/step_5_next_version.svg',
    ),
  ];

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Skip (fades out on last)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isLast ? 0 : 1,
              child: IgnorePointer(
                ignoring: isLast,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _goToLogin,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _AnimatedOnboardPage(data: pages[i]),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _index == i ? 22 : 6,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? Colors.black
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Bottom action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: isLast
                  ? _SwipeToStart(onComplete: _goToLogin)
                  : Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Next'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------------------------------------- */
// Animated page (fade + slide)

class _AnimatedOnboardPage extends StatelessWidget {
  final _OnboardData data;
  const _AnimatedOnboardPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: SvgPicture.asset(
                data.asset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------------------------------------- */
// Swipe button (last screen only)

class _SwipeToStart extends StatefulWidget {
  final VoidCallback onComplete;
  const _SwipeToStart({required this.onComplete});

  @override
  State<_SwipeToStart> createState() => _SwipeToStartState();
}

class _SwipeToStartState extends State<_SwipeToStart> {
  double _drag = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 48;

    return Container(
      height: 56,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Swipe to Start',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            left: _drag,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) {
                setState(() {
                  _drag = (_drag + d.delta.dx).clamp(0, width - 56);
                });
              },
              onHorizontalDragEnd: (_) {
                if (_drag > width * 0.6) {
                  HapticFeedback.mediumImpact();
                  widget.onComplete();
                } else {
                  setState(() => _drag = 0);
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------------------------------------------- */

class _OnboardData {
  final String title;
  final String description;
  final String asset;

  const _OnboardData({
    required this.title,
    required this.description,
    required this.asset,
  });
}
