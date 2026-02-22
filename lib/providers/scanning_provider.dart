import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import '../services/face_detection_service.dart';

class FaceScanState {
  final List<Face> faces;
  final EmotionState? detectedEmotion;
  final bool isScanning;
  final String? errorMessage;

  FaceScanState({
    this.faces = const [],
    this.detectedEmotion,
    this.isScanning = false,
    this.errorMessage,
  });

  FaceScanState copyWith({
    List<Face>? faces,
    EmotionState? detectedEmotion,
    bool? isScanning,
    String? errorMessage,
  }) {
    return FaceScanState(
      faces: faces ?? this.faces,
      detectedEmotion: detectedEmotion ?? this.detectedEmotion,
      isScanning: isScanning ?? this.isScanning,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FaceScanNotifier extends StateNotifier<FaceScanState> {
  final FaceDetectionService _faceDetectionService;

  FaceScanNotifier(this._faceDetectionService) : super(FaceScanState());

  void setScanning(bool value) {
    state = state.copyWith(isScanning: value);
  }

  void updateFaces(List<Face> faces) {
    EmotionState? bestEmotion;
    if (faces.isNotEmpty) {
      bestEmotion = _faceDetectionService.analyzeEmotion(faces.first);
    }
    state = state.copyWith(faces: faces, detectedEmotion: bestEmotion);
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message);
  }
}

final faceDetectionServiceProvider = Provider((ref) => FaceDetectionService());

final faceScanProvider = StateNotifierProvider<FaceScanNotifier, FaceScanState>((ref) {
  final service = ref.watch(faceDetectionServiceProvider);
  return FaceScanNotifier(service);
});
