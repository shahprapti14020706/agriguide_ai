import '../models/crop_model.dart';
import '../models/farm_context_model.dart';
import '../models/user_profile_model.dart';
import 'agriculture_intent_detection_service.dart';
import 'agriculture_knowledge_retrieval_service.dart';
import 'agriculture_recommendation_engine.dart';

class AgricultureAiAgentService {
  AgricultureAiAgentService({
    required AgricultureIntentDetectionService intentDetectionService,
    required AgricultureKnowledgeRetrievalService knowledgeRetrievalService,
    required AgricultureRecommendationEngine recommendationEngine,
  })  : _intentDetectionService = intentDetectionService,
        _knowledgeRetrievalService = knowledgeRetrievalService,
        _recommendationEngine = recommendationEngine;

  final AgricultureIntentDetectionService _intentDetectionService;
  final AgricultureKnowledgeRetrievalService _knowledgeRetrievalService;
  final AgricultureRecommendationEngine _recommendationEngine;

  AgricultureAgentResponse answer({
    required String question,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
    FarmContextModel? farmContext,
  }) {
    final intent = _intentDetectionService.detect(question);

    if (!intent.supported) {
      return AgricultureAgentResponse(
        message: AgricultureIntentDetectionService.unsupportedResponse,
        intent: intent,
        supported: false,
        sections: const {},
        context: const {},
      );
    }

    final knowledge = _knowledgeRetrievalService.retrieve(
      intent: intent,
      question: question,
      profile: profile,
      crops: crops,
    );
    final recommendation = _recommendationEngine.buildRecommendation(
      question: question,
      intent: intent,
      knowledge: knowledge,
      profile: profile,
      crops: crops,
    );

    return AgricultureAgentResponse(
      message: recommendation.message,
      intent: intent,
      supported: true,
      sections: recommendation.sections,
      context: {
        ...recommendation.context,
        if (farmContext != null) 'farmContext': farmContext.toPromptContext(),
      },
    );
  }
}

class AgricultureAgentResponse {
  const AgricultureAgentResponse({
    required this.message,
    required this.intent,
    required this.supported,
    required this.sections,
    required this.context,
  });

  final String message;
  final AgricultureIntent intent;
  final bool supported;
  final Map<String, String> sections;
  final Map<String, dynamic> context;
}
