import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../models/crop_model.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';
import '../services/local_storage_service.dart';
import '../services/reminder_service.dart';
import 'base_provider.dart';

class ReminderProvider extends BaseProvider {
  ReminderProvider({
    required ReminderRepository reminderRepository,
    required ReminderService reminderService,
    required LocalStorageService localStorageService,
  })  : _reminderRepository = reminderRepository,
        _reminderService = reminderService,
        _localStorageService = localStorageService;

  static String localRemindersKey(String userId) =>
      'business_reminders_$userId';

  final ReminderRepository _reminderRepository;
  final ReminderService _reminderService;
  final LocalStorageService _localStorageService;

  final List<ReminderModel> _reminders = [];

  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  List<ReminderModel> get upcoming => _reminders
      .where((reminder) => !reminder.completed)
      .toList(growable: false);

  Future<void> loadReminders(
    String userId, {
    List<CropModel> crops = const [],
  }) async {
    setLoading();
    try {
      final loaded = FirebaseRuntime.isAvailable
          ? await _reminderRepository.getReminders(userId)
          : _readLocal(userId);
      _reminders
        ..clear()
        ..addAll(loaded);
      if (_reminders.isEmpty && crops.isNotEmpty) {
        _reminders.addAll(
          _reminderService.generateCropStageReminders(
            userId: userId,
            crops: crops,
          ),
        );
        await _saveLocal(userId);
      }
      _reminders.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    await runGuarded(() async {
      var saved = reminder;
      if (FirebaseRuntime.isAvailable) {
        final id = await _reminderRepository.addReminder(reminder);
        saved = reminder.copyWith(id: id);
      }
      _replace(saved);
      await _saveLocal(saved.userId);
    });
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await runGuarded(() async {
      if (FirebaseRuntime.isAvailable) {
        await _reminderRepository.updateReminder(reminder);
      }
      _replace(reminder);
      await _saveLocal(reminder.userId);
    });
  }

  Future<void> complete(ReminderModel reminder) async {
    await updateReminder(_reminderService.markCompleted(reminder));
  }

  Future<void> snooze(ReminderModel reminder) async {
    await updateReminder(_reminderService.snooze(reminder));
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    await runGuarded(() async {
      if (FirebaseRuntime.isAvailable) {
        await _reminderRepository.deleteReminder(userId, reminderId);
      }
      _reminders.removeWhere((item) => item.id == reminderId);
      await _saveLocal(userId);
    });
  }

  ReminderModel? byId(String id) {
    for (final reminder in _reminders) {
      if (reminder.id == id) {
        return reminder;
      }
    }
    return null;
  }

  ReminderModel create({
    required String userId,
    required String title,
    required String description,
    required String type,
    required DateTime dueDate,
    required String priority,
    String? cropId,
    String? cropName,
  }) {
    return _reminderService.createReminder(
      userId: userId,
      title: title,
      description: description,
      type: type,
      dueDate: dueDate,
      priority: priority,
      cropId: cropId,
      cropName: cropName,
    );
  }

  void _replace(ReminderModel reminder) {
    final index = _reminders.indexWhere((item) => item.id == reminder.id);
    if (index == -1) {
      _reminders.insert(0, reminder);
    } else {
      _reminders[index] = reminder;
    }
  }

  List<ReminderModel> _readLocal(String userId) {
    final raw = _localStorageService.getString(localRemindersKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map((item) => ReminderModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> _saveLocal(String userId) {
    final data =
        _reminders.map((item) => item.toJson()).toList(growable: false);
    return _localStorageService.setString(
      localRemindersKey(userId),
      jsonEncode(data),
    );
  }
}
