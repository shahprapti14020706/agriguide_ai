import '../core/localization/language_strings.dart';
import '../models/crop_model.dart';
import '../models/fertilizer_recommendation_model.dart';
import '../models/weather_model.dart';

class FertilizerRecommendationService {
  FertilizerRecommendationModel buildRecommendation({
    required String userId,
    required CropModel crop,
    WeatherModel? weather,
    AppLanguage language = AppLanguage.english,
  }) {
    final now = DateTime.now();
    final stage = crop.currentStage;
    final rainRisk = weather?.rainProbability ?? 0;
    final fertilizer = _fertilizerFor(stage, crop.soilType, language);

    return FertilizerRecommendationModel(
      id: 'fertilizer_${now.microsecondsSinceEpoch}',
      userId: userId,
      cropId: crop.id,
      cropName: crop.cropName,
      variety: crop.variety,
      soilType: crop.soilType,
      cropStage: stage,
      recommendedFertilizer: fertilizer,
      quantity: _quantityFor(crop, language),
      applicationTiming: rainRisk > 60
          ? _pick(
              language,
              'Apply after rainfall risk reduces and soil is workable.',
              'बारिश का जोखिम कम होने और मिट्टी उपयुक्त होने पर प्रयोग करें।',
              'पावसाचा धोका कमी झाल्यावर आणि माती योग्य असताना वापरा.',
            )
          : _pick(
              language,
              'Apply during early morning or evening with adequate soil moisture.',
              'पर्याप्त नमी में सुबह जल्दी या शाम को प्रयोग करें।',
              'पुरेसा ओलावा असताना सकाळी किंवा संध्याकाळी वापरा.',
            ),
      precautions: [
        _pick(
          language,
          'Do not apply fertilizer on dry cracked soil.',
          'सूखी फटी मिट्टी पर उर्वरक न डालें।',
          'कोरड्या भेगाळलेल्या मातीत खत टाकू नका.',
        ),
        _pick(
          language,
          'Keep fertilizer away from direct seed or stem contact.',
          'उर्वरक को बीज या तने के सीधे संपर्क से दूर रखें।',
          'खत बियाणे किंवा खोडाच्या थेट संपर्कापासून दूर ठेवा.',
        ),
        if (rainRisk > 60)
          _pick(
            language,
            'Avoid application before expected heavy rain.',
            'भारी बारिश से पहले प्रयोग न करें।',
            'मोठ्या पावसापूर्वी वापर टाळा.',
          ),
      ],
      nutrientRequirements: {
        _pick(language, 'Nitrogen', 'नाइट्रोजन', 'नायट्रोजन'):
            stage == 'Vegetative'
                ? _pick(language, 'High', 'अधिक', 'जास्त')
                : _pick(language, 'Medium', 'मध्यम', 'मध्यम'),
        _pick(language, 'Phosphorus', 'फॉस्फोरस', 'फॉस्फरस'):
            stage == 'Germination'
                ? _pick(language, 'High', 'अधिक', 'जास्त')
                : _pick(language, 'Medium', 'मध्यम', 'मध्यम'),
        _pick(language, 'Potassium', 'पोटाशियम', 'पोटॅशियम'):
            stage == 'Fruiting'
                ? _pick(language, 'High', 'अधिक', 'जास्त')
                : _pick(language, 'Medium', 'मध्यम', 'मध्यम'),
      },
      schedule: [
        _pick(
          language,
          'Split application based on crop stage.',
          'फसल अवस्था के अनुसार विभाजित प्रयोग करें।',
          'पीक अवस्थेनुसार विभागून वापर करा.',
        ),
        _pick(
          language,
          'Irrigate lightly after application if rain is not expected.',
          'बारिश न हो तो प्रयोग के बाद हल्की सिंचाई करें।',
          'पाऊस अपेक्षित नसेल तर वापरानंतर हलके सिंचन करा.',
        ),
        _pick(
          language,
          'Review crop response after 7 days.',
          '7 दिन बाद फसल की प्रतिक्रिया देखें।',
          '7 दिवसांनंतर पिकाची प्रतिक्रिया पाहा.',
        ),
      ],
      createdAt: now,
    );
  }

  String _pick(AppLanguage language, String en, String hi, String mr) {
    return switch (language) {
      AppLanguage.hindi => hi,
      AppLanguage.marathi => mr,
      AppLanguage.english => en,
    };
  }

  String _fertilizerFor(
    String stage,
    String soilType,
    AppLanguage language,
  ) {
    final normalizedStage = stage.toLowerCase();
    final normalizedSoil = soilType.toLowerCase();
    if (normalizedStage.contains('germination') ||
        normalizedStage.contains('seedling')) {
      return _pick(
        language,
        'Balanced starter fertilizer with phosphorus support',
        'फॉस्फोरस समर्थन वाला संतुलित प्रारंभिक उर्वरक',
        'फॉस्फरस समर्थनासह संतुलित प्रारंभिक खत',
      );
    }
    if (normalizedStage.contains('flower') ||
        normalizedStage.contains('fruit')) {
      return _pick(
        language,
        'Potassium-rich fertilizer with micronutrient support',
        'सूक्ष्म पोषक समर्थन वाला पोटाशियम युक्त उर्वरक',
        'सूक्ष्म पोषकांसह पोटॅशियमयुक्त खत',
      );
    }
    if (normalizedSoil.contains('sandy')) {
      return _pick(
        language,
        'Split-dose NPK with organic compost',
        'जैविक खाद के साथ विभाजित NPK मात्रा',
        'सेंद्रिय कंपोस्टसह विभागून NPK मात्रा',
      );
    }
    return _pick(
      language,
      'Stage-based NPK with organic manure supplement',
      'जैविक खाद पूरक के साथ अवस्था आधारित NPK',
      'सेंद्रिय खत पूरकासह अवस्था आधारित NPK',
    );
  }

  String _quantityFor(CropModel crop, AppLanguage language) {
    final area = crop.areaUnderCultivation <= 0 ? 1 : crop.areaUnderCultivation;
    final quantity = (area * 25).toStringAsFixed(0);
    return _pick(
      language,
      '$quantity kg total split across application schedule',
      '$quantity kg कुल मात्रा, कार्यक्रम के अनुसार विभाजित',
      '$quantity kg एकूण मात्रा, वेळापत्रकानुसार विभागून',
    );
  }
}
