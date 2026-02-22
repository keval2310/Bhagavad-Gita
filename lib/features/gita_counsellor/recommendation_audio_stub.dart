// Native (mobile/desktop) stub — no audio for now
import 'recommendation_audio.dart';

class RecommendationAudioImpl implements RecommendationAudio {
  @override
  void play(String url) {}
  @override
  void pause() {}
  @override
  void dispose() {}
}

RecommendationAudio createAudio() => RecommendationAudioImpl();
