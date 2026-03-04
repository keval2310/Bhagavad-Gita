import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';

class PssAssessmentScreen extends StatefulWidget {
  final Function(int totalScore, String stressLevel) onComplete;

  const PssAssessmentScreen({super.key, required this.onComplete});

  @override
  State<PssAssessmentScreen> createState() => _PssAssessmentScreenState();
}

class _PssAssessmentScreenState extends State<PssAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<int?> _answers = List.filled(10, null);

  final List<String> _questions = [
    "In the last month, how often have you been upset because of something that happened unexpectedly?",
    "In the last month, how often have you felt that you were unable to control the important things in your life?",
    "In the last month, how often have you felt nervous and stressed?",
    "In the last month, how often have you felt confident about your ability to handle your personal problems?",
    "In the last month, how often have you felt things were going your way?",
    "In the last month, how often have you found that you could not cope with all the things that you had to do?",
    "In the last month, how often have you been able to control irritations in your life?",
    "In the last month, how often have you felt that you were on top of things?",
    "In the last month, how often have you been angered because of things that happened that were outside of your control?",
    "In the last month, how often have you felt difficulties were piling up so high that you could not overcome them?",
  ];

  final List<String> _options = [
    "Never",
    "Almost Never",
    "Sometimes",
    "Fairly Often",
    "Very Often"
  ];

  bool _isAssessmentFinishing = false;

  void _nextQuestion() {
    if (_currentPage < 9) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishAssessment();
    }
  }

  void _finishAssessment() {
    if (_isAssessmentFinishing) return;
    setState(() => _isAssessmentFinishing = true);

    int totalScore = 0;
    for (int i = 0; i < 10; i++) {
      int score = _answers[i] ?? 0;
      // Questions 4, 5, 7, and 8 are reversed
      if (i == 3 || i == 4 || i == 6 || i == 7) {
        score = 4 - score;
      }
      totalScore += score;
    }

    String emotionalState;
    if (totalScore <= 7) {
      emotionalState = "Abundant Joy & Peace";
    } else if (totalScore <= 13) {
      emotionalState = "Calm & Balanced";
    } else if (totalScore <= 20) {
      emotionalState = "Mild Distress / Sorrow";
    } else if (totalScore <= 27) {
      emotionalState = "Significant Stress / Anxiety";
    } else if (totalScore <= 34) {
      emotionalState = "Deep Sorrow / Heavy Burden";
    } else {
      emotionalState = "Overwhelming Turmoil";
    }

    widget.onComplete(totalScore, emotionalState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppTheme.glassDecoration,
                      child: const Icon(Icons.close, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stress Assessment',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / 10,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          key: ValueKey('q_$index'),
                          child: Text(
                            "Question ${index + 1} of 10",
                            style: GoogleFonts.outfit(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInDown(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            _questions[index],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 22,
                              color: AppTheme.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        ...List.generate(5, (optionIndex) {
                          bool isSelected = _answers[index] == optionIndex;
                          return FadeInUp(
                            delay: Duration(milliseconds: 200 + (optionIndex * 50)),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _answers[index] = optionIndex);
                                  Future.delayed(const Duration(milliseconds: 200), _nextQuestion);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.1),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                          ),
                                          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                                        ),
                                        child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _options[optionIndex],
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
