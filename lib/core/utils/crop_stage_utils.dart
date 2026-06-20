abstract final class CropStageUtils {
  static int calculateCropAgeDays(DateTime sowingDate, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return DateTime(today.year, today.month, today.day)
        .difference(
          DateTime(sowingDate.year, sowingDate.month, sowingDate.day),
        )
        .inDays;
  }
}
