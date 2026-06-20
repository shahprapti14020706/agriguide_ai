import '../models/crop_calendar_model.dart';
import '../models/crop_model.dart';
import '../models/reminder_model.dart';
import '../services/crop_calendar_service.dart';
import 'base_provider.dart';

class CropCalendarProvider extends BaseProvider {
  CropCalendarProvider({required CropCalendarService cropCalendarService})
      : _cropCalendarService = cropCalendarService;

  final CropCalendarService _cropCalendarService;
  final List<CropCalendarModel> _calendars = [];

  List<CropCalendarModel> get calendars => List.unmodifiable(_calendars);

  void buildCalendars(List<CropModel> crops) {
    _calendars
      ..clear()
      ..addAll(crops.map(_cropCalendarService.buildCalendar));
    _calendars.isEmpty ? setEmpty() : setSuccess();
  }

  List<ReminderModel> generatedReminders() {
    return _calendars
        .expand(_cropCalendarService.remindersFromCalendar)
        .toList(growable: false);
  }
}
