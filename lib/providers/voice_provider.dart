import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import '../services/voice_analysis_service.dart';
import '../services/gemini_service.dart';
import '../core/config.dart';

class VoiceScanState {
  final String transcript;
  final EmotionState? detectedEmotion;
  final bool isListening;
  final bool isAnalyzing;

  VoiceScanState({
    this.transcript = '',
    this.detectedEmotion,
    this.isListening = false,
    this.isAnalyzing = false,
  });

  VoiceScanState copyWith({
    String? transcript,
    EmotionState? detectedEmotion,
    bool? isListening,
    bool? isAnalyzing,
  }) {
    return VoiceScanState(
      transcript: transcript ?? this.transcript,
      detectedEmotion: detectedEmotion ?? this.detectedEmotion,
      isListening: isListening ?? this.isListening,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
}

class VoiceScanNotifier extends StateNotifier<VoiceScanState> {
  final VoiceAnalysisService _voiceService;

  VoiceScanNotifier(this._voiceService) : super(VoiceScanState());

  void updateTranscript(String text) {
    state = state.copyWith(transcript: text);
  }

  void setListening(bool value) {
    state = state.copyWith(isListening: value);
  }

  Future<void> analyzeTranscription() async {
    if (state.transcript.isEmpty) return;
    state = state.copyWith(isAnalyzing: true);
    final emotion = await _voiceService.analyzeSentiment(state.transcript);
    state = state.copyWith(detectedEmotion: emotion, isAnalyzing: false);
  }
  
  void reset() {
    state = VoiceScanState();
  }
}

// Assumes GeminiService is already provided or available
final voiceAnalysisServiceProvider = Provider((ref) {
  // Replace with actual API key logic if needed
  final gemini = GeminiService(AppConfig.geminiApiKey); 
  return VoiceAnalysisService(gemini);
});

final voiceScanProvider = StateNotifierProvider<VoiceScanNotifier, VoiceScanState>((ref) {
  final service = ref.watch(voiceAnalysisServiceProvider);
  return VoiceScanNotifier(service);
});
