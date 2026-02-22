import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../emotion_engine/face_scan_screen.dart';
import '../emotion_engine/text_analysis_screen.dart';
import '../emotion_engine/voice_analysis_screen.dart';
import '../gita_counsellor/recommendation_screen.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import '../../models/gita_recommendation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                              'नमो नमः, Soul',
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryColor, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Featured Quote Card
                    FadeInDown(
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
                              '\"Yoga is the journey of the self, through the self, to the self.\"',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                color: AppTheme.textPrimary,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '- Bhagavad Gita 6.20',
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

                    // Action Cards
                    FadeInUp(
                      child: Column(
                        children: [
                          _ActionCard(
                            title: 'Soul Mirror',
                            subtitle: 'Face scan for emotion',
                            icon: Icons.face_retouching_natural_rounded,
                            imageUrl: 'https://images.unsplash.com/photo-1545389336-cf090694435e?q=80&w=400',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FaceScanScreen()),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ActionCard(
                            title: 'Soul Voice',
                            subtitle: 'Vocal emotional analysis',
                            icon: Icons.mic_none_rounded,
                            imageUrl: 'https://images.unsplash.com/photo-1512438248247-f0f2a5a8b7f0?q=80&w=400',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const VoiceAnalysisScreen()),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _ActionCard(
                            title: 'Heart Reflection',
                            subtitle: 'Journal your thoughts',
                            icon: Icons.auto_stories_outlined,
                            imageUrl: 'https://images.unsplash.com/photo-1455390582262-044cdead277a?q=80&w=800',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TextAnalysisScreen()),
                            ),
                          ),
                        ],
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String imageUrl;
  final VoidCallback onPressed;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.imageUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 120,
        decoration: AppTheme.softCardDecoration,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image with Gradient
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppTheme.surfaceColor,
                      AppTheme.surfaceColor.withOpacity(0.9),
                      AppTheme.surfaceColor.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                    ),
                    child: Icon(icon, color: AppTheme.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.playfairDisplay(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, 
                      color: AppTheme.primaryColor, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
