import '../models/crop_model.dart';
import '../models/user_profile_model.dart';
import 'agriculture_intent_detection_service.dart';

class AgricultureKnowledgeRetrievalService {
  List<String> retrieve({
    required AgricultureIntent intent,
    required String question,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
  }) {
    final cropContext = crops.isEmpty
        ? 'No active crop context is available.'
        : 'Active crop context: '
            '${crops.map((crop) => '${crop.cropName} (${crop.currentStage})').join(', ')}.';
    final profileContext = profile == null
        ? 'Farmer profile is not completed.'
        : 'Farm context: ${profile.village}, ${profile.district}, '
            '${profile.state}; soil ${profile.soilType}; irrigation '
            '${profile.irrigationMethod}; water source ${profile.waterSource}.';

    return [
      'Farmer question: ${question.trim()}',
      profileContext,
      cropContext,
      ...(_knowledgeByTopic[intent.topic] ??
          _knowledgeByTopic['farm_management']!),
    ];
  }

  static const Map<String, List<String>> _knowledgeByTopic = {
    'crop_diseases': [
      'Disease advice should start with symptom observation, affected plant part, spread pattern, and recent weather.',
      'Avoid repeated chemical spraying without confirming the disease or pest cause.',
    ],
    'pest_attacks': [
      'Pest guidance should include field scouting, pest population level, crop stage, and safe control thresholds.',
      'Integrated pest management should combine monitoring, biological control, and careful pesticide use.',
    ],
    'fertilizers': [
      'Fertilizer recommendations should consider crop, stage, soil type, and recent rainfall or irrigation.',
      'Split fertilizer application is safer than a large single dose for many crops.',
    ],
    'irrigation': [
      'Irrigation decisions should consider crop stage, soil moisture, temperature, rainfall forecast, and water source.',
      'Critical stages such as flowering and fruiting often need consistent moisture.',
    ],
    'seeds': [
      'Seed advice should consider variety suitability, season, disease tolerance, and germination quality.',
      'Use treated, certified, locally suitable seed when available.',
    ],
    'crop_stages': [
      'Crop stage advice should use sowing date, expected harvest date, and local crop calendar.',
      'Upcoming activities depend on the current stage and crop stress indicators.',
    ],
    'harvesting': [
      'Harvesting advice should consider crop maturity, moisture, weather forecast, labor, and storage readiness.',
      'Avoid harvesting immediately after rain unless crop-specific practice supports it.',
    ],
    'soil_health': [
      'Soil health advice should encourage soil testing, organic matter improvement, and balanced nutrients.',
      'Soil type affects irrigation frequency, nutrient holding capacity, and root growth.',
    ],
    'government_schemes': [
      'Scheme recommendations should be filtered by state, crop, farmer category, farm size, and deadlines.',
      'Farmers should verify documents and official application channels before applying.',
    ],
    'market_information': [
      'Market advice should compare nearby prices, quality grade, transport cost, and harvest timing.',
      'Do not rely on a single market price point for selling decisions.',
    ],
    'organic_farming': [
      'Organic farming guidance should include soil organic matter, compost quality, bio-input timing, and pest prevention.',
      'Transition to organic methods should be planned crop by crop.',
    ],
    'weather_advisory': [
      'Weather advisory should connect rainfall, wind, humidity, and temperature to irrigation, spraying, and harvesting decisions.',
      'Avoid spraying during high wind, rain probability, or extreme heat.',
    ],
    'farm_management': [
      'Farm management advice should convert recommendations into timely activities and records.',
      'Track inputs, field observations, and completed tasks for better future recommendations.',
    ],
  };
}
