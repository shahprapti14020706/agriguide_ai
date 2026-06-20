import '../models/crop_model.dart';
import '../models/crop_stage_tracking_model.dart';
import '../services/crop_stage_service.dart';
import 'base_provider.dart';

class CropStageProvider extends BaseProvider {
  CropStageProvider({required CropStageService cropStageService})
      : _cropStageService = cropStageService;

  final CropStageService _cropStageService;
  final Map<String, CropStageModel> _currentStages = {};
  final Map<String, List<CropStageModel>> _history = {};

  CropStageModel? stageFor(String cropId) => _currentStages[cropId];
  List<CropStageModel> historyFor(String cropId) =>
      _history[cropId] ?? const [];

  void calculateForCrops(List<CropModel> crops) {
    for (final crop in crops) {
      final stage = _cropStageService.calculateStage(crop);
      _currentStages[crop.id] = stage;
      _history.putIfAbsent(crop.id, () => []).insert(0, stage);
    }
    setSuccess();
  }

  void overrideStage(CropModel crop, String stageName) {
    final stage = _cropStageService.calculateStage(
      crop,
      manualStage: stageName,
    );
    _currentStages[crop.id] = stage;
    _history.putIfAbsent(crop.id, () => []).insert(0, stage);
    setSuccess();
  }
}
