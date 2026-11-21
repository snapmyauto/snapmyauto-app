import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';

// Must be held down for [holdFor] so a pocket tap can't call anyone.
class HoldSosButton extends StatefulWidget {
  const HoldSosButton({
    super.key,
    required this.onTriggered,
    this.holdFor = const Duration(seconds: 3),
  });

  final VoidCallback onTriggered;
  final Duration holdFor;

  @override
  State<HoldSosButton> createState() => _HoldSosButtonState();
}

class _HoldSosButtonState extends State<HoldSosButton>
    with SingleTickerProviderStateMixin {
  late final _hold = AnimationController(vsync: this, duration: widget.holdFor)
    ..addListener(_onTick)
    ..addStatusListener(_onStatus);
  int _lastSecond = 0;

  // small buzz each full second while holding
  void _onTick() {
    final second = (_hold.value * widget.holdFor.inSeconds).floor();
    if (_hold.status == AnimationStatus.forward && second > _lastSecond) {
      _lastSecond = second;
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.heavyImpact();
    _hold.reset();
    widget.onTriggered();
  }

  void _start() {
    _lastSecond = 0;
    HapticFeedback.mediumImpact();
    _hold.forward();
  }

  void _stop() {
    if (_hold.isAnimating) _hold.reverse();
  }

  int get _secondsLeft {
    final total = widget.holdFor.inSeconds;
    return (total - _hold.value * total).ceil().clamp(1, total);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sev = context.severity;

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => _start(),
          onTapUp: (_) => _stop(),
          onTapCancel: _stop,
          child: AnimatedBuilder(
            animation: _hold,
            builder: (context, _) {
              final holding = _hold.value > 0;

              return SizedBox.square(
                dimension: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 240,
                      child: CircularProgressIndicator(
                        value: _hold.value,
                        strokeWidth: 10,
                        color: sev.stop,
                        backgroundColor: sev.stopTint,
                      ),
                    ),
                    AnimatedScale(
                      scale: holding ? 0.94 : 1,
                      duration: const Duration(milliseconds: 150),
                      child: Material(
                        color: sev.stop,
                        shape: const CircleBorder(),
                        elevation: holding ? 2 : 6,
                        child: SizedBox.square(
                          dimension: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.phoneCall,
                                size: 44,
                                color: sev.stopTint,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                holding ? '$_secondsLeft' : 'SOS',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  color: sev.stopTint,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Hold for ${widget.holdFor.inSeconds} seconds',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
