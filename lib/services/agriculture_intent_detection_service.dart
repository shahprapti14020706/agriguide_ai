class AgricultureIntentDetectionService {
  static const unsupportedResponse =
      'I am AgriGuide AI and can only assist with agriculture-related topics.';

  AgricultureIntent detect(String question) {
    final normalized = question.toLowerCase().trim();

    for (final entry in _topicKeywords.entries) {
      if (entry.value.any((keyword) => normalized.contains(keyword))) {
        return AgricultureIntent(
          topic: entry.key,
          supported: true,
          confidence: 0.86,
        );
      }
    }

    return const AgricultureIntent(
      topic: 'unsupported',
      supported: false,
      confidence: 1,
    );
  }

  static const Map<String, List<String>> _topicKeywords = {
    'crop_diseases': [
      'disease',
      'leaf spot',
      'yellow leaf',
      'fungus',
      'blight',
      'wilt',
      'rot',
      'infection',
      'symptom',
    ],
    'pest_attacks': [
      'pest',
      'insect',
      'borer',
      'aphid',
      'whitefly',
      'caterpillar',
      'mites',
      'attack',
    ],
    'fertilizers': [
      'fertilizer',
      'nutrient',
      'nitrogen',
      'phosphorus',
      'potassium',
      'npk',
      'urea',
      'manure',
    ],
    'irrigation': [
      'irrigation',
      'water',
      'watering',
      'drip',
      'sprinkler',
      'moisture',
      'dry',
    ],
    'seeds': [
      'seed',
      'variety',
      'germination',
      'sowing',
      'nursery',
    ],
    'crop_stages': [
      'stage',
      'flowering',
      'fruiting',
      'vegetative',
      'maturity',
      'crop age',
    ],
    'harvesting': [
      'harvest',
      'harvesting',
      'mature',
      'storage',
      'post harvest',
    ],
    'soil_health': [
      'soil',
      'ph',
      'organic carbon',
      'salinity',
      'soil test',
      'soil health',
    ],
    'government_schemes': [
      'scheme',
      'subsidy',
      'pm kisan',
      'insurance',
      'loan',
      'government',
    ],
    'market_information': [
      'market',
      'price',
      'mandi',
      'sell',
      'rate',
      'trend',
    ],
    'organic_farming': [
      'organic',
      'compost',
      'vermicompost',
      'biofertilizer',
      'natural farming',
    ],
    'weather_advisory': [
      'weather',
      'rain',
      'temperature',
      'humidity',
      'forecast',
      'spray',
    ],
    'farm_management': [
      'farm',
      'crop',
      'cultivation',
      'field',
      'farmer',
      'farming',
      'agriculture',
      'record',
      'planning',
      'reminder',
      'activity',
      'schedule',
    ],
  };
}

class AgricultureIntent {
  const AgricultureIntent({
    required this.topic,
    required this.supported,
    required this.confidence,
  });

  final String topic;
  final bool supported;
  final double confidence;
}
