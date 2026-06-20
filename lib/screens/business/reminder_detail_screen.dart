import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/business/business_cards.dart';

class ReminderDetailScreen extends StatelessWidget {
  const ReminderDetailScreen({required this.reminderId, super.key});

  final String reminderId;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final provider = context.watch<ReminderProvider>();
    final reminder = provider.byId(reminderId);
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.reminders),
        actions: [
          if (reminder != null)
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed(
                RouteNames.editReminder,
                arguments: reminder.id,
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: reminder == null
            ? BusinessStateView(message: strings.noData)
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BusinessSection(
                    title: reminder.title,
                    children: [
                      DetailRow(
                        label: strings.description,
                        value: reminder.description,
                      ),
                      DetailRow(
                        label: strings.reminderType,
                        value: reminder.type,
                      ),
                      DetailRow(
                        label: strings.priority,
                        value: reminder.priority,
                      ),
                      DetailRow(label: strings.status, value: reminder.status),
                      DetailRow(
                        label: strings.dueDate,
                        value:
                            '${reminder.scheduledAt.day}/${reminder.scheduledAt.month}/${reminder.scheduledAt.year}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: reminder.completed
                        ? null
                        : () => provider.complete(reminder),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(strings.markCompleted),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => provider.snooze(reminder),
                    icon: const Icon(Icons.snooze),
                    label: Text(strings.snooze),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: user == null
                        ? null
                        : () async {
                            await provider.deleteReminder(user.id, reminder.id);
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
