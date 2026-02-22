import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import '../../models/gita_recommendation.dart';
import '../../core/app_theme.dart';
import 'recommendation_audio.dart';

class RecommendationScreen extends StatefulWidget {
  final EmotionState emotion;
  final GitaRecommendation recommendation;

  const RecommendationScreen({
    super.key,
    required this.emotion,
    required this.recommendation,
  });

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  bool _isPlaying = false;
  final RecommendationAudio _audio = RecommendationAudio();

  String _emojiFor(EmotionType t) {
    const map = {
      EmotionType.joy: '😇',
      EmotionType.stress: '😰',
      EmotionType.sadness: '😔',
      EmotionType.anger: '😤',
      EmotionType.anxiety: '😟',
      EmotionType.confusion: '🤔',
      EmotionType.conflict: '⚖️',
      EmotionType.neutral: '🙏',
    };
    return map[t] ?? '🙏';
  }

  Color get _eColor {
    const map = <EmotionType, Color>{
      EmotionType.joy: Color(0xFF4CAF50),
      EmotionType.stress: Color(0xFFFF9800),
      EmotionType.sadness: Color(0xFF2196F3),
      EmotionType.anger: Color(0xFFF44336),
      EmotionType.anxiety: Color(0xFFE91E63),
      EmotionType.confusion: Color(0xFF9C27B0),
      EmotionType.conflict: Color(0xFF00BCD4),
      EmotionType.neutral: AppTheme.primaryColor,
    };
    return map[widget.emotion.primaryEmotion] ?? AppTheme.primaryColor;
  }

  void _toggleChant() {
    if (_isPlaying) {
      _audio.pause();
      setState(() => _isPlaying = false);
    } else {
      _audio.play(widget.recommendation.audioChantUrl);
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rec = widget.recommendation;
    final emotion = widget.emotion;

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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── APP BAR ──────────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: AppTheme.textPrimary, size: 16),
                  ),
                ),
                title: Text('Divine Guidance',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                centerTitle: true,
                actions: [
                  // Audio chant button (web only)
                  if (kIsWeb)
                    GestureDetector(
                      onTap: _toggleChant,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isPlaying
                              ? AppTheme.primaryColor.withOpacity(0.15)
                              : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.5)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.music_note_rounded,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isPlaying ? 'Pause' : 'Chant ♪',
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Emotion Badge ─────────────────────────────────────
                    FadeInDown(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _eColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: _eColor.withOpacity(0.4)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_emojiFor(emotion.primaryEmotion),
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 10),
                            Text(
                              'Guidance for: ${emotion.displayName}',
                              style: GoogleFonts.outfit(
                                  color: _eColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                          ]),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── SHLOKA CARD ───────────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.13),
                              AppTheme.cardColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                const Text('📜',
                                    style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(rec.shlokaNumber,
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.8)),
                              ]),
                              const SizedBox(height: 16),

                              // Sanskrit text
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.2)),
                                ),
                                child: Text(
                                  rec.sanskritText,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 17,
                                    color: AppTheme.primaryColor,
                                    height: 1.9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // English translation
                              Text(
                                rec.englishTranslation,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  height: 1.65,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Commentary ────────────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _card('🕊️', 'Spiritual Commentary',
                        Text(rec.commentary,
                            style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                                height: 1.7))),
                    ),

                    const SizedBox(height: 14),

                    // ── Psychological Tips ────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _card('🧠', 'Psychological Guidance',
                        Column(children: [
                          ...rec.psychologicalTips.asMap().entries.map((e) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        margin: const EdgeInsets.only(
                                            top: 1, right: 10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _eColor.withOpacity(0.15),
                                          border: Border.all(
                                              color:
                                                  _eColor.withOpacity(0.4)),
                                        ),
                                        child: Center(
                                          child: Text('${e.key + 1}',
                                              style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  color: _eColor,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                        ),
                                      ),
                                      Expanded(
                                          child: Text(e.value,
                                              style: GoogleFonts.outfit(
                                                  fontSize: 13,
                                                  color: AppTheme.textPrimary,
                                                  height: 1.5))),
                                    ]),
                              )),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Reflective Prompts ────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _card('💭', 'Reflective Prompts',
                        Column(children: [
                          ...rec.reflectivePrompts.map((q) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _eColor.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: _eColor.withOpacity(0.2)),
                                ),
                                child: Row(children: [
                                  Icon(Icons.lightbulb_outline,
                                      color: _eColor, size: 16),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(q,
                                          style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              color: AppTheme.textPrimary,
                                              height: 1.5))),
                                ]),
                              )),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Breathing Exercise ────────────────────────────────
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: _card('🌬️', 'Pranayama Practice',
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryColor.withOpacity(0.12),
                              ),
                              child: const Text('🫁',
                                  style: TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(rec.breathingExercise,
                                  style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                      height: 1.65)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Audio Chant Banner ────────────────────────────────
                    if (kIsWeb)
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: GestureDetector(
                          onTap: _toggleChant,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppTheme.primaryColor.withOpacity(0.15),
                                AppTheme.accentColor.withOpacity(0.10),
                              ]),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.primaryColor
                                      .withOpacity(0.35)),
                            ),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isPlaying
                                      ? AppTheme.primaryColor.withOpacity(0.2)
                                      : AppTheme.cardColor,
                                  border: Border.all(
                                      color: AppTheme.primaryColor
                                          .withOpacity(0.5)),
                                ),
                                child: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isPlaying
                                            ? 'Playing Sacred Chant...'
                                            : 'Sacred Audio Chant',
                                        style: GoogleFonts.outfit(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                      Text(
                                        _isPlaying
                                            ? 'Tap to pause'
                                            : 'Tap to begin sonic meditation',
                                        style: GoogleFonts.outfit(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11),
                                      ),
                                    ]),
                              ),
                              if (_isPlaying)
                                Row(
                                  children: List.generate(
                                      4,
                                      (i) => AnimatedContainer(
                                            duration: Duration(
                                                milliseconds: 300 + i * 120),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 2),
                                            width: 3,
                                            height: 12.0 +
                                                (i % 2 == 0 ? 8 : 0),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          )),
                                ),
                            ]),
                          ),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String icon, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}
