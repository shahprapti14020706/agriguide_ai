import 'dart:convert';
import 'dart:io';

import '../core/config/firebase_runtime.dart';
import '../core/constants/storage_paths.dart';
import '../core/errors/app_exception.dart';
import '../core/utils/crop_stage_utils.dart';
import '../models/crop_model.dart';
import '../repositories/crop_repository.dart';
import '../services/firebase_storage_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class CropProvider extends BaseProvider {
  CropProvider({
    required CropRepository cropRepository,
    required FirebaseStorageService storageService,
    required LocalStorageService localStorageService,
  })  : _cropRepository = cropRepository,
        _storageService = storageService,
        _localStorageService = localStorageService;

  static String localCropsKey(String userId) => 'crops_$userId';

  final CropRepository _cropRepository;
  final FirebaseStorageService _storageService;
  final LocalStorageService _localStorageService;

  final List<CropModel> _crops = [];
  String? _successMessage;

  List<CropModel> get crops => List.unmodifiable(_crops);
  String? get successMessage => _successMessage;
  List<CropModel> get activeCrops =>
      _crops.where((crop) => crop.status == 'active').toList(growable: false);

  Future<void> loadCrops(String userId) async {
    setLoading();

    try {
      late final List<CropModel> crops;
      try {
        crops = await _cropRepository.getCrops(userId);
      } catch (_) {
        crops = _readLocalCrops(userId);
      }
      _crops
        ..clear()
        ..addAll(crops.map(_refreshStage));

      _crops.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  CropModel? cropById(String cropId) {
    for (final crop in _crops) {
      if (crop.id == cropId) {
        return crop;
      }
    }

    return null;
  }

  Future<void> addCrop(CropModel crop) async {
    await runGuarded(() async {
      var refreshedCrop = _refreshStage(crop);
      final duplicate = _crops.any(
        (item) =>
            item.cropName.trim().toLowerCase() ==
                refreshedCrop.cropName.trim().toLowerCase() &&
            item.sowingDate.year == refreshedCrop.sowingDate.year &&
            item.sowingDate.month == refreshedCrop.sowingDate.month &&
            item.sowingDate.day == refreshedCrop.sowingDate.day,
      );
      if (duplicate) {
        throw const AppException(
          'This crop is already registered for the selected sowing date.',
        );
      }

      try {
        final savedCropId = await _cropRepository.addCrop(refreshedCrop);
        refreshedCrop = refreshedCrop.copyWith(id: savedCropId);
      } catch (_) {
        _crops.insert(0, refreshedCrop);
        await _saveLocalCrops(refreshedCrop.userId);
        _successMessage = 'Crop saved locally';
        return;
      }

      _crops.insert(0, refreshedCrop);
      await _saveLocalCrops(refreshedCrop.userId);
      _successMessage = 'Crop added successfully';
    });
  }

  Future<void> updateCrop(CropModel crop) async {
    await runGuarded(() async {
      final refreshedCrop = _refreshStage(
        crop.copyWith(updatedAt: DateTime.now()),
      );

      try {
        await _cropRepository.updateCrop(refreshedCrop);
      } catch (_) {
        final index = _crops.indexWhere((item) => item.id == refreshedCrop.id);
        if (index == -1) {
          _crops.insert(0, refreshedCrop);
        } else {
          _crops[index] = refreshedCrop;
        }

        await _saveLocalCrops(refreshedCrop.userId);
        _successMessage = 'Crop updated locally';
        return;
      }

      final index = _crops.indexWhere((item) => item.id == refreshedCrop.id);
      if (index == -1) {
        _crops.insert(0, refreshedCrop);
      } else {
        _crops[index] = refreshedCrop;
      }

      await _saveLocalCrops(refreshedCrop.userId);
      _successMessage = 'Crop updated successfully';
    });
  }

  Future<CropModel> attachCropImage({
    required CropModel crop,
    required File imageFile,
  }) async {
    final imageUrl = await _resolveCropImageUrl(
      userId: crop.userId,
      cropId: crop.id,
      imageFile: imageFile,
    );
    final updatedCrop = crop.copyWith(
      imageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    await updateCrop(updatedCrop);
    return updatedCrop;
  }

  Future<void> deleteCrop(String userId, String cropId) async {
    await runGuarded(() async {
      try {
        await _cropRepository.deleteCrop(userId, cropId);
      } catch (_) {
        _crops.removeWhere((crop) => crop.id == cropId);
        await _saveLocalCrops(userId);
        _successMessage = 'Crop removed locally';
        return;
      }

      _crops.removeWhere((crop) => crop.id == cropId);
      await _saveLocalCrops(userId);
      _successMessage = 'Crop removed successfully';
    });
  }

  CropStageEstimate estimateStage(CropModel crop) {
    final ageDays = CropStageUtils.calculateCropAgeDays(crop.sowingDate);
    final totalDays = crop.expectedHarvestDate
        .difference(crop.sowingDate)
        .inDays
        .clamp(1, 10000);
    final progress = (ageDays / totalDays).clamp(0, 1).toDouble();

    final stage = switch (progress) {
      < 0.10 => 'Germination',
      < 0.22 => 'Seedling',
      < 0.48 => 'Vegetative',
      < 0.66 => 'Flowering',
      < 0.84 => 'Fruiting',
      < 0.96 => 'Maturity',
      _ => 'Harvesting',
    };

    return CropStageEstimate(
      ageDays: ageDays < 0 ? 0 : ageDays,
      stageName: stage,
      progress: progress,
      upcomingActivities: _activitiesForStage(stage),
    );
  }

  void clearMessages() {
    _successMessage = null;
    resetState();
  }

  CropModel _refreshStage(CropModel crop) {
    final estimate = estimateStage(crop);

    return crop.copyWith(
      currentStage: estimate.stageName,
      cropAgeDays: estimate.ageDays,
    );
  }

  Future<String> _resolveCropImageUrl({
    required String userId,
    required String cropId,
    required File imageFile,
  }) async {
    if (!FirebaseRuntime.isAvailable) {
      return imageFile.path;
    }

    final storagePath = '${StoragePaths.cropImages(userId)}/$cropId.jpg';
    try {
      return await _storageService.uploadFile(
        storagePath: storagePath,
        file: imageFile,
      );
    } catch (_) {
      return imageFile.path;
    }
  }

  List<CropModel> _readLocalCrops(String userId) {
    final raw = _localStorageService.getString(localCropsKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => CropModel.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> _saveLocalCrops(String userId) {
    final data = _crops.map((crop) => crop.toJson()).toList(growable: false);
    return _localStorageService.setString(
      localCropsKey(userId),
      jsonEncode(data),
    );
  }

  List<String> _activitiesForStage(String stage) {
    return switch (stage) {
      'Germination' => const [
          'Check seed emergence and field moisture',
          'Protect young seedlings from waterlogging',
        ],
      'Seedling' => const [
          'Inspect for early pest activity',
          'Maintain light irrigation if soil is dry',
        ],
      'Vegetative' => const [
          'Monitor nutrient demand and weed pressure',
          'Plan fertilizer application based on crop condition',
        ],
      'Flowering' => const [
          'Avoid moisture stress during flowering',
          'Inspect for disease symptoms before spraying',
        ],
      'Fruiting' => const [
          'Track fruit or grain development',
          'Adjust irrigation based on rainfall and soil moisture',
        ],
      'Maturity' => const [
          'Prepare harvesting labor and storage',
          'Reduce irrigation where crop practice recommends it',
        ],
      _ => const [
          'Check harvest readiness',
          'Plan post-harvest handling and market timing',
        ],
    };
  }
}

class CropStageEstimate {
  const CropStageEstimate({
    required this.ageDays,
    required this.stageName,
    required this.progress,
    required this.upcomingActivities,
  });

  final int ageDays;
  final String stageName;
  final double progress;
  final List<String> upcomingActivities;
}
