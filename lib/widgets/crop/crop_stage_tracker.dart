import 'package:flutter/material.dart';

import '../../providers/crop_provider.dart';

class CropStageTracker extends StatelessWidget {
  const CropStageTracker({
    required this.estimate,
    super.key,
  });

  final CropStageEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = (estimate.progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                estimate.stageName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: estimate.progress,
          minHeight: 10,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: 12),
        Text(
          '${estimate.ageDays} days after sowing',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Upcoming activities',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        ...estimate.upcomingActivities.map(
          (activity) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(activity)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
