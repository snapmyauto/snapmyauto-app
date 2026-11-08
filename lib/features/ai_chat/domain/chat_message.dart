enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.failed = false,
  });

  final ChatRole role;
  final String text;
  // true when the question never got an answer, so it can be retried
  final bool failed;

  bool get fromUser => role == ChatRole.user;

  ChatMessage copyWith({bool? failed}) =>
      ChatMessage(role: role, text: text, failed: failed ?? this.failed);
}
