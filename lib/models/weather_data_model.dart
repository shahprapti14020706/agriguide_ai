import '../core/utils/map_utils.dart';

class WeatherDataModel {
  const WeatherDataModel({
    required this.id,
    required this.userId,
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.uvIndex,
    required this.forecastDate,
    required this.advisory,
    required this.fetchedAt,
  });

  final String id;
  final String userId;
  final String location;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double rainProbability;
  final double uvIndex;
  final DateTime forecastDate;
  final Map<String, dynamic> advisory;
  final DateTime fetchedAt;

  factory WeatherDataModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return WeatherDataModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      location: map['location'] as String? ?? '',
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0,
      windSpeed: (map['windSpeed'] as num?)?.toDouble() ?? 0,
      rainProbability: (map['rainProbability'] as num?)?.toDouble() ?? 0,
      uvIndex: (map['uvIndex'] as num?)?.toDouble() ?? 0,
      forecastDate:
          MapUtils.dateTimeFromValue(map['forecastDate']) ?? DateTime.now(),
      advisory: MapUtils.stringMapFromValue(map['advisory']),
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
      'uvIndex': uvIndex,
      'forecastDate': forecastDate,
      'advisory': advisory,
      'fetchedAt': fetchedAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) {
    return WeatherDataModel.fromMap(json);
  }
}
