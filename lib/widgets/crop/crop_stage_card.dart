import 'package:flutter/material.dart';

import '../../models/crop_stage_tracking_model.dart';

class CropStageCard extends StatelessWidget {
  const CropStageCard({
    required this.stage,
    required this.onOverride,
    super.key,
  });

  final CropStageModel stage;
  final ValueChanged<String> onOverride;

  static const stages = [
    'Land Preparation',
    'Sowing',
    'Germination',
    'Vegetative Growth',
    'Flowering',
    'Fruiting/Grain Formation',
    'Maturity',
    'Harvest',
  ];

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
                  Icons.timeline_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stage.stageName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                DropdownButton<String>(
                  value: stages.contains(stage.stageName)
                      ? stage.stageName
                      : stages.first,
                  underline: const SizedBox.shrink(),
                  items: stages
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      onOverride(value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: stage.progress),
            const SizedBox(height: 12),
            Text('Days in current stage: ${stage.daysInStage}'),
            Text('Days remaining to next stage: ${stage.daysRemaining}'),
          ],
        ),
      ),
    );
  }
}
