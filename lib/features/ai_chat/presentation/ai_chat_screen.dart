import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/severity_colors.dart';
import '../../../core/widgets/severity_badge.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../../vehicles/domain/vehicle.dart';
import '../data/ai_chat_repository.dart';
import '../domain/chat_context.dart';
import '../domain/chat_message.dart';

const _maxQuestions = 20;

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key, this.chatContext = const ChatContext()});

  final ChatContext chatContext;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  AiChat? _chat;
  bool _waiting = false;

  int get _asked => _messages.where((m) => m.fromUser).length;
  bool get _limitReached => _asked >= _maxQuestions;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Vehicle? _vehicle(List<Vehicle> vehicles) {
    final id = widget.chatContext.vehicleId;
    for (final v in vehicles) {
      if (v.id == id) return v;
    }
    // with only one car it must be that one
    return vehicles.length == 1 ? vehicles.first : null;
  }

  AiChat _session() {
    return _chat ??= ref
        .read(aiChatRepositoryProvider)
        .start(
          widget.chatContext.describe(
            _vehicle(ref.read(vehiclesProvider).value ?? const []),
          ),
        );
  }

  Future<void> _send(String text) async {
    final question = text.trim();
    if (question.isEmpty || _waiting || _limitReached) return;
    _input.clear();
    setState(() {
      _messages.add(ChatMessage(role: ChatRole.user, text: question));
      _waiting = true;
    });
    _scrollDown();
    await _ask(_messages.length - 1);
  }

  Future<void> _retry(int index) async {
    if (_waiting) return;
    setState(() {
      _messages[index] = _messages[index].copyWith(failed: false);
      _waiting = true;
    });
    await _ask(index);
  }

  Future<void> _ask(int index) async {
    try {
      final answer = await _session().send(_messages[index].text);
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(role: ChatRole.assistant, text: answer));
        _waiting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages[index] = _messages[index].copyWith(failed: true);
        _waiting = false;
      });
    }
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final chatContext = widget.chatContext;
    final vehicle = _vehicle(ref.watch(vehiclesProvider).value ?? const []);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              child: const Icon(LucideIcons.sparkles, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SnapMyAuto AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  chatContext.hasScan || vehicle != null
                      ? 'Knows your scan & vehicle'
                      : 'Ask about your car',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: context.severity.safe,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              children: [
                if (chatContext.hasScan)
                  Center(
                    child: _ContextChip(
                      chatContext: chatContext,
                      vehicle: vehicle,
                    ),
                  ),
                if (_messages.isEmpty) const _Welcome(),
                for (final (i, m) in _messages.indexed)
                  _Bubble(
                    message: m,
                    onRetry: m.failed ? () => _retry(i) : null,
                  ),
                if (_waiting) const _TypingBubble(),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
              child: Column(
                children: [
                  if (_messages.isEmpty)
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final s in chatContext.suggestions())
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(s),
                                onPressed: () => _send(s),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _input,
                    enabled: !_limitReached,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText: _limitReached
                          ? 'Question limit reached for this chat'
                          : 'Ask about your warning...',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(6),
                        child: IconButton.filled(
                          tooltip: 'Send',
                          onPressed: _waiting || _limitReached
                              ? null
                              : () => _send(_input.text),
                          icon: const Icon(LucideIcons.arrowRight, size: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI can make mistakes. For safety, follow the triage result.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
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

class _ContextChip extends StatelessWidget {
  const _ContextChip({required this.chatContext, required this.vehicle});

  final ChatContext chatContext;
  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final triage = chatContext.triage!;
    final colors = Theme.of(context).colorScheme;
    final car = vehicle == null ? '' : ' · ${vehicle!.displayName}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SeverityBadge(severity: triage.severity),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${triage.worstLight!.name}$car',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        'Ask anything about your warning lights or your car.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.onRetry});

  final ChatMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mine = message.fromUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * (mine ? 0.78 : 0.86),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: mine ? colors.primary : colors.surfaceContainerLowest,
                border: mine ? null : Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(mine ? 20 : 6),
                  bottomRight: Radius.circular(mine ? 6 : 20),
                ),
              ),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: mine ? colors.onPrimary : colors.onSurface,
                ),
              ),
            ),
          ),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: context.severity.stop,
              ),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Not sent. Tap to retry'),
            ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: 'AI is typing',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            border: Border.all(color: colors.outlineVariant),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(left: i == 0 ? 0 : 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // each dot lights up a bit after the one before it
                      color: colors.onSurfaceVariant.withValues(
                        alpha: ((_anim.value * 3 - i) % 3) < 1 ? 0.9 : 0.3,
                      ),
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
