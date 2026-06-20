import '../core/constants/firestore_paths.dart';
import '../models/weather_model.dart';
import '../services/firestore_service.dart';

abstract class WeatherRepository {
  Future<List<WeatherModel>> getWeatherHistory(String userId);

  Future<String> saveWeatherData(WeatherModel weatherData);
}

class FirebaseWeatherRepository implements WeatherRepository {
  FirebaseWeatherRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<WeatherModel>> getWeatherHistory(String userId) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userWeatherData(userId),
      queryBuilder: (collection) => collection.orderBy(
        'fetchedAt',
        descending: true,
      ),
    );

    return data
        .map((item) => WeatherModel.fromMap(item))
        .toList(growable: false);
  }

  @override
  Future<String> saveWeatherData(WeatherModel weatherData) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userWeatherData(weatherData.userId),
      documentId: weatherData.id,
      data: weatherData.toMap(),
    );
  }
}
