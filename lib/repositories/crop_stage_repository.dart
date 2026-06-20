import '../core/constants/firestore_paths.dart';
import '../models/crop_stage_model.dart';
import '../services/firestore_service.dart';

abstract class CropStageRepository {
  Future<CropStageCalendarModel?> getCropStageCalendar(String cropName);

  Stream<CropStageCalendarModel?> watchCropStageCalendar(String cropName);
}

class FirebaseCropStageRepository implements CropStageRepository {
  FirebaseCropStageRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<CropStageCalendarModel?> getCropStageCalendar(String cropName) async {
    final data = await _firestoreService.getDocument(
      FirestorePaths.cropStages(cropName),
    );

    return data == null
        ? null
        : CropStageCalendarModel.fromMap(data, id: cropName);
  }

  @override
  Stream<CropStageCalendarModel?> watchCropStageCalendar(String cropName) {
    return _firestoreService
        .watchDocument(FirestorePaths.cropStages(cropName))
        .map(
          (data) => data == null
              ? null
              : CropStageCalendarModel.fromMap(data, id: cropName),
        );
  }
}
