import '../models/crop_model.dart';
import '../models/government_scheme_model.dart';
import '../models/user_profile_model.dart';

class SchemeService {
  List<GovernmentSchemeModel> fallbackSchemes() {
    final now = DateTime.now();
    return [
      GovernmentSchemeModel(
        id: 'pm_kisan',
        name: 'PM Kisan Samman Nidhi',
        department: 'Ministry of Agriculture and Farmers Welfare',
        schemeLevel: 'Central',
        description: 'Income support scheme for eligible farmer families.',
        eligibility: const [
          'Farmer family with cultivable landholding',
          'Valid bank account and identity documents',
        ],
        benefits: const ['Direct income support in scheduled installments'],
        requiredDocuments: const ['Aadhaar', 'Bank account', 'Land record'],
        applicationProcess: const [
          'Visit official PM Kisan portal',
          'Complete farmer registration',
          'Submit documents for verification',
        ],
        officialLink: 'https://pmkisan.gov.in',
        deadline: null,
        crops: const [],
        states: const [],
        minFarmSize: null,
        maxFarmSize: null,
        farmerCategories: const [],
        active: true,
      ),
      GovernmentSchemeModel(
        id: 'soil_health_card',
        name: 'Soil Health Card',
        department: 'Department of Agriculture',
        schemeLevel: 'Central',
        description: 'Soil testing support for nutrient-based crop planning.',
        eligibility: const ['All farmers with agricultural land'],
        benefits: const ['Soil nutrient report', 'Fertilizer guidance'],
        requiredDocuments: const ['Farmer ID', 'Land details'],
        applicationProcess: const [
          'Contact local agriculture office',
          'Submit soil sample',
          'Collect soil health recommendation',
        ],
        officialLink: 'https://soilhealth.dac.gov.in',
        deadline: now.add(const Duration(days: 120)),
        crops: const [],
        states: const [],
        minFarmSize: null,
        maxFarmSize: null,
        farmerCategories: const [],
        active: true,
      ),
      GovernmentSchemeModel(
        id: 'micro_irrigation_subsidy',
        name: 'Micro Irrigation Subsidy',
        department: 'Agriculture Department',
        schemeLevel: 'State or Central',
        description: 'Subsidy support for drip and sprinkler irrigation.',
        eligibility: const ['Farmer with irrigation need', 'Valid land record'],
        benefits: const ['Subsidy for drip or sprinkler system'],
        requiredDocuments: const ['Aadhaar', 'Land record', 'Bank details'],
        applicationProcess: const [
          'Apply through agriculture department portal',
          'Select approved vendor',
          'Complete field verification',
        ],
        officialLink: '',
        deadline: now.add(const Duration(days: 90)),
        crops: const [],
        states: const ['Maharashtra', 'Karnataka', 'Gujarat'],
        minFarmSize: null,
        maxFarmSize: null,
        farmerCategories: const [],
        active: true,
      ),
    ];
  }

  List<GovernmentSchemeModel> recommendSchemes({
    required List<GovernmentSchemeModel> schemes,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
  }) {
    final state = profile?.state.toLowerCase() ?? '';
    final farmSize = profile?.farmSize;
    final cropNames = crops.map((crop) => crop.cropName).toSet();

    return schemes.where((scheme) {
      final stateMatches = scheme.states.isEmpty ||
          scheme.states.any((item) => item.toLowerCase() == state);
      final cropMatches =
          scheme.crops.isEmpty || scheme.crops.any(cropNames.contains);
      final minMatches = farmSize == null ||
          scheme.minFarmSize == null ||
          farmSize >= scheme.minFarmSize!;
      final maxMatches = farmSize == null ||
          scheme.maxFarmSize == null ||
          farmSize <= scheme.maxFarmSize!;
      return stateMatches && cropMatches && minMatches && maxMatches;
    }).toList(growable: false);
  }
}
