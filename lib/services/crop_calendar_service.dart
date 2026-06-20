import '../models/crop_calendar_model.dart';
import '../models/crop_model.dart';
import '../models/reminder_model.dart';

class CropCalendarService {
  CropCalendarModel buildCalendar(CropModel crop) {
    final now = DateTime.now();
    final activities = [
      _activity('Irrigation', crop.sowingDate.add(const Duration(days: 3))),
      _activity('Fertilizer', crop.sowingDate.add(const Duration(days: 15))),
      _activity('Spraying', crop.sowingDate.add(const Duration(days: 30))),
      _activity('Harvesting', crop.expectedHarvestDate),
    ];
    return CropCalendarModel(
      id: 'calendar_${crop.id}',
      userId: crop.userId,
      cropId: crop.id,
      cropName: crop.cropName,
      activities: activities,
      createdAt: now,
    );
  }

  List<ReminderModel> remindersFromCalendar(CropCalendarModel calendar) {
    return calendar.activities.map((activity) {
      return ReminderModel(
        id: 'calendar_${calendar.cropId}_${activity.type}',
        userId: calendar.userId,
        cropId: calendar.cropId,
        cropName: calendar.cropName,
        type: activity.type,
        title: '${activity.type} - ${calendar.cropName}',
        description: activity.description,
        scheduledAt: activity.scheduledDate,
        completed: false,
        priority: 'normal',
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  CropCalendarActivityModel _activity(String type, DateTime date) {
    return CropCalendarActivityModel(
      type: type,
      title: type,
      description: '$type activity scheduled from crop calendar.',
      scheduledDate: date,
    );
  }
}
