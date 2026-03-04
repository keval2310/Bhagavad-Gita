import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import '../../core/app_theme.dart';
import '../../core/config.dart';
import '../../providers/voice_provider.dart';
import 'package:emotion_gita/models/gita_recommendation.dart';
import 'package:emotion_gita/services/firebase_service.dart';
import 'package:emotion_gita/features/gita_counsellor/recommendation_screen.dart';
import 'package:emotion_gita/services/gemini_service.dart';

class VoiceAnalysisScreen extends ConsumerStatefulWidget {
  final Function(String transcript)? onResult;
  const VoiceAnalysisScreen({super.key, this.onResult});

  @override
  ConsumerState<VoiceAnalysisScreen> createState() =>
      _VoiceAnalysisScreenState();
}

class _VoiceAnalysisScreenState extends ConsumerState<VoiceAnalysisScreen>
    with TickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  bool _speechAvailable = false;
  late AnimationController _micPulse;
  late AnimationController _waveController;

  // Simple waveform bars state
  final List<double> _waveBars = List.filled(20, 0.2);

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(_updateWave);

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) => debugPrint('STT error: $e'),
      onStatus: (s) {
        debugPrint('STT status: $s');
        if (s == 'done' || s == 'notListening') {
          if (ref.read(voiceScanProvider).isListening) {
            ref.read(voiceScanProvider.notifier).setListening(false);
            _micPulse.stop();
            _waveController.stop();
            ref.read(voiceScanProvider.notifier).analyzeTranscription();
          }
        }
      },
    );
    setState(() {});
  }

  void _updateWave() {
    if (!ref.read(voiceScanProvider).isListening) return;
    setState(() {
      for (int i = 0; i < _waveBars.length; i++) {
        _waveBars[i] = 0.15 + (0.85 * (0.3 + 0.7 * (i % 3 == 0 ? 0.8 : 0.4)));
      }
    });
  }

  Future<void> _toggleListening() async {
    final notifier = ref.read(voiceScanProvider.notifier);
    final isListening = ref.read(voiceScanProvider).isListening;

    if (isListening) {
      await _speech.stop();
      notifier.setListening(false);
      _micPulse.stop();
      _waveController.stop();
      setState(() {
        for (int i = 0; i < _waveBars.length; i++) _waveBars[i] = 0.2;
      });
      await notifier.analyzeTranscription();
    } else {
      notifier.reset();
      if (!_speechAvailable) {
        _speechAvailable = await _speech.initialize();
      }
      if (_speechAvailable) {
        notifier.setListening(true);
        _micPulse.repeat(reverse: true);
        _waveController.repeat();
        await _speech.listen(
          onResult: (result) {
            notifier.updateTranscript(result.recognizedWords);
          },
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: false,
          partialResults: true,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone not available on this device/browser.'),
              backgroundColor: AppTheme.accentColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _seekWisdom() async {
    final state = ref.read(voiceScanProvider);
    if (state.transcript.isEmpty) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );

    final gemini = GeminiService(AppConfig.geminiApiKey);
    final firebase = FirebaseService();
    
    List<Map<String, dynamic>> matchedVerses = [];
    String kaggleContext = "";
    
    try {
      matchedVerses = await firebase.searchVersesFromFirestore(state.transcript, 'Neutral');
      if (matchedVerses.isNotEmpty) {
        kaggleContext = "MANDATORY KAGGLE DATASET:\n" + 
          matchedVerses.take(3).map((v) => "- ${v['Sanskrit Anuvad']}").join('\n');
      }
    } catch (_) {}

    GitaRecommendation recommendation;
    try {
      recommendation = await gemini.getRecommendation(state.transcript, additionalContext: kaggleContext);
    } catch (e) {
      if (matchedVerses.isNotEmpty) {
        recommendation = GitaRecommendation.fromFirestore(matchedVerses.first);
      } else {
        recommendation = GitaRecommendation.placeholder();
      }
    }

    if (mounted) Navigator.pop(context);

    if (widget.onResult != null) {
      widget.onResult!(state.transcript);
    } else {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecommendationScreen(
              emotion: EmotionState(primaryEmotion: EmotionType.neutral, confidence: 1.0, trigger: 'Voice Echo'),
              recommendation: recommendation,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _micPulse.dispose();
    _waveController.dispose();
    _speech.stop();
    super.dispose();
  }

  String _emojiFor(EmotionType? t) {
    switch (t) {
      case EmotionType.joy:      return '😇';
      case EmotionType.stress:   return '😰';
      case EmotionType.sadness:  return '😔';
      case EmotionType.anger:    return '😤';
      case EmotionType.anxiety:  return '😟';
      case EmotionType.neutral:  return '🙏';
      default:                   return '✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceScanProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Sacred background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D1030), Color(0xFF0A0C18)],
              ),
            ),
          ),
          // Om watermark
          Positioned(
            bottom: -80,
            left: -80,
            child: Opacity(
              opacity: 0.05,
              child: Text('ॐ',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 300, color: AppTheme.primaryColor)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // ── Header ─────────────────────────────────────────────
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: AppTheme.textPrimary, size: 18),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Soul Voice',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'वाणी से भावनाओं का विश्लेषण',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Shloka Banner ───────────────────────────────────────
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.glassDecoration,
                        child: Text(
                          '"श्रद्धावान् लभते ज्ञानम्" — The faithful one attains wisdom',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Mic Button ──────────────────────────────────────────
                    GestureDetector(
                      onTap: _toggleListening,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse
                          AnimatedBuilder(
                            animation: _micPulse,
                            builder: (_, __) => Container(
                              width: 140 + _micPulse.value * 20,
                              height: 140 + _micPulse.value * 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (state.isListening
                                        ? AppTheme.accentColor
                                        : AppTheme.primaryColor)
                                    .withOpacity(0.08 + _micPulse.value * 0.1),
                              ),
                            ),
                          ),
                          // Middle ring
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.cardColor,
                              border: Border.all(
                                color: state.isListening
                                    ? AppTheme.accentColor
                                    : AppTheme.primaryColor,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (state.isListening
                                          ? AppTheme.accentColor
                                          : AppTheme.primaryColor)
                                      .withOpacity(0.35),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                )
                              ],
                            ),
                            child: Icon(
                              state.isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              size: 44,
                              color: state.isListening
                                  ? AppTheme.accentColor
                                  : AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      state.isListening
                          ? 'Listening... speak openly'
                          : 'Tap mic to speak your heart',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: state.isListening
                            ? AppTheme.accentColor
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Waveform (custom animated bars) ────────────────────
                    SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(_waveBars.length, (i) {
                          final val = state.isListening
                              ? (0.2 +
                                  0.8 *
                                      ((i % 5 == 0)
                                          ? 0.9
                                          : (i % 3 == 0 ? 0.6 : 0.35)))
                              : 0.15;
                          return AnimatedContainer(
                            duration:
                                Duration(milliseconds: 200 + i * 20),
                            width: (size.width - 48) / _waveBars.length - 2,
                            height: 60 * val,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.3),
                                  AppTheme.primaryColor,
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Transcript Card ─────────────────────────────────────
                    FadeInUp(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 130),
                        padding: const EdgeInsets.all(24),
                        decoration: AppTheme.goldCardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🪷',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Words',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.transcript.isEmpty
                                  ? 'Your sacred words will appear here...'
                                  : state.transcript,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: state.transcript.isEmpty
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                                fontStyle: state.transcript.isEmpty
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 20),

                    const SizedBox(height: 24),

                    // ── Action Buttons ─────────────────────────────────────
                    if (state.transcript.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _speech.stop();
                                ref.read(voiceScanProvider.notifier).reset();
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                    color:
                                        AppTheme.primaryColor.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              icon: const Icon(Icons.refresh,
                                  color: AppTheme.textSecondary, size: 18),
                              label: Text('RETRY',
                                  style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: _seekWisdom,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.accentColor
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🙏',
                                        style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'SEEK GITA',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),
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
