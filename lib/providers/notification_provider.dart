import 'dart:convert';

import '../core/config/firebase_runtime.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../services/app_notification_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class NotificationProvider extends BaseProvider {
  NotificationProvider({
    required NotificationRepository notificationRepository,
    required AppNotificationService notificationService,
    required LocalStorageService localStorageService,
  })  : _notificationRepository = notificationRepository,
        _notificationService = notificationService,
        _localStorageService = localStorageService;

  static String _localKey(String userId) => 'notifications_$userId';

  final NotificationRepository _notificationRepository;
  final AppNotificationService _notificationService;
  final LocalStorageService _localStorageService;

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((item) => !item.read).length;

  Future<void> loadNotifications(String userId) async {
    setLoading();
    try {
      final loaded = FirebaseRuntime.isAvailable
          ? await _notificationRepository.getNotifications(userId)
          : _readLocal(userId);
      _notifications
        ..clear()
        ..addAll(loaded);
      if (_notifications.isEmpty) {
        _notifications
            .addAll(_notificationService.fallbackNotifications(userId));
        await _saveLocal(userId);
      }
      _notifications.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await runGuarded(() async {
      if (FirebaseRuntime.isAvailable) {
        await _notificationRepository.markAsRead(userId, notificationId);
      }
      final index =
          _notifications.indexWhere((item) => item.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
      }
      await _saveLocal(userId);
    });
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    await runGuarded(() async {
      if (FirebaseRuntime.isAvailable) {
        await _notificationRepository.deleteNotification(
          userId,
          notificationId,
        );
      }
      _notifications.removeWhere((item) => item.id == notificationId);
      await _saveLocal(userId);
    });
  }

  NotificationModel? byId(String id) {
    for (final notification in _notifications) {
      if (notification.id == id) {
        return notification;
      }
    }
    return null;
  }

  List<NotificationModel> _readLocal(String userId) {
    final raw = _localStorageService.getString(_localKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map>()
        .map(
          (item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<void> _saveLocal(String userId) {
    final data =
        _notifications.map((item) => item.toJson()).toList(growable: false);
    return _localStorageService.setString(_localKey(userId), jsonEncode(data));
  }
}
