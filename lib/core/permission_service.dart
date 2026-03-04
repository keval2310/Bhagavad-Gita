import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PermissionService {
  static Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    if (kIsWeb) return true;
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<void> requestAll() async {
    if (kIsWeb) return;
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }
}
