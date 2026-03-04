import 'package:emotion_gita/models/emotion_state.dart';

class GitaRecommendation {
  final String shlokaNumber;
  final String sanskritText;
  final String englishTranslation;
  final String commentary;
  final List<String> psychologicalTips;
  final List<String> reflectivePrompts;
  final String breathingExercise;
  final String audioChantUrl;

  GitaRecommendation({
    required this.shlokaNumber,
    required this.sanskritText,
    required this.englishTranslation,
    required this.commentary,
    required this.psychologicalTips,
    required this.reflectivePrompts,
    required this.breathingExercise,
    this.audioChantUrl = '',
  });

  factory GitaRecommendation.fromFirestore(Map<String, dynamic> data) {
    // The dataset keys are 'Sanskrit Anuvad', 'Enlgish Translation' (with typo), 'Chapter', 'Verse'
    // 'Chapter' and 'Verse' already contain the words "Chapter" and "Verse"
    final ch = data['Chapter'] ?? '?';
    final vs = data['Verse'] ?? '?';
    
    return GitaRecommendation(
      shlokaNumber: "$ch, $vs",
      sanskritText: data['Sanskrit Anuvad'] ?? "",
      englishTranslation: data['Enlgish Translation'] ?? "",
      commentary: data['Hindi Anuvad'] ?? "Please reflect on this sacred verse.",
      psychologicalTips: [
        "Take 3 deep breaths as you absorb this wisdom.",
        "Practice mindful awareness of your thoughts.",
        "Journal about this teaching's relevance."
      ],
      reflectivePrompts: [
        "How does this apply to your life right now?",
        "What is your key takeaway from this verse?"
      ],
      breathingExercise: "Practice Box Breathing: Inhale 4s, Hold 4s, Exhale 4s, Hold 4s.",
      audioChantUrl: '',
    );
  }

  factory GitaRecommendation.placeholder() {
    return GitaRecommendation(
      shlokaNumber: 'Chapter 2, Verse 47',
      sanskritText: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।',
      englishTranslation: 'You have a right to perform your duties, but you are not entitled to the fruits of your actions.',
      commentary: 'Focus on your effort, and release the outcome.',
      psychologicalTips: ['Practice detachment from results.'],
      reflectivePrompts: ['What can I control today?'],
      breathingExercise: 'Deep abdominal breathing.',
    );
  }
}
