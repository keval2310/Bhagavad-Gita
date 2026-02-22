// Web implementation of RecommendationAudio
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'recommendation_audio.dart';

class RecommendationAudioImpl implements RecommendationAudio {
  html.AudioElement? _audio;

  @override
  void play(String url) {
    _audio ??= html.AudioElement(url);
    _audio!.play();
  }

  @override
  void pause() {
    _audio?.pause();
  }

  @override
  void dispose() {
    _audio?.pause();
    _audio = null;
  }
}

RecommendationAudio createAudio() => RecommendationAudioImpl();
