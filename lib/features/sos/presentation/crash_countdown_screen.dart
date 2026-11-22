import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/severity_colors.dart';
import '../data/contact_repository.dart';
import '../data/sos_service.dart';

// Shown after a possible crash. If the user doesn't cancel in time,
// the primary contact is called.
class CrashCountdownScreen extends ConsumerStatefulWidget {
  const CrashCountdownScreen({super.key});

  static const seconds = 10;

  @override
  ConsumerState<CrashCountdownScreen> createState() =>
      _CrashCountdownScreenState();
}

class _CrashCountdownScreenState extends ConsumerState<CrashCountdownScreen> {
  int _left = CrashCountdownScreen.seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (_left <= 1) {
      _timer?.cancel();
      _runSos();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _left--);
  }

  Future<void> _runSos() async {
    final contacts = await ref.read(contactsProvider.future);
    if (!mounted) return;

    final sos = ref.read(sosServiceProvider);
    final primary = sos.primaryOf(contacts);
    // Swap to the SOS screen so the SMS button is there when they come back.
    context.pushReplacement('/sos');
    if (primary != null) await sos.call(primary);
  }

  void _cancel() {
    _timer?.cancel();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sev = context.severity;
    final progress = _left / CrashCountdownScreen.seconds;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: sev.stop,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'Possible crash detected',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: sev.stopTint,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calling your emergency contact in',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: sev.stopTint,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox.square(
                  dimension: 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        color: sev.stopTint,
                        backgroundColor: sev.stopTint.withValues(alpha: 0.25),
                      ),
                      Center(
                        child: Text(
                          '$_left',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: sev.stopTint,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: sev.stopTint,
                      foregroundColor: sev.stop,
                      textStyle: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: _cancel,
                    child: const Text('I\'m OK'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
