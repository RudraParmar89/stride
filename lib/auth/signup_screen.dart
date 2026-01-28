import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ Added for Social Icons
import 'package:lottie/lottie.dart';
import 'package:stride/common/app_loader.dart';
import 'package:stride/auth/auth_service.dart';
import 'package:stride/onboarding/identity_protocol_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ✅ Key to control button state
  final GlobalKey<_HoldToSignupButtonState> _btnKey = GlobalKey();

  // ⚠️ Error States for Comic Bubbles
  String? _emailError;
  String? _passError;

  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  Future<void> _handleAuth(Future userFuture) async {
    if (_isLoading) return;

    setState(() {
      _emailError = null;
      _passError = null;
      _isLoading = true;
    });

    try {
      final user = await userFuture;
      if (user != null && mounted) {
        // SUCCESS ANIMATION
        _btnKey.currentState?.setSuccessState();

        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const IdentityProtocolScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      // 🛑 FAILURE: Map Errors to Bubbles
      String errorMsg = e.toString().toLowerCase();

      setState(() {
        if (errorMsg.contains('email-already-in-use')) {
          _emailError = "This email is already taken!";
        } else if (errorMsg.contains('weak-password')) {
          _passError = "Too weak! Use at least 6 chars.";
        } else if (errorMsg.contains('invalid-email')) {
          _emailError = "Invalid email format.";
        } else if (errorMsg.contains('network')) {
          _passError = "Network Error. Check Internet.";
        } else {
          _passError = "Error: Please try again.";
        }
      });

      // Reset Button
      _btnKey.currentState?.reset();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            clipBehavior: Clip.none, // Allow floating bubbles
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                Center(
                  child: Lottie.asset(
                    'assets/animations/login_animation.json',
                    height: 260,
                    repeat: true,
                    animate: true,
                    fit: BoxFit.contain,
                    frameRate: FrameRate.max,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Start your journey toward discipline.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 20),

                // ---------------- EMAIL INPUT ----------------
                _inputField(
                  controller: emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  errorText: _emailError,
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                ),

                const SizedBox(height: 25),

                // ---------------- PASSWORD INPUT ----------------
                _inputField(
                  controller: passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  errorText: _passError,
                  onChanged: (_) {
                    if (_passError != null) setState(() => _passError = null);
                  },
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),

                const SizedBox(height: 25),

                /// ✅ HOLD TO SIGNUP
                HoldToSignupButton(
                  key: _btnKey,
                  validate: () {
                    setState(() {
                      _emailError = null;
                      _passError = null;
                    });

                    bool isValid = true;

                    // 1. Check Password
                    if (passwordController.text.trim().length < 6) {
                      setState(() => _passError = "Must be at least 6 characters.");
                      isValid = false;
                    }

                    // 2. Check Email
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      setState(() => _emailError = "Email is required!");
                      isValid = false;
                    } else if (!_isValidEmail(email)) {
                      setState(() => _emailError = "Invalid email format!");
                      isValid = false;
                    }

                    return isValid;
                  },
                  onComplete: () => _handleAuth(
                    AuthService.createUserWithEmailAndPassword(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// DIVIDER
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Or sign up with', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 15),

                /// 🌐 SOCIAL LOGIN (Added)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialIcon(
                      asset: 'assets/icons/google.svg',
                      gap: 30,
                      onTap: () => _handleAuth(AuthService.signInWithGoogle()),
                    ),
                    _SocialIcon(
                      asset: 'assets/icons/facebook.svg',
                      gap: 30,
                      onTap: () => _handleAuth(AuthService.signInWithFacebook()),
                    ),
                    _SocialIcon(
                      asset: 'assets/icons/github.svg',
                      onTap: () => _handleAuth(AuthService.signInWithGitHub()),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// LOGIN REDIRECT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? errorText,
    Function(String)? onChanged,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          cursorColor: Colors.black,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: errorText != null ? Colors.redAccent : Colors.grey.shade300,
                  width: errorText != null ? 1.5 : 1.0
              ),
            ),
          ),
        ),

        if (errorText != null)
          Positioned(
            top: -42,
            right: 0,
            child: _ComicBubble(text: errorText),
          ),
      ],
    );
  }
}

// 💬 COMIC BUBBLE COMPONENT
class _ComicBubble extends StatelessWidget {
  final String text;
  const _ComicBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: ClipPath(
            clipper: _DownTriangleClipper(),
            child: Container(width: 14, height: 8, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}

class _DownTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// 🌐 SOCIAL ICON COMPONENT
class _SocialIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final double gap;

  const _SocialIcon({super.key, required this.asset, required this.onTap, this.gap = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(child: SvgPicture.asset(asset, width: 28, height: 28)),
          ),
        ),
        SizedBox(width: gap),
      ],
    );
  }
}

// ================= NUCLEAR HOLD BUTTON (Signup Variant) =================
class HoldToSignupButton extends StatefulWidget {
  final VoidCallback onComplete;
  final bool Function() validate;

  const HoldToSignupButton({super.key, required this.onComplete, required this.validate});

  @override
  State<HoldToSignupButton> createState() => _HoldToSignupButtonState();
}

class _HoldToSignupButtonState extends State<HoldToSignupButton> with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _scaleCtrl;

  bool _isAuthSuccess = false;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..addListener(() { setState(() {}); if (_progressCtrl.value > 0.0 && _progressCtrl.value % 0.1 < 0.02) HapticFeedback.selectionClick(); })
      ..addStatusListener((status) { if (status == AnimationStatus.completed) { HapticFeedback.heavyImpact(); widget.onComplete(); } });

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.95, upperBound: 1.0)..value = 1.0;
  }

  void reset() {
    if (mounted) { setState(() => _isAuthSuccess = false); HapticFeedback.vibrate(); _progressCtrl.reverse(); }
  }

  void setSuccessState() {
    if (mounted) setState(() => _isAuthSuccess = true);
  }

  @override
  void dispose() { _progressCtrl.dispose(); _pulseCtrl.dispose(); _scaleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    double progress = _progressCtrl.value;
    bool isFilled = progress >= 1.0;
    const accent = Colors.black;
    const bg = Color(0xFFF5F5F5);
    const textActive = Colors.white;

    return GestureDetector(
      onTapDown: (_) { if (!widget.validate()) { HapticFeedback.heavyImpact(); return; } HapticFeedback.mediumImpact(); _scaleCtrl.reverse(); _progressCtrl.forward(); },
      onTapUp: (_) { if (_progressCtrl.status != AnimationStatus.completed) { _scaleCtrl.forward(); _progressCtrl.reverse(); } },
      onTapCancel: () { _scaleCtrl.forward(); _progressCtrl.reverse(); },
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressCtrl, _scaleCtrl, _pulseCtrl]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset((_progressCtrl.value < 0.1 ? 0.0 : (DateTime.now().millisecondsSinceEpoch % 2 == 0 ? 1 : -1) * (_progressCtrl.value * 3.0)), 0),
            child: Transform.scale(
              scale: _scaleCtrl.value,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _progressCtrl.isAnimating ? accent : Colors.grey.shade300, width: _progressCtrl.isAnimating ? 1.5 : 1),
                  boxShadow: [
                    if (_progressCtrl.isAnimating) BoxShadow(color: accent.withOpacity(0.2 * progress), blurRadius: 15 * progress, offset: const Offset(0, 5))
                    else BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Center(child: Text("HOLD TO CREATE", style: TextStyle(color: Colors.grey.withOpacity(0.8), fontWeight: FontWeight.w700, letterSpacing: 2.0, fontSize: 14))),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              decoration: BoxDecoration(color: isFilled ? Colors.white : accent),
                              child: Center(
                                child: Text(
                                  _isAuthSuccess ? "ACCOUNT CREATED" : (isFilled ? "REGISTERING..." : "INITIALIZING..."),
                                  style: TextStyle(color: isFilled ? accent : textActive, fontWeight: FontWeight.w900, letterSpacing: 2.0 + (progress * 1), fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}