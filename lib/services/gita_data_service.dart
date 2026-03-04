import 'dart:convert';
import 'package:flutter/services.dart';

class GitaVerse {
  final int sNo;
  final String title;
  final String chapter;
  final String verse;
  final String sanskrit;
  final String hindi;
  final String english;
  final String chapterNumber;

  GitaVerse({
    required this.sNo,
    required this.title,
    required this.chapter,
    required this.verse,
    required this.sanskrit,
    required this.hindi,
    required this.english,
    required this.chapterNumber,
  });

  factory GitaVerse.fromJson(Map<String, dynamic> json) {
    return GitaVerse(
      sNo: json['S.No.'] ?? 0,
      title: json['Title'] ?? '',
      chapter: json['Chapter'] ?? '',
      verse: json['Verse'] ?? '',
      sanskrit: json['Sanskrit Anuvad'] ?? '',
      hindi: json['Hindi Anuvad'] ?? '',
      english: json['Enlgish Translation'] ?? '',
      chapterNumber: json['ChapterNumber'] ?? '',
    );
  }
}

class GitaDataService {
  static List<GitaVerse>? _cachedVerses;

  Future<List<GitaVerse>> loadVerses() async {
    if (_cachedVerses != null) return _cachedVerses!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/gita_verses.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedVerses = jsonList.map((e) => GitaVerse.fromJson(e)).toList();
      return _cachedVerses!;
    } catch (e) {
      print('Error loading Gita data: $e');
      return [];
    }
  }

  /// Search for a verse that matches a keyword or topic
  Future<List<GitaVerse>> searchVerses(String query) async {
    final verses = await loadVerses();
    final words = query.toLowerCase().split(' ').where((w) => w.length > 3).toList();
    if (words.isEmpty) return [];

    // Score verses based on keyword matches
    final scored = verses.map((v) {
      int score = 0;
      final content = (v.english + " " + v.hindi + " " + v.title).toLowerCase();
      for (final word in words) {
        if (content.contains(word)) score++;
      }
      return MapEntry(v, score);
    }).where((entry) => entry.value > 0).toList();

    // Sort by highest score
    scored.sort((a, b) => b.value.compareTo(a.value));
    
    return scored.map((e) => e.key).toList();
  }
}
