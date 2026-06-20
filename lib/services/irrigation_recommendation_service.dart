import '../core/localization/language_strings.dart';
import '../models/crop_model.dart';
import '../models/irrigation_recommendation_model.dart';
import '../models/weather_model.dart';

class IrrigationRecommendationService {
  IrrigationRecommendationModel buildRecommendation({
    required String userId,
    required CropModel crop,
    WeatherModel? weather,
    AppLanguage language = AppLanguage.english,
  }) {
    final now = DateTime.now();
    final rainProbability = weather?.rainProbability ?? 0;
    final nextDate = rainProbability > 65
        ? now.add(const Duration(days: 3))
        : now.add(const Duration(days: 1));

    return IrrigationRecommendationModel(
      id: 'irrigation_${now.microsecondsSinceEpoch}',
      userId: userId,
      cropId: crop.id,
      cropName: crop.cropName,
      soilType: crop.soilType,
      irrigationMethod: crop.irrigationMethod,
      cropStage: crop.currentStage,
      waterRequirement: _waterRequirementFor(crop, weather, language),
      irrigationFrequency: rainProbability > 65
          ? _pick(
              language,
              'Pause irrigation until rainfall is reviewed.',
              'बारिश की स्थिति देखकर सिंचाई रोकें।',
              'पावसाची स्थिती पाहून सिंचन थांबवा.',
            )
          : _frequencyFor(crop.soilType, crop.currentStage, language),
      nextIrrigationDate: nextDate,
      advisoryNotes: [
        _pick(
          language,
          'Check soil moisture before irrigation.',
          'सिंचाई से पहले मिट्टी की नमी जांचें।',
          'सिंचनापूर्वी मातीतील ओलावा तपासा.',
        ),
        _pick(
          language,
          'Irrigate during early morning or evening to reduce evaporation.',
          'वाष्पीकरण कम करने के लिए सुबह या शाम सिंचाई करें।',
          'बाष्पीभवन कमी करण्यासाठी सकाळी किंवा संध्याकाळी सिंचन करा.',
        ),
        if (rainProbability > 65)
          _pick(
            language,
            'Expected rain is sufficient to postpone immediate irrigation.',
            'अपेक्षित बारिश तत्काल सिंचाई टालने के लिए पर्याप्त है।',
            'अपेक्षित पाऊस तत्काळ सिंचन पुढे ढकलण्यासाठी पुरेसा आहे.',
          ),
      ],
      alerts: _alertsFor(crop, weather, language),
      schedule: [
        _pick(
          language,
          'Review field moisture today.',
          'आज खेत की नमी जांचें।',
          'आज शेतातील ओलावा तपासा.',
        ),
        _pick(
          language,
          'Irrigate next on ${nextDate.day}/${nextDate.month}/${nextDate.year}.',
          'अगली सिंचाई ${nextDate.day}/${nextDate.month}/${nextDate.year} को करें।',
          'पुढील सिंचन ${nextDate.day}/${nextDate.month}/${nextDate.year} रोजी करा.',
        ),
        _pick(
          language,
          'Recheck after rainfall or high temperature.',
          'बारिश या अधिक तापमान के बाद फिर जांचें।',
          'पाऊस किंवा जास्त तापमानानंतर पुन्हा तपासा.',
        ),
      ],
      createdAt: now,
    );
  }

  String _waterRequirementFor(
    CropModel crop,
    WeatherModel? weather,
    AppLanguage language,
  ) {
    final area = crop.areaUnderCultivation <= 0 ? 1 : crop.areaUnderCultivation;
    final base = crop.currentStage == 'Flowering' ? 1800 : 1400;
    final adjustment = (weather?.temperature ?? 0) > 33 ? 1.2 : 1.0;
    final liters = (area * base * adjustment).toStringAsFixed(0);
    return _pick(
      language,
      '$liters liters estimated for current field condition',
      '$liters लीटर वर्तमान खेत स्थिति के लिए अनुमानित',
      '$liters लिटर सध्याच्या शेत स्थितीसाठी अंदाजित',
    );
  }

  String _frequencyFor(String soilType, String stage, AppLanguage language) {
    final soil = soilType.toLowerCase();
    if (soil.contains('sandy')) {
      return _pick(
        language,
        'Every 2 days with smaller quantity',
        'हर 2 दिन कम मात्रा में',
        'दर 2 दिवसांनी कमी प्रमाणात',
      );
    }
    if (stage == 'Flowering' || stage == 'Fruiting') {
      return _pick(
        language,
        'Every 2 to 3 days based on moisture',
        'नमी के आधार पर हर 2 से 3 दिन',
        'ओलाव्यानुसार दर 2 ते 3 दिवसांनी',
      );
    }
    return _pick(
      language,
      'Every 3 to 4 days based on soil moisture',
      'मिट्टी की नमी के आधार पर हर 3 से 4 दिन',
      'मातीतील ओलाव्यानुसार दर 3 ते 4 दिवसांनी',
    );
  }

  List<String> _alertsFor(
    CropModel crop,
    WeatherModel? weather,
    AppLanguage language,
  ) {
    final alerts = <String>[];
    if ((weather?.rainProbability ?? 0) > 65) {
      alerts.add(
        _pick(
          language,
          'Rain expected; avoid over-irrigation.',
          'बारिश अपेक्षित है; अधिक सिंचाई से बचें।',
          'पाऊस अपेक्षित आहे; जास्त सिंचन टाळा.',
        ),
      );
    }
    if ((weather?.temperature ?? 0) > 33) {
      alerts.add(
        _pick(
          language,
          'Heat stress risk; check crop during afternoon.',
          'गर्मी तनाव का जोखिम है; दोपहर में फसल जांचें।',
          'उष्णतेचा ताण संभवतो; दुपारी पीक तपासा.',
        ),
      );
    }
    if (crop.irrigationMethod.toLowerCase().contains('flood')) {
      alerts.add(
        _pick(
          language,
          'Avoid standing water around root zone.',
          'जड़ क्षेत्र में पानी जमा न रहने दें।',
          'मुळाजवळ पाणी साचू देऊ नका.',
        ),
      );
    }
    return alerts.isEmpty
        ? [
            _pick(
              language,
              'No irrigation alert for now.',
              'अभी कोई सिंचाई अलर्ट नहीं है।',
              'सध्या सिंचन सूचना नाही.',
            ),
          ]
        : alerts;
  }

  String _pick(AppLanguage language, String en, String hi, String mr) {
    return switch (language) {
      AppLanguage.hindi => hi,
      AppLanguage.marathi => mr,
      AppLanguage.english => en,
    };
  }
}
