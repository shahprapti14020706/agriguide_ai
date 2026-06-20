import 'package:flutter/material.dart';

import '../../models/reminder_model.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    required this.reminder,
    required this.onTap,
    required this.onComplete,
    required this.onSnooze,
    super.key,
  });

  final ReminderModel reminder;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onSnooze;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          reminder.completed
              ? Icons.check_circle_outline
              : Icons.notifications_active_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(reminder.title),
        subtitle: Text(
          '${reminder.type} • ${reminder.scheduledAt.day}/${reminder.scheduledAt.month}/${reminder.scheduledAt.year}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'complete') {
              onComplete();
            } else if (value == 'snooze') {
              onSnooze();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'complete', child: Text('Complete')),
            PopupMenuItem(value: 'snooze', child: Text('Snooze')),
          ],
        ),
      ),
    );
  }
}
