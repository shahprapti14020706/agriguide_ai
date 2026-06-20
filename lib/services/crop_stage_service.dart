import '../models/crop_model.dart';
import '../models/crop_stage_tracking_model.dart';

class CropStageService {
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

  CropStageModel calculateStage(CropModel crop, {String? manualStage}) {
    final now = DateTime.now();
    final totalDays = crop.expectedHarvestDate
        .difference(crop.sowingDate)
        .inDays
        .clamp(1, 500);
    final ageDays = now.difference(crop.sowingDate).inDays.clamp(0, totalDays);
    final index = manualStage == null
        ? ((ageDays / totalDays) * stages.length)
            .floor()
            .clamp(0, stages.length - 1)
        : stages.indexOf(manualStage).clamp(0, stages.length - 1);
    final stageLength = (totalDays / stages.length).ceil();
    final startedAt = crop.sowingDate.add(Duration(days: stageLength * index));
    final expectedEndAt = startedAt.add(Duration(days: stageLength));
    final daysInStage = now.difference(startedAt).inDays.clamp(0, stageLength);
    final daysRemaining =
        expectedEndAt.difference(now).inDays.clamp(0, stageLength);
    return CropStageModel(
      id: 'stage_${crop.id}_${now.microsecondsSinceEpoch}',
      cropId: crop.id,
      userId: crop.userId,
      stageName: manualStage ?? stages[index],
      startedAt: startedAt,
      expectedEndAt: expectedEndAt,
      daysInStage: daysInStage,
      daysRemaining: daysRemaining,
      progress: (ageDays / totalDays).clamp(0, 1).toDouble(),
      manualOverride: manualStage != null,
      createdAt: now,
    );
  }
}
