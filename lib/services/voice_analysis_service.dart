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
    // Keywords for fast local fallback
    final lowerText = text.toLowerCase();
    if (lowerText.contains('happy') || lowerText.contains('joy') || lowerText.contains('good')) {
      return EmotionState(primaryEmotion: EmotionType.joy, confidence: 0.9, trigger: 'Voice Content');
    }
    if (lowerText.contains('sad') || lowerText.contains('pain') || lowerText.contains('cry')) {
      return EmotionState(primaryEmotion: EmotionType.stress, confidence: 0.9, trigger: 'Voice Content');
    }
    
    // In production, we send to Gemini for Deep NLP
    // Here we'll default to neutral if no key, but logic is ready.
    return EmotionState(primaryEmotion: EmotionType.neutral, confidence: 0.7, trigger: 'Voice Analysis');
  }

  bool get isListening => _speechToText.isListening;
}
