import '../models/crop_model.dart';
import 'disease_analysis_service.dart';
import 'disease_severity_analyzer.dart';

class DiseaseRecommendationEngine {
  DiseaseAdvisory buildAdvisory({
    required DiseaseAnalysisResult analysis,
    required DiseaseSeverityResult severity,
    CropModel? crop,
  }) {
    final cropName = crop?.cropName ?? 'the crop';
    final stage = crop?.currentStage ?? 'current';

    return DiseaseAdvisory(
      symptoms: _symptoms(analysis.possibleDisease, analysis.plantPart),
      causes: _causes(analysis.possibleDisease),
      treatment: _treatment(
        cropName,
        stage,
        severity.level,
      ),
      prevention: _prevention(),
      expertAdvice: _expertAdvice(severity.level),
    );
  }

  List<String> _symptoms(String disease, String plantPart) {
    return switch (disease) {
      'Leaf Spot' => [
          'Circular or irregular spots on $plantPart',
          'Yellowing around affected tissue',
          'Drying of older infected areas',
        ],
      'Blight' => [
          'Rapid browning or burning of leaf edges',
          'Dark lesions spreading across plant tissue',
          'Weak or collapsing affected areas',
        ],
      'Powdery Mildew' => [
          'White powder-like growth on plant surface',
          'Leaf curling or dull green appearance',
          'Reduced vigor in affected plants',
        ],
      _ => [
          'Visible stress or discoloration on $plantPart',
          'Uneven plant growth or affected tissue',
          'Symptoms require closer field confirmation',
        ],
    };
  }

  List<String> _causes(String disease) {
    return switch (disease) {
      'Leaf Spot' => const [
          'High humidity and leaf wetness',
          'Infected crop residue or seed material',
          'Dense canopy with poor airflow',
        ],
      'Blight' => const [
          'Warm humid weather',
          'Rapid pathogen spread from infected plants',
          'Delayed removal of affected plant material',
        ],
      'Powdery Mildew' => const [
          'Dry days with humid nights',
          'Poor air circulation',
          'Susceptible variety or stressed crop',
        ],
      _ => const [
          'Nutrient stress, pathogen infection, or pest damage',
          'Weather stress and unsuitable field conditions',
          'Unconfirmed symptoms needing field inspection',
        ],
    };
  }

  List<String> _treatment(
    String cropName,
    String stage,
    String severity,
  ) {
    return [
      'Inspect multiple $cropName plants at $stage stage before treatment.',
      'Remove severely affected plant parts where practical.',
      if (severity == 'High')
        'Consult a local agriculture officer before chemical application.',
      'Use only crop-approved fungicide or biological treatment based on local recommendation.',
    ];
  }

  List<String> _prevention() {
    return const [
      'Use clean seed or healthy planting material.',
      'Avoid overhead irrigation when disease symptoms are visible.',
      'Maintain spacing and airflow within the crop.',
      'Remove infected crop residue after harvest.',
      'Rotate crops where the disease is recurring.',
    ];
  }

  String _expertAdvice(String severity) {
    return switch (severity) {
      'High' =>
        'Contact an agriculture expert immediately if symptoms are spreading or more than 10 percent of plants are affected.',
      'Moderate' =>
        'Contact an expert if symptoms increase within 3 to 5 days after treatment or monitoring.',
      _ =>
        'Contact an expert if diagnosis is unclear or symptoms appear on new plants.',
    };
  }
}

class DiseaseAdvisory {
  const DiseaseAdvisory({
    required this.symptoms,
    required this.causes,
    required this.treatment,
    required this.prevention,
    required this.expertAdvice,
  });

  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatment;
  final List<String> prevention;
  final String expertAdvice;
}
