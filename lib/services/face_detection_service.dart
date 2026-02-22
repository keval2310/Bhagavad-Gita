import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:emotion_gita/models/emotion_state.dart';

class FaceDetectionService {
  FaceDetector? _faceDetector;
  bool _isInitialized = false;

  FaceDetectionService() {
    _initDetector();
  }

  void _initDetector() {
    if (kIsWeb) return;
    
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    _isInitialized = true;
  }

  Future<List<Face>> detectFaces(InputImage inputImage) async {
    if (kIsWeb || !_isInitialized || _faceDetector == null) return [];
    try {
      return await _faceDetector!.processImage(inputImage);
    } catch (e) {
      debugPrint("Face detection error: $e");
      return [];
    }
  }

  EmotionState analyzeEmotion(Face face) {
    double? smileProb = face.smilingProbability;
    double? leftEyeOpen = face.leftEyeOpenProbability;
    double? rightEyeOpen = face.rightEyeOpenProbability;
    
    // Higher-order emotion logic based on ML Kit classifications
    
    // 1. JOY / HAPPINESS
    if (smileProb != null && smileProb > 0.6) {
      return EmotionState(
        primaryEmotion: EmotionType.joy,
        confidence: smileProb,
        trigger: 'Smiling Expression',
      );
    }

    // 2. SURPRISE (High eye openness)
    if ((leftEyeOpen ?? 0) > 0.95 && (rightEyeOpen ?? 0) > 0.95 && (smileProb ?? 0) < 0.1) {
      return EmotionState(
        primaryEmotion: EmotionType.confusion,
        confidence: 0.85,
        trigger: 'Surprised Features',
      );
    }

    // 3. STRESS / ANGER / SADNESS (Low eye probability or low smile)
    if (smileProb != null && smileProb < 0.05) {
      double eyeAvg = ((leftEyeOpen ?? 1.0) + (rightEyeOpen ?? 1.0)) / 2;
      
      if (eyeAvg < 0.3) {
        return EmotionState(
          primaryEmotion: EmotionType.anger,
          confidence: 1.0 - eyeAvg,
          trigger: 'Furrowed Brow/Squint',
        );
      }
      
      if (eyeAvg < 0.6) {
        return EmotionState(
          primaryEmotion: EmotionType.stress,
          confidence: 0.8,
          trigger: 'Tense Features',
        );
      }

      return EmotionState(
        primaryEmotion: EmotionType.sadness,
        confidence: 0.75,
        trigger: 'Somber Expression',
      );
    }

    return EmotionState(
      primaryEmotion: EmotionType.neutral,
      confidence: 0.9,
      trigger: 'Stable Soul',
    );
  }

  void dispose() {
    _faceDetector?.close();
  }
}
