import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emotion_gita/core/app_theme.dart';
import 'package:emotion_gita/features/emotion_engine/face_scan_screen.dart';
import 'package:emotion_gita/features/emotion_engine/text_analysis_screen.dart';
import 'package:emotion_gita/features/emotion_engine/voice_analysis_screen.dart';
import 'package:emotion_gita/features/gita_counsellor/recommendation_screen.dart';
import 'package:emotion_gita/features/emotion_engine/multi_stage_analysis_flow.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import 'package:emotion_gita/models/gita_recommendation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emotion_gita/providers/shloka_provider.dart';
import 'package:emotion_gita/providers/user_provider.dart';
import 'package:emotion_gita/features/auth/login_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyShloka = ref.watch(dailyShlokaProvider);
    final user = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Custom Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'नमो नमः, ${user.name ?? "Soul"}',
                              style: GoogleFonts.outfit(
                                color: AppTheme.primaryColor, 
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Seek Inner Peace',
                              style: GoogleFonts.playfairDisplay(
                                color: AppTheme.textPrimary, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.cardColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                title: Text('Sign Out', style: GoogleFonts.playfairDisplay(color: AppTheme.textPrimary)),
                                content: Text('Would you like to end your current journey?', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('STAY', style: GoogleFonts.outfit(color: AppTheme.textSecondary)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
                                    onPressed: () {
                                      ref.read(userProvider.notifier).logout();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                                        (route) => false,
                                      );
                                    },
                                    child: const Text('LOGOUT'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.logout_rounded, color: AppTheme.primaryColor, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Featured Quote Card
                    dailyShloka.when(
                      data: (rec) => FadeInDown(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: AppTheme.goldCardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('🪷', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'DAILY DHARMA',
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '"${rec.englishTranslation}"',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 18,
                                  color: AppTheme.textPrimary,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '- ${rec.shlokaNumber}',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.primaryColor.withOpacity(0.8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      loading: () => Container(
                        height: 150,
                        alignment: Alignment.center,
                        decoration: AppTheme.glassDecoration,
                        child: const CircularProgressIndicator(color: AppTheme.primaryColor),
                      ),
                      error: (err, stack) => const SizedBox(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Detect Mood Button
                    FadeInUp(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MultiStageAnalysisFlow()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.psychology, color: Colors.white, size: 36),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Detect Mood',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Complete 3 Sacred Steps for Guidance',
                                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Section Title
                    Text(
                      'Divine Analysis',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose a mirror to reflect your soul',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Cards replaced by holistic flow
                    FadeInUp(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.glassDecoration,
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Experience the full journey by clicking the "Detect Mood" button above.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Om Watermark at bottom
                    Center(
                      child: Opacity(
                        opacity: 0.05,
                        child: Text(
                          'ॐ',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 100,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

