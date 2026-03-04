import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emotion_gita/core/app_theme.dart';
import 'package:emotion_gita/core/config.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import 'package:emotion_gita/services/gemini_service.dart';
import 'package:emotion_gita/services/firebase_service.dart';
import 'package:emotion_gita/models/gita_recommendation.dart';
import 'package:emotion_gita/features/gita_counsellor/recommendation_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emotion_gita/providers/user_provider.dart';

class TextAnalysisScreen extends ConsumerStatefulWidget {
  final Function(String text)? onResult;
  const TextAnalysisScreen({super.key, this.onResult});

  @override
  ConsumerState<TextAnalysisScreen> createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends ConsumerState<TextAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnalyzing = false;
  final GeminiService _geminiService = GeminiService(AppConfig.geminiApiKey);
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _analyzeThoughts() async {
    final user = ref.read(userProvider);
    final userId = user.isLoggedIn ? user.id ?? "anonymous" : "anonymous";
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please share your thoughts first.'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    
    try {
      // --- NEW: Kaggle Fallback logic ---
      List<Map<String, dynamic>> matchedVerses = [];
      String kaggleContext = "";
      try {
        matchedVerses = await _firebaseService.searchVersesFromFirestore(_controller.text, 'Neutral');
        if (matchedVerses.isNotEmpty) {
          kaggleContext = "MANDATORY KAGGLE DATASET:\n" + 
            matchedVerses.take(3).map((v) => "- ${v['Sanskrit Anuvad']}").join('\n');
        }
      } catch (_) {}

      GitaRecommendation recommendation;
      try {
        recommendation = await _geminiService.getRecommendation(_controller.text, additionalContext: kaggleContext);
      } catch (e) {
        if (matchedVerses.isNotEmpty) {
          recommendation = GitaRecommendation.fromFirestore(matchedVerses.first);
        } else {
          recommendation = GitaRecommendation.placeholder();
        }
      }

      // Async save reflection ONLY if this is a standalone screen (no onResult callback)
      if (widget.onResult == null) {
        _firebaseService.saveReflection(
          userId: userId,
          content: _controller.text,
          shlokaRef: recommendation.shlokaNumber,
        );
      }

      if (widget.onResult != null) {
        widget.onResult!(_controller.text);
      } else {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecommendationScreen(
                emotion: EmotionState(primaryEmotion: EmotionType.neutral, confidence: 1.0, trigger: 'Divine Echo'),
                recommendation: recommendation,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('The AI is meditating deeply. Please try again in a moment.'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D1030), Color(0xFF0A0C18)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heart Reflection',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'विचारों का मंथन',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        FadeInDown(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: AppTheme.glassDecoration,
                            child: Column(
                              children: [
                                Icon(Icons.format_quote_rounded, color: AppTheme.primaryColor.withOpacity(0.4), size: 28),
                                const SizedBox(height: 8),
                                Text(
                                  '\"Set thy heart upon thy work, but never on its reward.\"',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 17, 
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.textPrimary.withOpacity(0.9),
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _controller,
                              maxLines: 12,
                              style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textPrimary, height: 1.6),
                              decoration: InputDecoration(
                                hintText: 'Pour your heart out here... What is bothering you?',
                                hintStyle: GoogleFonts.outfit(color: AppTheme.textSecondary.withOpacity(0.3)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(24),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: GestureDetector(
                            onTap: _isAnalyzing ? null : _analyzeThoughts,
                            child: Container(
                              height: 64,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppTheme.primaryColor, AppTheme.accentColor],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isAnalyzing
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                                          const SizedBox(width: 12),
                                          Text(
                                            'SEEK DIVINE WISDOM',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        Opacity(
                          opacity: 0.1,
                          child: Text(
                            '🙏',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
