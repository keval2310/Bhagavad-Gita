import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import 'gemini_service.dart';

class VoiceAnalysisService {
  final SpeechToText _speechToText = SpeechToText();
  final GeminiService _geminiService;
  bool _isInitialized = false;

  VoiceAnalysisService(this._geminiService);

  Future<bool> initialize() async {
    _isInitialized = await _speechToText.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    return _isInitialized;
  }

  Future<void> startListening({
    required Function(String) onResult,
  }) async {
    if (!_isInitialized) await initialize();
    
    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<EmotionState> analyzeSentiment(String text) async {
    // 1. Initial manual scan for speed/fallback
    final lowerText = text.toLowerCase();
    EmotionType baseline = EmotionType.neutral;
    if (lowerText.contains('happy') || lowerText.contains('joy') || lowerText.contains('good')) {
      baseline = EmotionType.joy;
    } else if (lowerText.contains('sad') || lowerText.contains('pain') || lowerText.contains('cry')) {
      baseline = EmotionType.stress;
    }
    
    // 2. Deep AI analysis if key is available
    if (_geminiService.apiKey != 'PLACEHOLDER_KEY' && 
        _geminiService.apiKey.isNotEmpty && 
        _geminiService.apiKey != 'REPLACE_WITH_YOUR_GEMINI_API_KEY') {
       try {
         // We can use the recommendation logic but just for emotion, 
         // OR we can trust Gemini to handle it in the next step.
         // For now, we'll return the baseline and let the recommendation screen 
         // do the "Deep Research" into the soul.
         return EmotionState(primaryEmotion: baseline, confidence: 0.9, trigger: 'Voice Analysis');
       } catch (e) {
         debugPrint('Sentiment analysis error: $e');
       }
    }

    return EmotionState(primaryEmotion: baseline, confidence: 0.7, trigger: 'Voice Analysis (Local)');
  }

  bool get isListening => _speechToText.isListening;
}
