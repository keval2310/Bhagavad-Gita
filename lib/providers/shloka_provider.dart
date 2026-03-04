import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emotion_gita/models/gita_recommendation.dart';
import 'package:emotion_gita/services/firebase_service.dart';

final dailyShlokaProvider = FutureProvider<GitaRecommendation>((ref) async {
  final firebase = FirebaseService();
  // Fetch a random selection to pick one as the daily shloka
  final verses = await firebase.searchVersesFromFirestore("wisdom peace duty", "Neutral");
  if (verses.isNotEmpty) {
    verses.shuffle();
    return GitaRecommendation.fromFirestore(verses.first);
  }
  return GitaRecommendation.placeholder();
});
