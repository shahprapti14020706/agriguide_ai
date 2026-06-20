import 'package:flutter/material.dart';

import '../../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          notification.read
              ? Icons.notifications_none_outlined
              : Icons.notifications_active_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(notification.title),
        subtitle: Text(notification.body),
        trailing: notification.read
            ? null
            : Icon(
                Icons.circle,
                size: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
      ),
    );
  }
}
