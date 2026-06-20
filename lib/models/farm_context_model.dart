import 'crop_model.dart';
import 'disease_report_model.dart';
import 'market_price_model.dart';
import 'reminder_model.dart';
import 'user_profile_model.dart';
import 'weather_model.dart';

class FarmContextModel {
  const FarmContextModel({
    this.profile,
    this.activeCrops = const [],
    this.weather,
    this.diseaseReports = const [],
    this.reminders = const [],
    this.marketPrices = const [],
  });

  final UserProfileModel? profile;
  final List<CropModel> activeCrops;
  final WeatherModel? weather;
  final List<DiseaseReportModel> diseaseReports;
  final List<ReminderModel> reminders;
  final List<MarketPriceModel> marketPrices;

  Map<String, dynamic> toPromptContext() {
    return {
      'profileState': profile?.state,
      'profileDistrict': profile?.district,
      'activeCrops': activeCrops
          .map(
            (crop) => {
              'cropName': crop.cropName,
              'stage': crop.currentStage,
              'soilType': crop.soilType,
              'irrigationMethod': crop.irrigationMethod,
            },
          )
          .toList(growable: false),
      'weatherRisk': weather?.rainProbability,
      'openReminders': reminders.where((item) => !item.completed).length,
      'marketCrops': marketPrices.map((item) => item.cropName).toList(),
      'recentDiseaseReports': diseaseReports.length,
    };
  }
}
