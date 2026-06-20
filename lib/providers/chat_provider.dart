import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../models/chat_message_model.dart';
import '../models/crop_model.dart';
import '../models/user_profile_model.dart';
import '../repositories/chat_repository.dart';
import '../services/agriculture_ai_agent_service.dart';
import '../services/farm_context_builder.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class ChatProvider extends BaseProvider {
  ChatProvider({
    required ChatRepository chatRepository,
    required AgricultureAiAgentService aiAgentService,
    required FarmContextBuilder farmContextBuilder,
    required LocalStorageService localStorageService,
  })  : _chatRepository = chatRepository,
        _aiAgentService = aiAgentService,
        _farmContextBuilder = farmContextBuilder,
        _localStorageService = localStorageService;

  static const defaultChatId = 'agriculture_ai';

  static String _localMessagesKey(String userId, String chatId) =>
      'chat_${userId}_$chatId';

  final ChatRepository _chatRepository;
  final AgricultureAiAgentService _aiAgentService;
  final FarmContextBuilder _farmContextBuilder;
  final LocalStorageService _localStorageService;

  final List<ChatMessageModel> _messages = [];
  bool _isThinking = false;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isThinking => _isThinking;

  Future<void> loadMessages(String userId) async {
    setLoading();

    try {
      final messages = FirebaseRuntime.isAvailable
          ? await _chatRepository.getMessages(userId, defaultChatId)
          : _readLocalMessages(userId, defaultChatId);
      _messages
        ..clear()
        ..addAll(messages);

      _messages.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<void> sendQuestion({
    required String userId,
    required String question,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
  }) async {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty || _isThinking) {
      return;
    }

    _isThinking = true;
    safeNotifyListeners();

    try {
      final now = DateTime.now();
      final userMessage = ChatMessageModel(
        id: 'user_${now.microsecondsSinceEpoch}',
        chatId: defaultChatId,
        userId: userId,
        role: 'user',
        message: trimmedQuestion,
        supportedTopic: true,
        responseSections: const {},
        contextUsed: const {},
        createdAt: now,
      );

      await _appendMessage(userMessage);

      final farmContext = _farmContextBuilder.build(
        profile: profile,
        crops: crops,
      );
      final response = _aiAgentService.answer(
        question: trimmedQuestion,
        profile: profile,
        crops: crops,
        farmContext: farmContext,
      );

      final assistantMessage = ChatMessageModel(
        id: 'assistant_${DateTime.now().microsecondsSinceEpoch}',
        chatId: defaultChatId,
        userId: userId,
        role: 'assistant',
        message: response.message,
        intent: response.intent.topic,
        supportedTopic: response.supported,
        responseSections: response.sections,
        contextUsed: response.context,
        createdAt: DateTime.now(),
      );

      await _appendMessage(assistantMessage);
      setSuccess();
    } catch (error) {
      setFailure(error);
    } finally {
      _isThinking = false;
      safeNotifyListeners();
    }
  }

  Future<void> clearLocalHistory(String userId) async {
    _messages.clear();
    if (!FirebaseRuntime.isAvailable) {
      await _localStorageService.remove(
        _localMessagesKey(userId, defaultChatId),
      );
    }
    setEmpty();
  }

  Future<void> _appendMessage(ChatMessageModel message) async {
    _messages.add(message);

    if (FirebaseRuntime.isAvailable) {
      await _chatRepository.addMessage(message);
    } else {
      await _saveLocalMessages(message.userId, message.chatId);
    }

    safeNotifyListeners();
  }

  List<ChatMessageModel> _readLocalMessages(String userId, String chatId) {
    final raw = _localStorageService.getString(
      _localMessagesKey(userId, chatId),
    );
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => ChatMessageModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _saveLocalMessages(String userId, String chatId) {
    final data =
        _messages.map((message) => message.toJson()).toList(growable: false);
    return _localStorageService.setString(
      _localMessagesKey(userId, chatId),
      jsonEncode(data),
    );
  }
}
