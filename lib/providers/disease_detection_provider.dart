import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../core/errors/app_exception.dart';
import '../models/crop_model.dart';
import '../models/disease_report_model.dart';
import '../repositories/disease_repository.dart';
import '../services/disease_analysis_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/local_storage_service.dart';
import 'base_provider.dart';

class DiseaseDetectionProvider extends BaseProvider {
  DiseaseDetectionProvider({
    required DiseaseRepository diseaseRepository,
    required DiseaseAnalysisService diseaseAnalysisService,
    required FirebaseStorageService storageService,
    required LocalStorageService localStorageService,
  })  : _diseaseAnalysisService = diseaseAnalysisService,
        _localStorageService = localStorageService;

  static String _localReportsKey(String userId) => 'disease_reports_$userId';

  final DiseaseAnalysisService _diseaseAnalysisService;
  final LocalStorageService _localStorageService;

  final List<DiseaseReportModel> _reports = [];
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  DiseaseReportModel? _latestReport;
  String? _successMessage;

  List<DiseaseReportModel> get reports => List.unmodifiable(_reports);
  XFile? get selectedImage => _selectedImage;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  DiseaseReportModel? get latestReport => _latestReport;
  String? get successMessage => _successMessage;

  Future<void> selectImage(XFile image) async {
    _selectedImage = image;
    _selectedImageBytes = await image.readAsBytes();
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    _selectedImageBytes = null;
    notifyListeners();
  }

  Future<void> loadReports(String userId) async {
    setLoading();

    try {
      final reports = _readLocalReports(userId);
      _reports
        ..clear()
        ..addAll(reports);
      _reports.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  DiseaseReportModel? reportById(String reportId) {
    for (final report in _reports) {
      if (report.id == reportId) {
        return report;
      }
    }

    if (_latestReport?.id == reportId) {
      return _latestReport;
    }

    return null;
  }

  Future<DiseaseReportModel?> analyzeAndSave({
    required String userId,
    required CropModel crop,
    required XFile image,
    required String plantPart,
  }) async {
    setLoading();

    try {
      final now = DateTime.now();
      final reportId = 'disease_${now.microsecondsSinceEpoch}';
      final bytes = _selectedImageBytes ?? await image.readAsBytes();
      final imageUrl = _localImageUrl(image: image, bytes: bytes);
      final report = await _diseaseAnalysisService.analyzeImage(
        id: reportId,
        userId: userId,
        cropId: crop.id,
        imageUrl: imageUrl,
        imageName: image.name.isNotEmpty ? image.name : image.path,
        plantPart: plantPart,
        crop: crop,
        createdAt: now,
      );

      _reports.insert(0, report);
      _latestReport = report;
      _successMessage = 'Disease analysis completed';
      setSuccess();

      unawaited(_saveLocalReportsInBackground(userId));

      return report;
    } catch (error) {
      setFailure(
        AppException(
          'Disease analysis failed. Please try again.',
          cause: error,
        ),
      );
      return null;
    }
  }

  Future<void> _saveLocalReportsInBackground(String userId) async {
    try {
      await _saveLocalReports(userId);
    } catch (_) {
      // Local analysis result is already available in memory for the demo.
    }
  }

  Future<void> deleteReport(String userId, String reportId) async {
    await runGuarded(() async {
      _reports.removeWhere((report) => report.id == reportId);
      await _saveLocalReports(userId);
      _successMessage = 'Disease report removed';
    });
  }

  String _localImageUrl({
    required XFile image,
    required Uint8List bytes,
  }) {
    if (kIsWeb || image.path.isEmpty) {
      final mimeType = image.mimeType ?? 'image/jpeg';
      return 'data:$mimeType;base64,${base64Encode(bytes)}';
    }

    return image.path;
  }

  List<DiseaseReportModel> _readLocalReports(String userId) {
    final raw = _localStorageService.getString(_localReportsKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => DiseaseReportModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _saveLocalReports(String userId) {
    final data =
        _reports.map((report) => report.toJson()).toList(growable: false);
    return _localStorageService.setString(
      _localReportsKey(userId),
      jsonEncode(data),
    );
  }
}
