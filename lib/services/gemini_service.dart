import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/emotion_state.dart';
import '../models/gita_recommendation.dart';

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiService(this.apiKey) {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  Future<GitaRecommendation> getRecommendation(
      String userInput, EmotionState emotion) async {
    // Always use local DB first — instantaneous + offline
    final local = GitaShlokaDB.forEmotion(emotion.primaryEmotion);

    // If a real API key is set, enhance with Gemini
    if (apiKey != 'PLACEHOLDER_KEY' && apiKey.isNotEmpty) {
      try {
        final prompt = '''
You are an Emotion-Aware Bhagavad Gita Counsellor.
The user is feeling ${emotion.displayName} (confidence: ${(emotion.confidence * 100).toInt()}%).
User words: "$userInput"

Starting from this Gita shloka (${local.shlokaNumber}): "${local.sanskritText}"

Write a NEW personalised commentary for this user's exact situation (max 80 words).
Return ONLY a plain JSON object:
{
  "commentary": "..."
}
''';
        final response =
            await _model.generateContent([Content.text(prompt)]);
        final text = response.text ?? '';
        String jsonStr = text;
        if (text.contains('```json')) {
          jsonStr = text.split('```json')[1].split('```')[0].trim();
        } else if (text.contains('```')) {
          jsonStr = text.split('```')[1].split('```')[0].trim();
        }
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        return GitaRecommendation(
          shlokaNumber: local.shlokaNumber,
          sanskritText: local.sanskritText,
          englishTranslation: local.englishTranslation,
          commentary: data['commentary'] ?? local.commentary,
          psychologicalTips: local.psychologicalTips,
          reflectivePrompts: local.reflectivePrompts,
          breathingExercise: local.breathingExercise,
          audioChantUrl: local.audioChantUrl,
        );
      } catch (e) {
        debugPrint('Gemini enhance error: $e');
      }
    }

    return local;
  }
}
