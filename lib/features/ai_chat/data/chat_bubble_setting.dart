import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/shared_prefs.dart';

class ChatBubbleNotifier extends Notifier<bool> {
  static const _key = 'chatBubble';

  @override
  bool build() => ref.read(sharedPrefsProvider).getBool(_key) ?? true;

  Future<void> change(bool show) async {
    state = show;
    await ref.read(sharedPrefsProvider).setBool(_key, show);
  }
}

final chatBubbleProvider = NotifierProvider<ChatBubbleNotifier, bool>(
  ChatBubbleNotifier.new,
);
