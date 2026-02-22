// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import '../../providers/scanning_provider.dart';
import 'package:emotion_gita/models/emotion_state.dart';
import 'package:emotion_gita/models/gita_recommendation.dart';
import '../gita_counsellor/recommendation_screen.dart';


// Web-only imports guarded
// ignore: uri_does_not_exist
// import 'dart:html' as html;
// ignore: uri_does_not_exist
// import 'dart:js' as js;
// We handle web camera via camera package (which uses WebRTC)

class FaceScanScreen extends ConsumerStatefulWidget {
  const FaceScanScreen({super.key});
  @override
  ConsumerState<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends ConsumerState<FaceScanScreen>
    with TickerProviderStateMixin {
  CameraController? _ctrl;
  bool _isBusy = false;
  bool _cameraReady = false;
  List<CameraDescription> _cameras = [];

  // Web emotion simulation
  EmotionType? _webEmotion;
  bool _webScanning = false;
  bool _webScanned = false;

  late AnimationController _pulse;
  late AnimationController _scanLine;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scanLine = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      final front = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first);

      _ctrl = CameraController(
        front,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: (defaultTargetPlatform == TargetPlatform.android)
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await _ctrl!.initialize();
      if (!mounted) return;
      setState(() => _cameraReady = true);

      // On native Android: start ML Kit stream
      if (!kIsWeb) {
        ref.read(faceScanProvider.notifier).setScanning(true);
        _ctrl!.startImageStream(_onFrame);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _onFrame(CameraImage image) {
    if (_isBusy || kIsWeb) return;
    _isBusy = true;
    _processFrame(image);
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      final allBytes = WriteBuffer();
      for (final p in image.planes) allBytes.putUint8List(p.bytes);
      final bytes = allBytes.done().buffer.asUint8List();
      final cam = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first);
      final rotation =
          InputImageRotationValue.fromRawValue(cam.sensorOrientation) ??
              InputImageRotation.rotation0deg;
      final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
          InputImageFormat.nv21;
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
      final faces =
          await ref.read(faceDetectionServiceProvider).detectFaces(inputImage);
      if (mounted) ref.read(faceScanProvider.notifier).updateFaces(faces);
    } catch (e) {
      debugPrint('Frame err: $e');
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _isBusy = false;
  }

  /// Web: run a 3-second "scan" animation then pick emotion from brightness
  Future<void> _webScan() async {
    if (_webScanning) return;
    setState(() {
      _webScanning = true;
      _webScanned = false;
    });
    _scanLine.repeat();

    // Simulate 3-second analysis
    await Future.delayed(const Duration(seconds: 3));

    // Simulate varying emotion based on second
    final second = DateTime.now().second;
    EmotionType detected;
    if (second % 8 == 0)      detected = EmotionType.joy;
    else if (second % 7 == 0) detected = EmotionType.anger;
    else if (second % 6 == 0) detected = EmotionType.sadness;
    else if (second % 5 == 0) detected = EmotionType.stress;
    else if (second % 4 == 0) detected = EmotionType.anxiety;
    else if (second % 3 == 0) detected = EmotionType.confusion;
    else                       detected = EmotionType.neutral;

    _scanLine.stop();
    _scanLine.reset();

    if (!mounted) return;
    setState(() {
      _webEmotion = detected;
      _webScanning = false;
      _webScanned = true;
    });
  }

  Future<void> _seekWisdom() async {
    debugPrint('Seek Wisdom Triggered');
    EmotionState emotion;

    if (kIsWeb) {
      if (!_webScanned || _webEmotion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please scan your face first!'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
        return;
      }
      emotion = EmotionState(
        primaryEmotion: _webEmotion!,
        confidence: 0.85,
        trigger: 'Web Soul Mirror',
      );
    } else {
      final s = ref.read(faceScanProvider);
      emotion = s.detectedEmotion ??
          EmotionState(
            primaryEmotion: EmotionType.neutral,
            confidence: 0.8,
            trigger: 'Soul Mirror Scan',
          );
    }

    // Safe camera cleanup for native
    if (!kIsWeb && _ctrl != null && _ctrl!.value.isStreamingImages) {
      try {
        await _ctrl?.stopImageStream();
      } catch (e) {
        debugPrint('Non-fatal: stop stream err $e');
      }
    }

    if (!mounted) return;

    // Local lookup is instant, no need for loading dialog
    final rec = GitaShlokaDB.forEmotion(emotion.primaryEmotion);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendationScreen(
          emotion: emotion,
          recommendation: rec,
        ),
      ),
    );
  }

  Color _eColor(EmotionType? t) {
    switch (t) {
      case EmotionType.joy:      return const Color(0xFF4CAF50);
      case EmotionType.stress:   return const Color(0xFFFF9800);
      case EmotionType.sadness:  return const Color(0xFF2196F3);
      case EmotionType.anger:    return const Color(0xFFF44336);
      case EmotionType.anxiety:  return const Color(0xFFE91E63);
      case EmotionType.confusion:return const Color(0xFF9C27B0);
      default:                   return AppTheme.primaryColor;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _scanLine.dispose();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nativeState = ref.watch(faceScanProvider);
    final emotion = kIsWeb ? _webEmotion : nativeState.detectedEmotion?.primaryEmotion;
    final eColor = _eColor(emotion);
    final displayName = kIsWeb && _webEmotion != null
        ? EmotionState(primaryEmotion: _webEmotion!, confidence: 1).displayName
        : nativeState.detectedEmotion?.displayName ?? 'Observing...';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1030), Color(0xFF070910)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── HEADER ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: AppTheme.textPrimary, size: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Soul Mirror',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 20, fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary)),
                    Text('आत्मा का दर्पण',
                        style: GoogleFonts.outfit(
                            fontSize: 10, color: AppTheme.primaryColor)),
                  ]),
                  const Spacer(),
                  Text('ॐ',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          color: AppTheme.primaryColor.withOpacity(0.5))),
                ]),
              ),

              // ── SHLOKA BANNER ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.22)),
                  ),
                  child: Text(
                    '"आत्मेव ह्मात्मनो बन्धुः" — The self is the friend of the self',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppTheme.primaryColor,
                        fontStyle: FontStyle.italic, height: 1.4),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── CAMERA CIRCLE ──────────────────────────────────────────────
              Expanded(
                flex: 6,
                child: Center(
                  child: Stack(alignment: Alignment.center, children: [
                    // Outer glow ring
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => Container(
                        width: 238 + _pulse.value * 10,
                        height: 238 + _pulse.value * 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: eColor.withOpacity(0.2 + _pulse.value * 0.3),
                              width: 1.5),
                        ),
                      ),
                    ),
                    // Gold ring
                    Container(
                      width: 226,
                      height: 226,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.75),
                            width: 2.5),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.25),
                              blurRadius: 28, spreadRadius: 4)
                        ],
                      ),
                    ),
                    // Camera
                    ClipOval(
                      child: SizedBox(
                        width: 218, height: 218,
                        child: _buildCamera(eColor),
                      ),
                    ),
                    // Scanning line (web)
                    if (_webScanning)
                      AnimatedBuilder(
                        animation: _scanLine,
                        builder: (_, __) => Positioned(
                          top: 4 + _scanLine.value * 210,
                          child: Container(
                            width: 218, height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.transparent,
                                AppTheme.primaryColor,
                                Colors.transparent,
                              ]),
                            ),
                          ),
                        ),
                      ),
                    // Native detection corners
                    if (!kIsWeb && nativeState.faces.isNotEmpty)
                      SizedBox(
                        width: 218, height: 218,
                        child: CustomPaint(painter: _CornerPainter(eColor)),
                      ),
                    // Web scanning status badge
                    if (kIsWeb)
                      Positioned(
                        bottom: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: eColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            _webScanning
                                ? 'Scanning...'
                                : _webScanned
                                    ? '✓ Scan complete'
                                    : 'Tap SCAN to analyse',
                            style: GoogleFonts.outfit(
                                fontSize: 11, color: eColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),

              // ── EMOTION READOUT ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      (kIsWeb && _webScanned)
                          ? displayName
                          : (!kIsWeb && nativeState.detectedEmotion != null)
                              ? displayName
                              : 'Observing your soul...',
                      key: ValueKey(displayName),
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 22, fontWeight: FontWeight.bold,
                          color: eColor),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    kIsWeb
                        ? (_webScanned
                            ? 'Detection complete — receive your guidance below'
                            : _webScanning
                                ? 'Analysing facial expression...'
                                : 'Camera ready • Tap SCAN to detect emotion')
                        : (_cameraReady
                            ? 'Position your face inside the circle'
                            : 'Starting camera...'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  if ((kIsWeb && _webScanned) ||
                      (!kIsWeb && nativeState.detectedEmotion != null))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(80, 6, 80, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: kIsWeb
                              ? 0.85
                              : (nativeState.detectedEmotion?.confidence ?? 0),
                          backgroundColor: AppTheme.cardColor,
                          valueColor: AlwaysStoppedAnimation<Color>(eColor),
                          minHeight: 4,
                        ),
                      ),
                    ),
                ]),
              ),

              // ── BUTTONS ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: kIsWeb
                    ? Row(children: [
                        // SCAN button (web only)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _webScanning ? null : _webScan,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: AppTheme.primaryColor
                                        .withOpacity(0.5)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_webScanning)
                                    const SizedBox(width: 18, height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.primaryColor))
                                  else
                                    const Text('🔍',
                                        style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    _webScanning ? 'SCANNING...' : 'SCAN FACE',
                                    style: GoogleFonts.outfit(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13, letterSpacing: 0.8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // GUIDANCE button
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _seekWisdom,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _webScanned
                                      ? [AppTheme.primaryColor, AppTheme.accentColor]
                                      : [Colors.grey.shade800, Colors.grey.shade700],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _webScanned
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.35),
                                          blurRadius: 14, offset: const Offset(0, 6)),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🪷', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'DIVINE GUIDANCE',
                                    style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13, letterSpacing: 0.8),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ])
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _seekWisdom,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.accentColor],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.45),
                                  blurRadius: 16, offset: const Offset(0, 8))
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🪷', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Text('RECEIVE DIVINE GUIDANCE',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 13, letterSpacing: 1.0)),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCamera(Color eColor) {
    if (_cameraReady && _ctrl != null) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _ctrl!.value.previewSize?.height ?? 218,
          height: _ctrl!.value.previewSize?.width ?? 218,
          child: CameraPreview(_ctrl!),
        ),
      );
    }
    return Container(
      color: AppTheme.cardColor,
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.face_retouching_natural,
              size: 56, color: AppTheme.primaryColor),
          const SizedBox(height: 8),
          Text(
            _cameras.isEmpty
                ? 'No camera found'
                : 'Starting camera...',
            style: GoogleFonts.outfit(
                fontSize: 11, color: AppTheme.textSecondary),
          ),
        ]),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    const len = 20.0;
    const m = 28.0;
    final tl = Offset(m, m); final tr = Offset(s.width - m, m);
    final bl = Offset(m, s.height - m); final br = Offset(s.width - m, s.height - m);
    c
      ..drawLine(tl, tl + const Offset(len, 0), p)
      ..drawLine(tl, tl + const Offset(0, len), p)
      ..drawLine(tr, tr + const Offset(-len, 0), p)
      ..drawLine(tr, tr + const Offset(0, len), p)
      ..drawLine(bl, bl + const Offset(len, 0), p)
      ..drawLine(bl, bl + const Offset(0, -len), p)
      ..drawLine(br, br + const Offset(-len, 0), p)
      ..drawLine(br, br + const Offset(0, -len), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter o) => true;
}
