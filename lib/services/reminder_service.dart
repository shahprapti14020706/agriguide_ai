import '../models/crop_model.dart';
import '../models/reminder_model.dart';

class ReminderService {
  List<ReminderModel> generateCropStageReminders({
    required String userId,
    required List<CropModel> crops,
  }) {
    final now = DateTime.now();
    return crops.take(3).map((crop) {
      final stage = crop.currentStage.toLowerCase();
      final type = stage.contains('harvest')
          ? 'Harvesting'
          : stage.contains('flower') || stage.contains('fruit')
              ? 'Disease Inspection'
              : 'Irrigation';
      return ReminderModel(
        id: 'auto_${crop.id}_${type.toLowerCase().replaceAll(' ', '_')}',
        userId: userId,
        cropId: crop.id,
        cropName: crop.cropName,
        type: type,
        title: '$type - ${crop.cropName}',
        description:
            'Recommended $type activity for ${crop.cropName} at ${crop.currentStage} stage.',
        scheduledAt: now.add(const Duration(days: 1)),
        completed: false,
        priority: type == 'Disease Inspection' ? 'high' : 'normal',
        createdAt: now,
      );
    }).toList(growable: false);
  }

  ReminderModel createReminder({
    required String userId,
    required String title,
    required String description,
    required String type,
    required DateTime dueDate,
    required String priority,
    String? cropId,
    String? cropName,
  }) {
    final now = DateTime.now();
    return ReminderModel(
      id: 'reminder_${now.microsecondsSinceEpoch}',
      userId: userId,
      cropId: cropId,
      cropName: cropName,
      type: type,
      title: title,
      description: description,
      scheduledAt: dueDate,
      completed: false,
      priority: priority,
      createdAt: now,
    );
  }

  ReminderModel markCompleted(ReminderModel reminder) {
    final now = DateTime.now();
    return reminder.copyWith(
      completed: true,
      status: 'completed',
      completedAt: now,
    );
  }

  ReminderModel snooze(ReminderModel reminder) {
    return reminder.copyWith(
      snoozedUntil: DateTime.now().add(const Duration(days: 1)),
      status: 'snoozed',
    );
  }
}
