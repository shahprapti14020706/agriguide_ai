import '../core/utils/map_utils.dart';

class WeatherModel {
  const WeatherModel({
    required this.id,
    required this.userId,
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.sunrise,
    required this.sunset,
    required this.forecast,
    required this.alerts,
    required this.summary,
    required this.possibleImpact,
    required this.suggestedAction,
    required this.preventiveMeasures,
    required this.languageCode,
    required this.fetchedAt,
  });

  final String id;
  final String userId;
  final String location;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double rainProbability;
  final DateTime sunrise;
  final DateTime sunset;
  final List<WeatherForecastModel> forecast;
  final List<String> alerts;
  final String summary;
  final String possibleImpact;
  final String suggestedAction;
  final String preventiveMeasures;
  final String languageCode;
  final DateTime fetchedAt;

  factory WeatherModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final forecastItems = map['forecast'];

    return WeatherModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      location: map['location'] as String? ?? '',
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0,
      windSpeed: (map['windSpeed'] as num?)?.toDouble() ?? 0,
      rainProbability: (map['rainProbability'] as num?)?.toDouble() ?? 0,
      sunrise: MapUtils.dateTimeFromValue(map['sunrise']) ?? DateTime.now(),
      sunset: MapUtils.dateTimeFromValue(map['sunset']) ?? DateTime.now(),
      forecast: forecastItems is List
          ? forecastItems
              .whereType<Map>()
              .map(
                (item) => WeatherForecastModel.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const [],
      alerts: MapUtils.stringListFromValue(map['alerts']),
      summary: map['summary'] as String? ?? '',
      possibleImpact: map['possibleImpact'] as String? ?? '',
      suggestedAction: map['suggestedAction'] as String? ?? '',
      preventiveMeasures: map['preventiveMeasures'] as String? ?? '',
      languageCode: map['languageCode'] as String? ?? '',
      fetchedAt: MapUtils.dateTimeFromValue(map['fetchedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'rainProbability': rainProbability,
      'sunrise': sunrise,
      'sunset': sunset,
      'forecast': forecast.map((item) => item.toMap()).toList(growable: false),
      'alerts': alerts,
      'summary': summary,
      'possibleImpact': possibleImpact,
      'suggestedAction': suggestedAction,
      'preventiveMeasures': preventiveMeasures,
      'languageCode': languageCode,
      'fetchedAt': fetchedAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel.fromMap(json);
  }

  WeatherModel copyWith({String? id}) {
    return WeatherModel(
      id: id ?? this.id,
      userId: userId,
      location: location,
      temperature: temperature,
      humidity: humidity,
      windSpeed: windSpeed,
      rainProbability: rainProbability,
      sunrise: sunrise,
      sunset: sunset,
      forecast: forecast,
      alerts: alerts,
      summary: summary,
      possibleImpact: possibleImpact,
      suggestedAction: suggestedAction,
      preventiveMeasures: preventiveMeasures,
      languageCode: languageCode,
      fetchedAt: fetchedAt,
    );
  }
}

class WeatherForecastModel {
  const WeatherForecastModel({
    required this.date,
    required this.temperature,
    required this.rainProbability,
    required this.summary,
  });

  final DateTime date;
  final double temperature;
  final double rainProbability;
  final String summary;

  factory WeatherForecastModel.fromMap(Map<String, dynamic> map) {
    return WeatherForecastModel(
      date: MapUtils.dateTimeFromValue(map['date']) ?? DateTime.now(),
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      rainProbability: (map['rainProbability'] as num?)?.toDouble() ?? 0,
      summary: map['summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'temperature': temperature,
      'rainProbability': rainProbability,
      'summary': summary,
    };
  }
}
