import '../models/crop_model.dart';
import '../models/disease_report_model.dart';
import '../models/farm_context_model.dart';
import '../models/market_price_model.dart';
import '../models/reminder_model.dart';
import '../models/user_profile_model.dart';
import '../models/weather_model.dart';

class FarmContextBuilder {
  FarmContextModel build({
    UserProfileModel? profile,
    List<CropModel> crops = const [],
    WeatherModel? weather,
    List<DiseaseReportModel> diseaseReports = const [],
    List<ReminderModel> reminders = const [],
    List<MarketPriceModel> marketPrices = const [],
  }) {
    return FarmContextModel(
      profile: profile,
      activeCrops: crops.where((crop) => crop.status == 'active').toList(),
      weather: weather,
      diseaseReports: diseaseReports,
      reminders: reminders,
      marketPrices: marketPrices,
    );
  }
}
