import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/business/business_cards.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({required this.notificationId, super.key});

  final String notificationId;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final provider = context.watch<NotificationProvider>();
    final notification = provider.byId(notificationId);
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(title: Text(strings.notifications)),
      body: SafeArea(
        child: notification == null
            ? BusinessStateView(message: strings.noData)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BusinessSection(
                    title: notification.title,
                    children: [
                      DetailRow(label: strings.type, value: notification.type),
                      DetailRow(
                        label: strings.description,
                        value: notification.body,
                      ),
                      DetailRow(
                        label: strings.status,
                        value: notification.read ? 'Read' : 'Unread',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: user == null || notification.read
                        ? null
                        : () => provider.markAsRead(user.id, notification.id),
                    icon: const Icon(Icons.mark_email_read_outlined),
                    label: Text(strings.markRead),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: user == null
                        ? null
                        : () async {
                            await provider.deleteNotification(
                              user.id,
                              notification.id,
                            );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                    icon: const Icon(Icons.delete_outline),
                    label: Text(strings.delete),
                  ),
                ],
              ),
      ),
    );
  }
}
