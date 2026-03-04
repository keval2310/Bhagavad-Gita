import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../../core/app_theme.dart';
import '../../core/permission_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../home/main_navigation_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _omRotate;
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _omRotate = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _navigateToHome();
  }

  @override
  void dispose() {
    _omRotate.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    await PermissionService.requestAll();
    await Future.delayed(const Duration(milliseconds: 3200));

    if (mounted) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // If already logged in, we should ideally refresh provider but 
        // for now let's just go to main screen if we have a user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
            colors: [
              Color(0xFF0A0C18),
              Color(0xFF0D1030),
              Color(0xFF0A0C18),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Subtle network image – Gita / Krishna themed
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: Image.network(
                  'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=800&q=60',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rotating Om
                  ZoomIn(
                    duration: const Duration(milliseconds: 1200),
                    child: AnimatedBuilder(
                      animation: _shimmer,
                      builder: (_, child) => Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryColor
                                  .withOpacity(0.15 + 0.1 * _shimmer.value),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.primaryColor
                                .withOpacity(0.4 + 0.3 * _shimmer.value),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor
                                  .withOpacity(0.2 + 0.2 * _shimmer.value),
                              blurRadius: 40,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Center(
                          child: RotationTransition(
                            turns: _omRotate,
                            child: Text(
                              'ॐ',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 82,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Title
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      'भगवद्गीता',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      'SOUL GUIDE',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: 6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: Text(
                      'Emotion-Aware Divine Counsellor',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.2,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading dots
                  FadeInUp(
                    delay: const Duration(milliseconds: 1400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        return AnimatedBuilder(
                          animation: _shimmer,
                          builder: (_, __) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryColor.withOpacity(
                                  i == 0
                                      ? _shimmer.value
                                      : i == 1
                                          ? 0.6
                                          : 1 - _shimmer.value),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
