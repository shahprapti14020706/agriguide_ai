import '../models/crop_model.dart';
import '../models/user_profile_model.dart';
import 'agriculture_intent_detection_service.dart';

class AgricultureRecommendationEngine {
  AgricultureRecommendation buildRecommendation({
    required String question,
    required AgricultureIntent intent,
    required List<String> knowledge,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
  }) {
    final primaryCrop = crops.isEmpty ? null : crops.first;
    final cropPhrase = primaryCrop == null
        ? 'your crop'
        : '${primaryCrop.cropName} at ${primaryCrop.currentStage} stage';
    final locationPhrase = profile == null
        ? 'your local conditions'
        : '${profile.district}, ${profile.state} conditions';

    final sections = {
      'Problem Summary': _summary(intent.topic, cropPhrase, locationPhrase),
      'Possible Causes': _causes(intent.topic),
      'Suggested Action': _action(intent.topic, cropPhrase),
      'Preventive Measures': _prevention(intent.topic),
      'When To Contact Expert': _expertAdvice(intent.topic),
    };

    return AgricultureRecommendation(
      message: sections.entries
          .map((entry) => '${entry.key}\n${entry.value}')
          .join('\n\n'),
      sections: sections,
      context: {
        'topic': intent.topic,
        'question': question,
        'confidence': intent.confidence,
        'knowledge': knowledge,
        'cropIds': crops.map((crop) => crop.id).toList(growable: false),
        'profileUsed': profile != null,
      },
    );
  }

  String _summary(String topic, String cropPhrase, String locationPhrase) {
    return switch (topic) {
      'crop_diseases' =>
        'The question appears related to disease symptoms in $cropPhrase under $locationPhrase.',
      'pest_attacks' =>
        'The question appears related to pest pressure or insect damage in $cropPhrase.',
      'fertilizers' =>
        'The question is about nutrient planning for $cropPhrase.',
      'irrigation' => 'The question is about water management for $cropPhrase.',
      'seeds' => 'The question is about seed or variety selection.',
      'crop_stages' =>
        'The question is about crop stage and next activities for $cropPhrase.',
      'harvesting' =>
        'The question is about harvest readiness and post-harvest planning.',
      'soil_health' =>
        'The question is about soil condition and long-term productivity.',
      'government_schemes' =>
        'The question is about agriculture schemes or subsidies.',
      'market_information' =>
        'The question is about crop price, market timing, or selling decision.',
      'organic_farming' =>
        'The question is about organic or natural farming practices.',
      'weather_advisory' =>
        'The question is about weather-based farm decisions.',
      _ => 'The question is about farm management and activity planning.',
    };
  }

  String _causes(String topic) {
    return switch (topic) {
      'crop_diseases' =>
        'Possible causes include fungal or bacterial infection, excess humidity, poor drainage, nutrient stress, or infected planting material.',
      'pest_attacks' =>
        'Possible causes include pest buildup, delayed scouting, nearby infested fields, dense canopy, or favorable weather.',
      'fertilizers' =>
        'The need may be driven by crop stage, nutrient deficiency, soil type, previous fertilizer use, and rainfall loss.',
      'irrigation' =>
        'Water stress may result from high temperature, low soil moisture, sandy soil, flowering-stage demand, or delayed irrigation.',
      'soil_health' =>
        'Soil issues may come from low organic matter, imbalanced nutrients, salinity, compaction, or unsuitable pH.',
      'weather_advisory' =>
        'Risk may come from rain, wind, humidity, high heat, or sudden weather change.',
      _ =>
        'The causes depend on crop stage, local field condition, weather, soil, and recent farm activities.',
    };
  }

  String _action(String topic, String cropPhrase) {
    return switch (topic) {
      'crop_diseases' =>
        'Inspect affected plants closely, isolate severe samples, avoid unnecessary irrigation on foliage, and use crop-approved treatment only after confirming symptoms.',
      'pest_attacks' =>
        'Scout multiple field spots, estimate pest level, remove heavily affected parts where practical, and prefer integrated pest management before chemical control.',
      'fertilizers' =>
        'Apply nutrients according to crop stage and soil condition. Prefer split application and irrigate lightly if the fertilizer requires moisture.',
      'irrigation' =>
        'Check soil moisture near the root zone. Irrigate early morning or evening if the soil is dry and the crop is at a sensitive stage.',
      'seeds' =>
        'Choose locally suitable, certified, disease-tolerant seed and follow recommended seed rate and treatment.',
      'crop_stages' =>
        'Use sowing date and expected harvest date to plan the next activity for $cropPhrase.',
      'harvesting' =>
        'Check maturity indicators, avoid harvest during rain, and prepare drying, grading, storage, and transport.',
      'government_schemes' =>
        'Match the scheme with state, crop, farm size, category, documents, and deadline before applying.',
      'market_information' =>
        'Compare nearby market rates, quality grade, transport cost, and short-term price trend before selling.',
      'organic_farming' =>
        'Use well-decomposed compost, crop rotation, biological inputs, mulching, and regular pest monitoring.',
      'weather_advisory' =>
        'Avoid spraying during rain or strong wind, adjust irrigation to rainfall forecast, and protect harvest-ready produce.',
      _ =>
        'Record the field observation, plan the next activity, and monitor the result within the next few days.',
    };
  }

  String _prevention(String topic) {
    return switch (topic) {
      'crop_diseases' =>
        'Use clean seed, rotate crops, maintain spacing, improve drainage, and remove infected residues.',
      'pest_attacks' =>
        'Scout weekly, conserve beneficial insects, avoid excess nitrogen, and keep field borders clean.',
      'fertilizers' =>
        'Test soil periodically, keep input records, and avoid overuse of nitrogen.',
      'irrigation' =>
        'Use mulching, level fields, maintain irrigation equipment, and schedule water based on stage and soil.',
      'soil_health' =>
        'Add organic matter, reduce compaction, rotate crops, and follow soil-test-based nutrition.',
      _ =>
        'Maintain farm records, monitor crop stage, and act early when field conditions change.',
    };
  }

  String _expertAdvice(String topic) {
    return switch (topic) {
      'crop_diseases' ||
      'pest_attacks' =>
        'Contact a local agriculture expert if symptoms spread quickly, more than 10 percent of plants are affected, or diagnosis is uncertain.',
      'fertilizers' ||
      'soil_health' =>
        'Contact an expert if deficiency symptoms persist after correction or soil test values are abnormal.',
      'irrigation' ||
      'weather_advisory' =>
        'Contact an expert if the crop shows wilting, waterlogging, or stress during flowering or fruiting.',
      _ =>
        'Contact an expert when the recommendation involves high cost, chemical use, crop loss risk, or unclear field symptoms.',
    };
  }
}

class AgricultureRecommendation {
  const AgricultureRecommendation({
    required this.message,
    required this.sections,
    required this.context,
  });

  final String message;
  final Map<String, String> sections;
  final Map<String, dynamic> context;
}
