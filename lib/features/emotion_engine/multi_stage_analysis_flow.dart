import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emotion_gita/core/app_theme.dart';
import 'package:emotion_gita/core/config.dart';
import 'package:emotion_gita/features/emotion_engine/face_scan_screen.dart';
import 'package:emotion_gita/features/emotion_engine/voice_analysis_screen.dart';
import 'package:emotion_gita/features/emotion_engine/text_analysis_screen.dart';
import 'package:emotion_gita/features/emotion_engine/pss_assessment_screen.dart';
import 'package:emotion_gita/features/gita_counsellor/recommendation_screen.dart';
import 'package:emotion_gita/services/gemini_service.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emotion_gita/providers/scanning_provider.dart';
import 'package:emotion_gita/providers/voice_provider.dart';
import 'package:emotion_gita/services/firebase_service.dart';
import 'package:emotion_gita/models/gita_recommendation.dart';
import 'package:emotion_gita/providers/user_provider.dart';

enum FlowStep { overview, face, voice, text, pss, complete }

class MultiStageAnalysisFlow extends ConsumerStatefulWidget {
  const MultiStageAnalysisFlow({super.key});

  @override
  ConsumerState<MultiStageAnalysisFlow> createState() => _MultiStageAnalysisFlowState();
}

class _MultiStageAnalysisFlowState extends ConsumerState<MultiStageAnalysisFlow> {
  FlowStep _currentStep = FlowStep.overview;
  
  // Results
  EmotionState? _faceResult;
  String? _voiceTranscript;
  String? _textJournal;
  int? _pssScore;
  String? _stressLevel;
  bool _isProcessingHolistic = false;

  @override
  void initState() {
    super.initState();
    // Reset any previous scan data when starting a new flow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(faceScanProvider.notifier).reset();
      ref.read(voiceScanProvider.notifier).reset();
    });
  }

  void _onFaceComplete(EmotionState result) {
    setState(() {
      _faceResult = result;
      _currentStep = FlowStep.voice;
    });
  }

  void _onVoiceComplete(String transcript) {
    setState(() {
      _voiceTranscript = transcript;
      _currentStep = FlowStep.text;
    });
  }

  void _onTextComplete(String text) {
    setState(() {
      _textJournal = text;
      _currentStep = FlowStep.pss;
    });
  }

  Future<void> _onPssComplete(int score, String level) async {
    if (_isProcessingHolistic) return;
    setState(() {
      _isProcessingHolistic = true;
      _pssScore = score;
      _stressLevel = level;
      _currentStep = FlowStep.complete;
    });

    // Show loading while generating final holistic wisdom
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D3D),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Synthesizing Divine Wisdom...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white, 
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Merging face, voice, and spirit to find\nyour perfect Bhagavad Gita verse.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final gemini = GeminiService(AppConfig.geminiApiKey);
    
    // Map the score to a more descriptive holistic emotion for the UI and AI
    EmotionType holisticEmotion;
    if (_pssScore! <= 7) holisticEmotion = EmotionType.joy;
    else if (_pssScore! <= 14) holisticEmotion = EmotionType.neutral;
    else if (_pssScore! <= 22) holisticEmotion = EmotionType.sadness;
    else if (_pssScore! <= 28) holisticEmotion = EmotionType.anxiety;
    else if (_pssScore! <= 34) holisticEmotion = EmotionType.stress;
    else holisticEmotion = EmotionType.anger;

    final averageScore = (_pssScore! / 10).toStringAsFixed(1);

    // Build a holistic prompt with strict diversity instructions
    final prompt = """
Act as a profound Bhagavad Gita spiritual counsellor. A user has completed a multi-stage assessment.
YOU MUST PROVIDE A UNIQUE, DEEPLY PERSONALIZED RESPONSE based on these 4 SPECIFIC inputs:

1. FACIAL EXPRESSION: ${_faceResult?.displayName ?? 'Neutral'}
2. VOICE TRANSCRIPT: "${_voiceTranscript ?? 'No voice input'}"
3. HEART JOURNAL: "${_textJournal ?? 'No text input'}"
4. SOUL VIBRATION (Average Stress Score): $averageScore/4.0 (State: $_stressLevel)

CRITICAL INSTRUCTIONS:
- The user is in a state of '$_stressLevel'. Ensure the shloka selection matches this vibration perfectly.
- If the average score is low (0-0.7), focus on 'Abundant Joy', 'Gratitude', and 'Divine Grace'.
- If the average score is medium (0.8-2.6), focus on 'Equanimity', 'Diligence', and 'Balanced Living'.
- If the average score is high (2.7-4.0), focus on 'Inner Strength', 'Surrender to the Divine', and 'Overcoming Sorrow'.
- Compare the transcript and journal to find the root of their feeling. Mention one specific detail from their text in your commentary.
""";

    // --- NEW: Firestore Dataset Integration ---
    final firebaseService = FirebaseService();
    String kaggleContext = "";
    List<Map<String, dynamic>> matchedVerses = [];
    
    try {
      // Search for verses matching the holistic mood from Firestore
      final fullText = "${_textJournal ?? ''} ${_voiceTranscript ?? ''}";
      matchedVerses = await firebaseService.searchVersesFromFirestore(fullText, _faceResult?.displayName ?? 'Neutral');
      
      if (matchedVerses.isNotEmpty) {
        // Shuffle to ensure variety even with same keywords
        matchedVerses.shuffle(); 
        kaggleContext = "MANDATORY KAGGLE DATASET (CHOOSE FROM THIS):\n" + 
          matchedVerses.take(5).map((v) => 
            "${v['Verse']} (${v['Chapter']}):\n"
            "Sanskrit: ${v['Sanskrit Anuvad']}\n"
            "Translation: ${v['Enlgish Translation']}\n"
            "Hindi: ${v['Hindi Anuvad']}"
          ).join('\n---\n');
      }
    } catch (e) {
      // Quietly continue, allowing matchedVerses to remain empty for standard fallback
    }

    GitaRecommendation finalRecommendation;
    try {
      finalRecommendation = await gemini.getRecommendation(prompt, additionalContext: kaggleContext);
    } catch (e) {
      if (matchedVerses.isNotEmpty) {
        finalRecommendation = GitaRecommendation.fromFirestore(matchedVerses.first);
      } else {
        finalRecommendation = GitaRecommendation.placeholder();
      }
    }

    // --- NEW: Save final Holistic Reflection ---
    final user = ref.read(userProvider);
    final userId = user.isLoggedIn ? user.id ?? "anonymous" : "anonymous";
    await firebaseService.saveReflection(
      userId: userId,
      content: _textJournal ?? (_voiceTranscript ?? "Spiritual Consultation"),
      shlokaRef: finalRecommendation.shlokaNumber,
    );

    if (mounted) Navigator.pop(context); // Close loading dialog

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RecommendationScreen(
            emotion: EmotionState(
              primaryEmotion: holisticEmotion, 
              confidence: 1.0, 
              trigger: 'Holistic Synthesis'
            ),
            recommendation: finalRecommendation,
            isHolistic: true,
            pssScore: _pssScore,
            stressLevel: _stressLevel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case FlowStep.overview:
        return _buildOverviewScreen();
      case FlowStep.face:
        return FaceScanScreen(onResult: _onFaceComplete);
      case FlowStep.voice:
        return VoiceAnalysisScreen(onResult: _onVoiceComplete);
      case FlowStep.text:
        return TextAnalysisScreen(onResult: _onTextComplete);
      case FlowStep.pss:
        return PssAssessmentScreen(onComplete: _onPssComplete);
      case FlowStep.complete:
        return const Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }

  Widget _buildOverviewScreen() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1030), Color(0xFF070910)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                FadeInDown(
                  child: Text(
                    'Sacred Analysis',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '3 Steps to Reveal Your Soul',
                  style: GoogleFonts.outfit(color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 60),
                
                _buildStepCard(1, 'Face Scan', 'Capturing your visual essence', _faceResult != null),
                const SizedBox(height: 20),
                _buildStepCard(2, 'Soul Voice', 'Analyzing the vibration of words', _voiceTranscript != null),
                const SizedBox(height: 20),
                _buildStepCard(3, 'Heart Reflection', 'Journaling your deep thoughts', _textJournal != null),
                
                const Spacer(),
                
                FadeInUp(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_faceResult == null) _currentStep = FlowStep.face;
                        else if (_voiceTranscript == null) _currentStep = FlowStep.voice;
                        else _currentStep = FlowStep.text;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 64,
                      decoration: AppTheme.goldCardDecoration.copyWith(
                        gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]),
                      ),
                      child: Center(
                        child: Text(
                          'BEGIN MANDATORY STEPS',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
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
    );
  }

  Widget _buildStepCard(int num, String title, String subtitle, bool isDone) {
    return FadeInRight(
      delay: Duration(milliseconds: num * 100),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration.copyWith(
          border: Border.all(color: isDone ? Colors.green.withOpacity(0.5) : AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone ? Colors.green.withOpacity(0.2) : AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone 
                  ? const Icon(Icons.check, color: Colors.green, size: 20)
                  : Text('$num', style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
