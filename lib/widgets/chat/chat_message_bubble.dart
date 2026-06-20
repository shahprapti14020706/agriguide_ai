import 'package:flutter/material.dart';

import '../../models/chat_message_model.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    required this.message,
    super.key,
  });

  final ChatMessageModel message;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        _isUser ? colorScheme.primary : colorScheme.surfaceContainerHighest;
    final foregroundColor =
        _isUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;

    return Align(
      alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isUser || message.responseSections.isEmpty
              ? SelectableText(
                  message.message,
                  style: TextStyle(color: foregroundColor),
                )
              : _AssistantSections(
                  sections: message.responseSections,
                  textColor: foregroundColor,
                ),
        ),
      ),
    );
  }
}

class _AssistantSections extends StatelessWidget {
  const _AssistantSections({
    required this.sections,
    required this.textColor,
  });

  final Map<String, dynamic> sections;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    entry.value.toString(),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
