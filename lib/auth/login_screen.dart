import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../common/app_loader.dart';
import 'auth_service.dart';
import 'signup_screen.dart';

// ✅ IMPORT SYNC SERVICE
import 'package:stride/services/sync_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GlobalKey<_HoldToLoginButtonState> _btnKey = GlobalKey();

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

  // 🔥 NEW: HANDLE FORGOT PASSWORD LOGIC
  Future<void> _handleForgotPassword() async {
    final email = emailController.text.trim();

    // 1. Validation: Email is required to send the link
    if (email.isEmpty) {
      setState(() => _emailError = "Enter email to reset password!");
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = "Invalid email format!");
      return;
    }

    // 2. Send Reset Email via AuthService
    try {
      await AuthService.sendPasswordResetEmail(email);
      if (!mounted) return;

      // 3. Show Success Dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read, color: Colors.green),
              SizedBox(width: 10),
              Text("Recovery Sent"),
            ],
          ),
          content: Text("A password reset link has been sent to:\n$email\n\nCheck your inbox (and spam folder)."),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      );
    } catch (e) {
      // If email doesn't exist or network fail
      setState(() => _emailError = "Account not found or Network Error!");
    }
  }

  Future<void> _handleAuth(Future userFuture) async {
    if (_isLoading) return;

    // Clear errors and start loading
    setState(() {
      _emailError = null;
      _passError = null;
      _isLoading = true;
    });

    try {
      final user = await userFuture;
      if (!mounted) return;

      if (user != null) {
        // Success Animation
        _btnKey.currentState?.setSuccessState();

        await SyncService.downloadData();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/identity', (route) => false);
      }
    } catch (e) {
      // 🛑 FAILURE: Map Firebase Errors to Comic Bubbles
      String errorMsg = e.toString().toLowerCase();

      setState(() {
        if (errorMsg.contains('user-not-found')) {
          _emailError = "Account not found!";
        } else if (errorMsg.contains('wrong-password')) {
          _passError = "Access Denied: Wrong Password";
        } else if (errorMsg.contains('invalid-email')) {
          _emailError = "Invalid Email Format";
        } else if (errorMsg.contains('network')) {
          _passError = "Network Error. Check Internet.";
        } else {
          _passError = "Access Denied."; // Fallback
        }
      });

      // Reset button so user can try again
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
            clipBehavior: Clip.none, // Allow bubbles to float outside
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

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
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  'Enter your details to continue your quest.',
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
                      color: Colors.grey.shade600, // Ensure icon is visible
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),

                const SizedBox(height: 8),

                // ✅ UPDATED: CLICKABLE FORGOT PASSWORD
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _handleForgotPassword, // 🔥 Calls the new function
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600 // Bold it slightly to hint interaction
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ✅ HOLD TO LOGIN
                HoldToLoginButton(
                  key: _btnKey,
                  validate: () {
                    // Local Validation
                    setState(() {
                      _emailError = null;
                      _passError = null;
                    });

                    bool isValid = true;

                    if (passwordController.text.trim().isEmpty) {
                      setState(() => _passError = "Hey! Password is required!");
                      isValid = false;
                    }

                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      setState(() => _emailError = "Identity required here!");
                      isValid = false;
                    } else if (!_isValidEmail(email)) {
                      setState(() => _emailError = "Invalid email format!");
                      isValid = false;
                    }

                    return isValid;
                  },
                  onComplete: () => _handleAuth(
                    AuthService.signInWithEmailAndPassword(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Or sign in with', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 15),

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

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('New to Stride? ', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Create account',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ FIXED: Forced BLACK text color
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
          cursorColor: Colors.black, // Visible Cursor
          style: const TextStyle(color: Colors.black, fontSize: 16), // Visible Text
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: Colors.grey.shade600),
            suffixIcon: suffix,
            // Standard Flutter padding (Matches Signup)
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

        // 💬 COMIC BUBBLE
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
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: ClipPath(
            clipper: _DownTriangleClipper(),
            child: Container(
              width: 14,
              height: 8,
              color: Colors.redAccent,
            ),
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

class _SocialIcon extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final double gap;

  const _SocialIcon({
    super.key,
    required this.asset,
    required this.onTap,
    this.gap = 0,
  });

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
            child: Center(
              child: SvgPicture.asset(
                asset,
                width: 28,
                height: 28,
              ),
            ),
          ),
        ),
        SizedBox(width: gap),
      ],
    );
  }
}

// ================= NUCLEAR HOLD BUTTON =================
class HoldToLoginButton extends StatefulWidget {
  final VoidCallback onComplete;
  final bool Function() validate;

  const HoldToLoginButton({
    super.key,
    required this.onComplete,
    required this.validate,
  });

  @override
  State<HoldToLoginButton> createState() => _HoldToLoginButtonState();
}

class _HoldToLoginButtonState extends State<HoldToLoginButton> with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _scaleCtrl;

  bool _isAuthSuccess = false;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..addListener(() {
        setState(() {});
        if (_progressCtrl.value > 0.0 && _progressCtrl.value % 0.1 < 0.02) {
          HapticFeedback.selectionClick();
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          widget.onComplete();
        }
      });

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
  }

  void reset() {
    if (mounted) {
      setState(() => _isAuthSuccess = false);
      HapticFeedback.vibrate();
      _progressCtrl.reverse();
    }
  }

  void setSuccessState() {
    if (mounted) setState(() => _isAuthSuccess = true);
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown() {
    if (!widget.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    _scaleCtrl.reverse();
    _progressCtrl.forward();
  }

  void _onTapUp() {
    if (_progressCtrl.status != AnimationStatus.completed) {
      _scaleCtrl.forward();
      _progressCtrl.reverse();
    }
  }

  double _getShake() {
    if (_progressCtrl.value < 0.1) return 0.0;
    double intensity = _progressCtrl.value * 3.0;
    return (DateTime.now().millisecondsSinceEpoch % 2 == 0 ? 1 : -1) * intensity;
  }

  @override
  Widget build(BuildContext context) {
    double progress = _progressCtrl.value;
    bool isFilled = progress >= 1.0;

    const accent = Colors.black;
    const bg = Color(0xFFF5F5F5);
    const textIdle = Colors.grey;
    const textActive = Colors.white;

    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapUp(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressCtrl, _scaleCtrl, _pulseCtrl]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_getShake(), 0),
            child: Transform.scale(
              scale: _scaleCtrl.value,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _progressCtrl.isAnimating ? accent : Colors.grey.shade300,
                    width: _progressCtrl.isAnimating ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (_progressCtrl.isAnimating)
                      BoxShadow(
                        color: accent.withOpacity(0.2 * progress),
                        blurRadius: 15 * progress,
                        offset: const Offset(0, 5),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          "HOLD TO ENTER",
                          style: TextStyle(
                            color: textIdle.withOpacity(0.8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isFilled ? Colors.white : accent,
                              ),
                              child: Center(
                                child: Text(
                                  _isAuthSuccess
                                      ? "ACCESS GRANTED"
                                      : (isFilled ? "VERIFYING..." : "AUTHENTICATING..."),
                                  style: TextStyle(
                                    color: isFilled ? accent : textActive,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0 + (progress * 1),
                                    fontSize: 14,
                                  ),
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