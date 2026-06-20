import '../models/crop_model.dart';
import '../models/farm_history_model.dart';
import '../models/reminder_model.dart';

class FarmHistoryService {
  List<FarmHistoryModel> fallbackHistory({
    required String userId,
    List<CropModel> crops = const [],
  }) {
    final now = DateTime.now();
    final history = crops.take(3).map((crop) {
      return FarmHistoryModel(
        id: 'history_crop_${crop.id}',
        userId: userId,
        type: 'Crop Added',
        cropId: crop.id,
        cropName: crop.cropName,
        title: '${crop.cropName} added',
        description: '${crop.cropName} is at ${crop.currentStage} stage.',
        metadata: {'stage': crop.currentStage},
        createdAt: crop.createdAt,
      );
    }).toList();

    history.add(
      FarmHistoryModel(
        id: 'history_advisory_${now.microsecondsSinceEpoch}',
        userId: userId,
        type: 'Weather Advisory',
        title: 'Weather advisory reviewed',
        description:
            'Weather, fertilizer, and irrigation advisories are available.',
        metadata: const {},
        createdAt: now,
      ),
    );

    return history;
  }

  FarmHistoryModel reminderCompleted(ReminderModel reminder) {
    final now = DateTime.now();
    return FarmHistoryModel(
      id: 'history_reminder_${reminder.id}',
      userId: reminder.userId,
      type: 'Reminder Completed',
      cropId: reminder.cropId,
      cropName: reminder.cropName,
      relatedEntityId: reminder.id,
      title: reminder.title,
      description: 'Reminder marked as completed.',
      metadata: {'reminderType': reminder.type},
      createdAt: now,
    );
  }
}
