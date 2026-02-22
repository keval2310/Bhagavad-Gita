import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import '../../services/gemini_service.dart';
import '../../models/gita_recommendation.dart';
import '../gita_counsellor/recommendation_screen.dart';

class TextAnalysisScreen extends StatefulWidget {
  const TextAnalysisScreen({super.key});

  @override
  State<TextAnalysisScreen> createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends State<TextAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnalyzing = false;
  final GeminiService _geminiService = GeminiService("PLACEHOLDER_KEY");

  Future<void> _analyzeThoughts() async {
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
      // In a real app, Gemini would detect this from the text itself.
      // For now, we use a thoughtful default or mock logic.
      final text = _controller.text.toLowerCase();
      EmotionType detected = EmotionType.neutral;
      
      if (text.contains('sad') || text.contains('lose') || text.contains('hurt')) {
        detected = EmotionType.sadness;
      } else if (text.contains('angry') || text.contains('hate') || text.contains('annoy')) {
        detected = EmotionType.anger;
      } else if (text.contains('worried') || text.contains('fear') || text.contains('future')) {
        detected = EmotionType.anxiety;
      } else if (text.contains('stress') || text.contains('work') || text.contains('hard')) {
        detected = EmotionType.stress;
      } else if (text.contains('happy') || text.contains('joy') || text.contains('great')) {
        detected = EmotionType.joy;
      } else if (text.contains('don\'t know') || text.contains('confused')) {
        detected = EmotionType.confusion;
      }

      final emotion = EmotionState(
        primaryEmotion: detected,
        confidence: 0.85,
        trigger: 'Heart Reflection',
      );

      final recommendation = await _geminiService.getRecommendation(
        _controller.text,
        emotion,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationScreen(
              emotion: emotion,
              recommendation: recommendation,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
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
