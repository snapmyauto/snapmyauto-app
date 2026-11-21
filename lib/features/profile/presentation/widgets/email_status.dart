import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../../auth/data/auth_repository.dart';

// verified badge, or a button to send the link for email sign-ups
class EmailStatus extends ConsumerStatefulWidget {
  const EmailStatus({super.key});

  @override
  ConsumerState<EmailStatus> createState() => _EmailStatusState();
}

class _EmailStatusState extends ConsumerState<EmailStatus> {
  late bool _verified = ref.read(authRepositoryProvider).emailVerified;
  bool _sent = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final verified = await ref
        .read(authRepositoryProvider)
        .refreshEmailVerified();
    if (mounted) setState(() => _verified = verified);
  }

  Future<void> _send() async {
    setState(() => _busy = true);
    try {
      await ref.read(authRepositoryProvider).sendVerificationEmail();
      if (mounted) setState(() => _sent = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send the link. Try later.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sev = context.severity;
    final theme = Theme.of(context);

    if (_verified) {
      return _Badge(
        icon: LucideIcons.badgeCheck,
        label: 'Email verified',
        color: sev.safe,
        background: sev.safeTint,
      );
    }

    return Column(
      children: [
        _Badge(
          icon: LucideIcons.mailWarning,
          label: 'Email not verified',
          color: sev.soon,
          background: sev.soonTint,
        ),
        const SizedBox(height: 4),
        if (_sent)
          TextButton(
            onPressed: _check,
            child: const Text('I clicked the link, check again'),
          )
        else
          TextButton(
            onPressed: _busy ? null : _send,
            child: Text(_busy ? 'Sending...' : 'Send verification link'),
          ),
        if (_sent)
          Text(
            'Link sent. Check your inbox and spam folder.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
