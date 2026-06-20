import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/chat/chat_input_widget.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import '../../widgets/chat/suggested_questions_widget.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _scrollController = ScrollController();
  bool _requestedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requestedLoad) {
      return;
    }

    _requestedLoad = true;
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<ChatProvider>().loadMessages(user.id);
        if (mounted && context.read<CropProvider>().crops.isEmpty) {
          await context.read<CropProvider>().loadCrops(user.id);
        }
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion(String question) async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      return;
    }

    final profile = context.read<ProfileProvider>().profile;
    final crops = context.read<CropProvider>().activeCrops;
    final chatProvider = context.read<ChatProvider>();

    await chatProvider.sendQuestion(
      userId: user.id,
      question: question,
      profile: profile,
      crops: crops,
    );

    if (!mounted) {
      return;
    }

    if (chatProvider.hasError && chatProvider.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chatProvider.failure!.message)),
      );
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriGuide AI'),
        actions: [
          if (user != null)
            IconButton(
              tooltip: 'Clear local chat',
              onPressed: () => context.read<ChatProvider>().clearLocalHistory(
                    user.id,
                  ),
              icon: const Icon(Icons.delete_sweep_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? const Center(
                child: Text('Please sign in to chat with AgriGuide AI.'),
              )
            : Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return Column(
                    children: [
                      Expanded(
                        child: chatProvider.isLoading &&
                                chatProvider.messages.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : chatProvider.messages.isEmpty
                                ? _EmptyChatState(onQuestion: _sendQuestion)
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: chatProvider.messages.length +
                                        (chatProvider.isThinking ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          chatProvider.messages.length) {
                                        return const _ThinkingBubble();
                                      }

                                      return ChatMessageBubble(
                                        message: chatProvider.messages[index],
                                      );
                                    },
                                  ),
                      ),
                      if (chatProvider.hasError && chatProvider.failure != null)
                        _ErrorStrip(message: chatProvider.failure!.message),
                      ChatInputWidget(
                        enabled: !chatProvider.isThinking,
                        onSend: _sendQuestion,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({required this.onQuestion});

  final ValueChanged<String> onQuestion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Icon(
          Icons.eco_outlined,
          size: 56,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Ask agriculture questions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'AgriGuide AI can help with crops, pests, fertilizer, irrigation, soil, market, weather, and farm management.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SuggestedQuestionsWidget(onSelected: onQuestion),
      ],
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('AgriGuide AI is thinking...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorStrip extends StatelessWidget {
  const _ErrorStrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: colorScheme.errorContainer,
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}
