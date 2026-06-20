import 'package:flutter/material.dart';

import '../../models/reminder_model.dart';

class ReminderSummaryCard extends StatelessWidget {
  const ReminderSummaryCard({
    required this.reminders,
    super.key,
  });

  final List<ReminderModel> reminders;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pending Reminders',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reminders.isEmpty)
              const Text(
                'No upcoming crop reminders. Add irrigation or inspection tasks for your active crop.',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              )
            else
              ...reminders.take(3).map(
                    (reminder) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${reminder.title} - ${_dueText(reminder.scheduledAt)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _dueText(DateTime scheduledAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
    );
    final days = dueDay.difference(today).inDays;
    if (days <= 0) {
      return 'today';
    }
    if (days == 1) {
      return 'tomorrow';
    }
    return 'in $days days';
  }
}
