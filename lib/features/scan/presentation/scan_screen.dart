import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/dashlight_detector.dart';
import '../domain/scan_draft.dart';
import '../domain/scan_record.dart';
import 'widgets/scan_failed_sheet.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  CameraController? _camera;
  bool _torchOn = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    // load the model early so the first scan is fast
    ref.read(dashlightDetectorProvider).load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    super.dispose();
  }

  // free the camera when the app goes to background, get it back on return
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _camera;
    if (state == AppLifecycleState.inactive) {
      if (camera != null) {
        _camera = null;
        camera.dispose();
        if (mounted) setState(() {});
      }
    } else if (state == AppLifecycleState.resumed && _camera == null) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _error = 'No camera found on this device.');
        }
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _torchOn = false;
        _error = null;
      });
    } on CameraException catch (e) {
      final denied = e.code.contains('Denied');
      if (mounted) {
        setState(
          () => _error = denied
              ? 'Camera permission is off. Allow it in Settings, or pick a photo instead.'
              : 'Camera could not start. You can still pick a photo.',
        );
      }
    } catch (_) {
      // emulators with no camera throw a PlatformException instead
      if (mounted) {
        setState(
          () => _error = 'Camera could not start. You can still pick a photo.',
        );
      }
    }
  }

  Future<void> _toggleTorch() async {
    final camera = _camera;
    if (camera == null) return;
    final next = !_torchOn;
    await camera.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    setState(() => _torchOn = next);
  }

  Future<void> _capture() async {
    final camera = _camera;
    if (camera == null || _busy || camera.value.isTakingPicture) return;
    setState(() => _busy = true);
    try {
      final file = await camera.takePicture();
      await _analyse(await file.readAsBytes(), ScanSource.camera);
    } catch (e) {
      _showError('Could not take the photo. Try again.');
    }
  }

  Future<void> _pickPhoto() async {
    if (_busy) return;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    if (file == null) return;
    setState(() => _busy = true);
    await _analyse(await file.readAsBytes(), ScanSource.gallery);
  }

  Future<void> _analyse(Uint8List bytes, ScanSource source) async {
    final DetectionResult result;
    try {
      final detector = ref.read(dashlightDetectorProvider);
      await detector.load();
      result = await detector.detect(bytes);
    } catch (e) {
      _showError('Scan failed. Try again.');
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.detections.isEmpty) {
      final action = await ScanFailedSheet.show(context);
      if (action == ScanFailedAction.pickPhoto) await _pickPhoto();
      return;
    }

    final draft = ScanDraft(photo: bytes, result: result, source: source);
    await _setPreview(false);
    if (!mounted) return;
    await context.push('/scan/review', extra: draft);
    await _setPreview(true);
  }

  // no need to keep the camera running while the review screen is open
  Future<void> _setPreview(bool on) async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    try {
      on ? await camera.resumePreview() : await camera.pausePreview();
    } on CameraException catch (_) {}
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final camera = _camera;
    final ready = camera != null && camera.value.isInitialized;

    // camera screens stay dark in both themes, like the design
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: camera.value.previewSize!.height,
                height: camera.value.previewSize!.width,
                child: CameraPreview(camera),
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _error == null
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
              ),
            ),
          const _ScanFrame(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      _RoundButton(
                        icon: LucideIcons.x,
                        label: 'Close',
                        onTap: () => context.pop(),
                      ),
                      const Spacer(),
                      _RoundButton(
                        icon: _torchOn ? LucideIcons.zap : LucideIcons.zapOff,
                        label: _torchOn ? 'Turn light off' : 'Turn light on',
                        onTap: ready ? _toggleTorch : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Fit the warning lights inside the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundButton(
                        icon: LucideIcons.image,
                        label: 'Pick a photo',
                        onTap: _busy ? null : _pickPhoto,
                        size: 56,
                      ),
                      Semantics(
                        button: true,
                        label: 'Take photo and scan',
                        child: GestureDetector(
                          onTap: ready && !_busy ? _capture : null,
                          child: Container(
                            width: 84,
                            height: 84,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ready ? scheme.primary : Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_busy)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 14),
                    Text(
                      'Checking warning lights...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 48,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              color: onTap == null ? Colors.white38 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.82,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: CustomPaint(painter: _CornerPainter()),
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 34.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, len)
      ..lineTo(0, 0)
      ..lineTo(len, 0)
      ..moveTo(w - len, 0)
      ..lineTo(w, 0)
      ..lineTo(w, len)
      ..moveTo(w, h - len)
      ..lineTo(w, h)
      ..lineTo(w - len, h)
      ..moveTo(len, h)
      ..lineTo(0, h)
      ..lineTo(0, h - len);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
