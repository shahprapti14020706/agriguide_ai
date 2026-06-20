import 'package:flutter/material.dart';

import '../../models/crop_model.dart';
import '../../providers/crop_provider.dart';
import 'crop_stage_tracker.dart';

class ActiveCropCard extends StatelessWidget {
  const ActiveCropCard({
    required this.crop,
    required this.stageEstimate,
    this.onTap,
    super.key,
  });

  final CropModel crop;
  final CropStageEstimate stageEstimate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.grass,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.cropName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        Text(
                          '${crop.variety} • ${crop.areaUnderCultivation} acres',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 16),
              CropStageTracker(estimate: stageEstimate),
            ],
          ),
        ),
      ),
    );
  }
}
