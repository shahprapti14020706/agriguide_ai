import '../core/localization/language_strings.dart';
import '../models/crop_model.dart';
import '../models/user_profile_model.dart';
import '../models/weather_model.dart';

class WeatherAdvisoryService {
  WeatherModel buildAdvisory({
    required String userId,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
    AppLanguage language = AppLanguage.english,
  }) {
    final now = DateTime.now();
    final activeCrop = crops.isEmpty ? null : crops.first;
    final location = _locationFor(profile);
    final temperature = _temperatureFor(profile);
    final humidity = _humidityFor(profile);
    final rainProbability = _rainProbabilityFor(activeCrop);
    final windSpeed = rainProbability > 60 ? 18.0 : 10.0;
    final sunrise = DateTime(now.year, now.month, now.day, 6, 8);
    final sunset = DateTime(now.year, now.month, now.day, 18, 42);

    return WeatherModel(
      id: 'weather_${now.microsecondsSinceEpoch}',
      userId: userId,
      location: location,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      rainProbability: rainProbability,
      sunrise: sunrise,
      sunset: sunset,
      forecast: List.generate(7, (index) {
        final day = now.add(Duration(days: index));
        final rain = (rainProbability + (index * 4) - 8).clamp(10, 90);
        return WeatherForecastModel(
          date: day,
          temperature: temperature + (index.isEven ? 1.5 : -0.8),
          rainProbability: rain.toDouble(),
          summary: rain > 65
              ? _pick(
                  language,
                  'Rain likely',
                  'बारिश की संभावना',
                  'पावसाची शक्यता',
                )
              : _pick(
                  language,
                  'Field work suitable',
                  'खेत का काम उपयुक्त',
                  'शेतीचे काम योग्य',
                ),
        );
      }),
      alerts: _alertsFor(rainProbability, windSpeed, temperature, language),
      summary: _pick(
        language,
        '$location is expected to stay near ${temperature.toStringAsFixed(0)}C with ${rainProbability.toStringAsFixed(0)}% rain probability.',
        '$location में तापमान लगभग ${temperature.toStringAsFixed(0)}C और बारिश की संभावना ${rainProbability.toStringAsFixed(0)}% है।',
        '$location येथे तापमान सुमारे ${temperature.toStringAsFixed(0)}C आणि पावसाची शक्यता ${rainProbability.toStringAsFixed(0)}% आहे.',
      ),
      possibleImpact: activeCrop == null
          ? _pick(
              language,
              'Weather may affect irrigation planning and field operations.',
              'मौसम सिंचाई योजना और खेत कार्यों को प्रभावित कर सकता है।',
              'हवामान सिंचन नियोजन आणि शेती कामांवर परिणाम करू शकते.',
            )
          : _pick(
              language,
              '${activeCrop.cropName} at ${activeCrop.currentStage} stage may need adjusted irrigation and disease monitoring.',
              '${activeCrop.cropName} की ${activeCrop.currentStage} अवस्था में सिंचाई और रोग निगरानी समायोजित करें।',
              '${activeCrop.cropName} च्या ${activeCrop.currentStage} अवस्थेत सिंचन आणि रोग निरीक्षण समायोजित करा.',
            ),
      suggestedAction: rainProbability > 60
          ? _pick(
              language,
              'Delay spraying and fertilizer application until rain risk reduces.',
              'बारिश का जोखिम कम होने तक छिड़काव और उर्वरक प्रयोग रोकें।',
              'पावसाचा धोका कमी होईपर्यंत फवारणी आणि खत वापर थांबवा.',
            )
          : _pick(
              language,
              'Continue planned field work and check soil moisture before irrigation.',
              'योजनाबद्ध खेत कार्य जारी रखें और सिंचाई से पहले मिट्टी की नमी जांचें।',
              'नियोजित शेती कामे सुरू ठेवा आणि सिंचनापूर्वी मातीतील ओलावा तपासा.',
            ),
      preventiveMeasures: _pick(
        language,
        'Keep drainage clear, avoid spraying during strong wind, and inspect crops after rain or high humidity.',
        'निकास साफ रखें, तेज हवा में छिड़काव न करें, और बारिश या अधिक नमी के बाद फसल जांचें।',
        'निचरा स्वच्छ ठेवा, जोरदार वाऱ्यात फवारणी टाळा, आणि पाऊस किंवा जास्त आर्द्रतेनंतर पीक तपासा.',
      ),
      languageCode: language.code,
      fetchedAt: now,
    );
  }

  String _locationFor(UserProfileModel? profile) {
    if (profile == null) {
      return 'Farm location';
    }

    final parts = [
      profile.village,
      profile.district,
      profile.state,
    ].where((part) => part.trim().isNotEmpty).toList(growable: false);

    return parts.isEmpty ? 'Farm location' : parts.join(', ');
  }

  double _temperatureFor(UserProfileModel? profile) {
    final state = profile?.state.toLowerCase() ?? '';
    if (state.contains('maharashtra')) {
      return 31;
    }
    if (state.contains('punjab') || state.contains('haryana')) {
      return 34;
    }
    return 29;
  }

  double _humidityFor(UserProfileModel? profile) {
    final waterSource = profile?.waterSource.toLowerCase() ?? '';
    return waterSource.contains('rain') ? 78 : 64;
  }

  double _rainProbabilityFor(CropModel? crop) {
    final stage = crop?.currentStage.toLowerCase() ?? '';
    if (stage.contains('flower') || stage.contains('fruit')) {
      return 68;
    }
    if (stage.contains('harvest')) {
      return 35;
    }
    return 52;
  }

  List<String> _alertsFor(
    double rainProbability,
    double windSpeed,
    double temperature,
    AppLanguage language,
  ) {
    final alerts = <String>[];
    if (rainProbability > 60) {
      alerts.add(
        _pick(
          language,
          'High rain probability can interrupt spraying.',
          'अधिक बारिश की संभावना छिड़काव रोक सकती है।',
          'जास्त पावसाची शक्यता फवारणी थांबवू शकते.',
        ),
      );
    }
    if (windSpeed > 15) {
      alerts.add(
        _pick(
          language,
          'Moderate wind may cause spray drift.',
          'हवा से छिड़काव बह सकता है।',
          'वाऱ्यामुळे फवारणी वाहू शकते.',
        ),
      );
    }
    if (temperature > 33) {
      alerts.add(
        _pick(
          language,
          'High temperature increases crop water stress.',
          'अधिक तापमान फसल में जल तनाव बढ़ाता है।',
          'जास्त तापमानामुळे पिकात पाण्याचा ताण वाढतो.',
        ),
      );
    }
    return alerts.isEmpty
        ? [
            _pick(
              language,
              'No severe weather alert for now.',
              'अभी कोई गंभीर मौसम अलर्ट नहीं है।',
              'सध्या गंभीर हवामान सूचना नाही.',
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
