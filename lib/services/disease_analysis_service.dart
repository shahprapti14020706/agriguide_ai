import '../models/crop_model.dart';
import '../models/disease_report_model.dart';
import 'disease_recommendation_engine.dart';
import 'disease_severity_analyzer.dart';

class DiseaseAnalysisService {
  DiseaseAnalysisService({
    required DiseaseSeverityAnalyzer severityAnalyzer,
    required DiseaseRecommendationEngine recommendationEngine,
  })  : _severityAnalyzer = severityAnalyzer,
        _recommendationEngine = recommendationEngine;

  final DiseaseSeverityAnalyzer _severityAnalyzer;
  final DiseaseRecommendationEngine _recommendationEngine;

  Future<DiseaseReportModel> analyzeImage({
    required String id,
    required String userId,
    required String cropId,
    required String imageUrl,
    required String imageName,
    required String plantPart,
    CropModel? crop,
    DateTime? createdAt,
  }) async {
    final result = _localAnalyze(
      imageName: imageName,
      plantPart: plantPart,
      crop: crop,
    );
    final severity = _severityAnalyzer.analyze(
      confidenceScore: result.confidenceScore,
      plantPart: plantPart,
    );
    final advisory = _recommendationEngine.buildAdvisory(
      analysis: result,
      severity: severity,
      crop: crop,
    );

    return DiseaseReportModel(
      id: id,
      userId: userId,
      cropId: cropId,
      imageUrl: imageUrl,
      plantPart: plantPart,
      diseaseName: result.possibleDisease,
      confidenceScore: result.confidenceScore,
      severity: severity.level,
      symptoms: advisory.symptoms,
      causes: advisory.causes,
      treatment: advisory.treatment,
      prevention: advisory.prevention,
      recommendedAction: advisory.expertAdvice,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  DiseaseAnalysisResult _localAnalyze({
    required String imageName,
    required String plantPart,
    CropModel? crop,
  }) {
    final name = imageName.toLowerCase();
    final cropName = crop?.cropName.toLowerCase() ?? '';

    if (name.contains('mildew') || cropName.contains('grape')) {
      return DiseaseAnalysisResult(
        possibleDisease: 'Powdery Mildew',
        confidenceScore: 0.74,
        plantPart: plantPart,
      );
    }

    if (name.contains('blight') || cropName.contains('tomato')) {
      return DiseaseAnalysisResult(
        possibleDisease: 'Blight',
        confidenceScore: 0.81,
        plantPart: plantPart,
      );
    }

    return DiseaseAnalysisResult(
      possibleDisease: 'Leaf Spot',
      confidenceScore: 0.68,
      plantPart: plantPart,
    );
  }
}

class DiseaseAnalysisResult {
  const DiseaseAnalysisResult({
    required this.possibleDisease,
    required this.confidenceScore,
    required this.plantPart,
  });

  final String possibleDisease;
  final double confidenceScore;
  final String plantPart;
}
