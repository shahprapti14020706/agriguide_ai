import '../models/farm_context_model.dart';

class FarmContextService {
  String summarize(FarmContextModel context) {
    final crops = context.activeCrops.map((crop) => crop.cropName).join(', ');
    final reminders = context.reminders.where((item) => !item.completed).length;
    final rain = context.weather?.rainProbability.toStringAsFixed(0);
    return [
      if (context.profile != null)
        'Farmer location: ${context.profile!.district}, ${context.profile!.state}',
      if (crops.isNotEmpty) 'Active crops: $crops',
      if (rain != null) 'Rain probability: $rain%',
      'Open reminders: $reminders',
      'Recent disease reports: ${context.diseaseReports.length}',
    ].join('\n');
  }
}
