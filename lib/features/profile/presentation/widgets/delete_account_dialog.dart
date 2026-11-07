import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/severity_colors.dart';
import '../../../auth/data/auth_errors.dart';
import '../../../auth/data/auth_repository.dart';

/// Asks for confirmation (and the password for email users),
/// logs in again, then deletes the account.
Future<void> showDeleteAccountDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _DeleteAccountDialog(),
  );
}

class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final auth = ref.read(authRepositoryProvider);
    if (auth.usesPassword && _password.text.isEmpty) {
      setState(() => _error = 'Enter your password');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await auth.reauthenticate(
        password: auth.usesPassword ? _password.text : null,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = isGoogleCancel(e) ? null : authErrorMessage(e);
      });
      return;
    }

    if (!mounted) return;

    // Close the dialog before deleting. Deleting signs the user out and the
    // router swaps every screen for login, which must not happen while this
    // dialog is still open.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    try {
      await auth.deleteAccount();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final severity = context.severity;
    final usesPassword = ref.read(authRepositoryProvider).usesPassword;

    return AlertDialog(
      title: const Text('Delete account?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your vehicles, scans, reminders and contacts will be deleted. '
            'This can\'t be undone.',
          ),
          const SizedBox(height: 16),
          if (usesPassword)
            TextField(
              controller: _password,
              obscureText: true,
              enabled: !_busy,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            )
          else
            const Text('You\'ll be asked to sign in with Google again.'),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: severity.stop)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: severity.stop),
          onPressed: _busy ? null : _delete,
          child: _busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }
}
