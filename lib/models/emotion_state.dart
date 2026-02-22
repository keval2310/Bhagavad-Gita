enum EmotionType {
  stress,
  anxiety,
  anger,
  confusion,
  conflict,
  neutral,
  joy,
  sadness
}

class EmotionState {
  final EmotionType primaryEmotion;
  final double confidence;
  final String? trigger; // Voice, Face, or Text
  final DateTime timestamp;

  EmotionState({
    required this.primaryEmotion,
    required this.confidence,
    this.trigger,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  String get displayName {
    switch (primaryEmotion) {
      case EmotionType.stress: return 'Stressed';
      case EmotionType.anxiety: return 'Anxious';
      case EmotionType.anger: return 'Restless (Anger)';
      case EmotionType.confusion: return 'Confused';
      case EmotionType.conflict: return 'Conflicted';
      case EmotionType.neutral: return 'Neutral';
      case EmotionType.joy: return 'Joyful';
      case EmotionType.sadness: return 'Sorrowful';
    }
  }
}
