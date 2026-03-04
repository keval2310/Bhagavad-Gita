import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch a specific shloka from Firestore.
  /// Expects a collection named 'shlokas' with documents indexed by shloka_number.
  Future<Map<String, dynamic>?> fetchShloka(String shlokaNumber) async {
    try {
      final doc = await _db.collection('shlokas').doc(shlokaNumber).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint('Firestore query error: $e');
    }
    return null;
  }

  /// Save a user's journaling reflection.
  /// Fetches matching verses from the 'emotions' collection in Firestore based on keyword search.
  Future<List<Map<String, dynamic>>> searchVersesFromFirestore(String query, String emotion) async {
    try {
      // Clean query and extract keywords
      final words = query.toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(RegExp(r'\s+'))
          .where((w) => w.length >= 3)
          .toList();
      
      // Also add the emotion to the words for better matching
      words.add(emotion.toLowerCase());

      final snapshot = await _db.collection('emotions').get();
      if (snapshot.docs.isEmpty) return [];

      final allDocs = snapshot.docs.map((doc) => doc.data()).toList();
      
      // 1. Try keyword matching
      final matched = allDocs.where((data) {
        final textToSearch = "${data['Enlgish Translation']} ${data['Hindi Anuvad']} ${data['Title']}".toLowerCase();
        return words.any((word) => textToSearch.contains(word));
      }).toList();

      if (matched.isNotEmpty) {
        matched.shuffle();
        return matched.take(10).toList();
      }

      // 2. Fallback: If no keywords match, return 5 random verses from the dataset
      // This ensures the AI always has actual Kaggle data to work with.
      allDocs.shuffle();
      return allDocs.take(5).toList();
    } catch (e) {
      debugPrint('Firestore Search Error: $e');
      return [];
    }
  }

  Future<void> saveReflection({
    required String content,
    required String shlokaRef,
    String? userId,
  }) async {
    try {
      // Always try to get the real current user ID if not provided
      final effectiveUserId = userId ?? _auth.currentUser?.uid ?? 'anonymous';
      
      await _db.collection('user_reflections').add({
        'user_id': effectiveUserId,
        'content': content,
        'shloka_ref': shlokaRef,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving reflection: $e');
    }
  }

  /// Registers a new user using Firebase Auth and stores profile in Firestore.
  Future<bool> registerUser(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'name': name,
          'created_at': FieldValue.serverTimestamp(),
          'role': 'user',
        });
        return true;
      }
    } catch (e) {
      debugPrint('Firebase registration error: $e');
    }
    return false;
  }

  /// Logs in a user using Firebase Auth and fetches profile from Firestore.
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final doc = await _db.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          data['id'] = userCredential.user!.uid; // Map UID to id for compatibility
          return data;
        }
      }
    } catch (e) {
      debugPrint('Firebase login error: $e');
    }
    return null;
  }

  /// Toggles a shloka as a favorite for a user.
  Future<void> toggleFavorite(String userId, String shlokaId) async {
    try {
      final favRef = _db.collection('users').doc(userId).collection('favorites').doc(shlokaId);
      final doc = await favRef.get();

      if (!doc.exists) {
        await favRef.set({
          'shloka_id': shlokaId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await favRef.delete();
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }

  /// Logs a user's spiritual activity.
  Future<void> logActivity(String userId, String type, {String? ref}) async {
    try {
      await _db.collection('user_activity_log').add({
        'user_id': userId,
        'activity_type': type,
        'shloka_ref': ref,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Log activity error: $e');
    }
  }

  /// Updates app preferences for a user.
  Future<void> updatePreferences(String userId, String lang, String theme) async {
    try {
      await _db.collection('users').doc(userId).collection('settings').doc('preferences').set({
        'preferred_language': lang,
        'theme_mode': theme,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Update preferences error: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
