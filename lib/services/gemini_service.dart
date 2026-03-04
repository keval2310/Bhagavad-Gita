import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import 'package:emotion_gita/models/gita_recommendation.dart';
import 'package:emotion_gita/core/config.dart';

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiService(this.apiKey) {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  /// Dynamically fetches a tailored shloka recommendation based on user input and optional Kaggle data context.
  Future<GitaRecommendation> getRecommendation(String userInput, {String? additionalContext}) async {
    // If no key, fallback immediately to local DB
    if (apiKey == 'PLACEHOLDER_KEY' || apiKey.isEmpty || apiKey == 'REPLACE_WITH_YOUR_GEMINI_API_KEY') {
       throw Exception('Missing API Key');
    }

    try {
      final prompt = '''
You are the Bhagavad Gita AI Counsellor. Your goal is to guide the user through their situation using the wisdom of the Bhagavad Gita.

User says: "$userInput"

Your Task:
1. Deeply analyze the user's situation and intent.
2. Select the EXACT Bhagavad Gita verse (Chapter & Verse) that provides the best wisdom.
3. Provide a personalized spiritual commentary (max 60 words).
4. Provide 2-3 psychological tips and 2 reflective prompts.
5. Provide a short breathing exercise instruction.

Return ONLY a JSON object with this structure:
{
  "shlokaNumber": "Chapter X, Verse Y",
  "sanskritText": "Exact Sanskrit text from the dataset",
  "englishTranslation": "Exact English translation from the dataset",
  "commentary": "Personalized advice...",
  "psychologicalTips": ["Tip 1", "Tip 2"],
  "reflectivePrompts": ["Prompt 1", "Prompt 2"],
  "breathingExercise": "Breathing technique..."
}

MANDATORY DATASET RULES:
1. You MUST choose ONE verse from the 'MANDATORY KAGGLE DATASET' provided below.
2. If the list is provided, pick the most relevant one for the user's mood.
3. Use the EXACT 'Sanskrit' and 'Translation' provided in that list. DO NOT invent your own.
4. Your commentary should be tailored to why this specific Kaggle verse fits the user.

${additionalContext != null ? "MANDATORY KAGGLE DATASET:\n$additionalContext" : "No dataset context available - please use your own knowledge to find an appropriate Bhagavad Gita verse."}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      // Extract JSON from potential markdown markers
      String jsonStr = text;
      if (text.contains('```json')) {
        jsonStr = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        jsonStr = text.split('```')[1].split('```')[0].trim();
      }

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      return GitaRecommendation(
        shlokaNumber: data['shlokaNumber'] ?? "Unknown Verse",
        sanskritText: data['sanskritText'] ?? "",
        englishTranslation: data['englishTranslation'] ?? "",
        commentary: data['commentary'] ?? "Continue your meditation.",
        psychologicalTips: List<String>.from(data['psychologicalTips'] ?? []),
        reflectivePrompts: List<String>.from(data['reflectivePrompts'] ?? []),
        breathingExercise: data['breathingExercise'] ?? "Take a deep breath.",
        audioChantUrl: '', 
      );
    } catch (e) {
      rethrow; 
    }
  }
}

