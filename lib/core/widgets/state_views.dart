import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/severity_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _StateLayout(
      tile: _IconTile(
        icon: icon,
        background: colors.surfaceContainerHigh,
        color: colors.onSurfaceVariant,
      ),
      title: title,
      message: message,
      action: actionLabel == null
          ? null
          : FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: onAction,
              icon: Icon(actionIcon ?? LucideIcons.plus, size: 18),
              label: Text(actionLabel!),
            ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Please check your connection and try again.',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final sev = context.severity;

    return _StateLayout(
      tile: _IconTile(
        icon: LucideIcons.circleAlert,
        background: sev.stopTint,
        color: sev.stop,
      ),
      title: title,
      message: message,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Retry'),
            ),
    );
  }
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.tile,
    required this.title,
    required this.message,
    this.action,
  });

  final Widget tile;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile,
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }
}
