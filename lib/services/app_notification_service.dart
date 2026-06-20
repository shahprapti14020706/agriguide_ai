import '../models/notification_model.dart';

class AppNotificationService {
  List<NotificationModel> fallbackNotifications(String userId) {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'local_weather_alert',
        userId: userId,
        title: 'Weather Alert',
        body: 'Review weather advisory before spraying or irrigation.',
        type: 'Weather Alert',
        read: false,
        sentAt: now,
      ),
      NotificationModel(
        id: 'local_market_alert',
        userId: userId,
        title: 'Market Price Alert',
        body: 'Check latest market prices for active crops.',
        type: 'Market Price Alert',
        read: false,
        sentAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }
}
