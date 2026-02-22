import 'recommendation_audio_stub.dart'
    if (dart.library.html) 'recommendation_audio_web.dart';

abstract class RecommendationAudio {
  void play(String url);
  void pause();
  void dispose();

  factory RecommendationAudio() => createAudio();
}
