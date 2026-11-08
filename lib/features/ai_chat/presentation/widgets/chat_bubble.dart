import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      tooltip: 'Ask AI',
      shape: const CircleBorder(),
      onPressed: () => context.push('/chat'),
      child: const Icon(LucideIcons.sparkles, size: 20),
    );
  }
}
