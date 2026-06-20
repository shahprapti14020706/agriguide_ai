import '../models/farm_activity_model.dart';

class FarmActivityService {
  FarmActivityModel createActivity({
    required String userId,
    required String type,
    required String title,
    required String description,
    String? cropId,
    String? cropName,
    String? quantity,
    double? cost,
    DateTime? activityDate,
  }) {
    final now = DateTime.now();
    return FarmActivityModel(
      id: 'activity_${now.microsecondsSinceEpoch}',
      userId: userId,
      type: type,
      title: title,
      description: description,
      cropId: cropId,
      cropName: cropName,
      quantity: quantity,
      cost: cost,
      activityDate: activityDate ?? now,
      createdAt: now,
    );
  }
}
