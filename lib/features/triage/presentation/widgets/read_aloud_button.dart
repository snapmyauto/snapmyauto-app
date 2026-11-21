import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReadAloudButton extends StatefulWidget {
  final String text;
  // starts reading as soon as the page opens
  final bool autoStart;

  const ReadAloudButton({
    super.key,
    required this.text,
    this.autoStart = false,
  });

  @override
  State<ReadAloudButton> createState() => _ReadAloudButtonState();
}

class _ReadAloudButtonState extends State<ReadAloudButton> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _setUpTts();
  }

  Future<void> _setUpTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    _tts.setCompletionHandler(_onStopped);
    _tts.setCancelHandler(_onStopped);
    _tts.setErrorHandler((message) => _onStopped());
    if (widget.autoStart && mounted) await _onPressed();
  }

  void _onStopped() {
    if (!mounted) return;
    setState(() {
      _isSpeaking = false;
    });
  }

  Future<void> _onPressed() async {
    if (_isSpeaking) {
      await _tts.stop();
      _onStopped();
      return;
    }
    setState(() {
      _isSpeaking = true;
    });
    await _tts.speak(widget.text);
  }

  @override
  void dispose() {
    // stop talking when leaving the page
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton.filledTonal(
      tooltip: _isSpeaking ? 'Stop reading' : 'Read aloud',
      style: IconButton.styleFrom(
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.primary,
      ),
      icon: Icon(_isSpeaking ? LucideIcons.square : LucideIcons.volume2),
      onPressed: _onPressed,
    );
  }
}
