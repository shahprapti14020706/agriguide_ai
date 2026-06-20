import '../core/constants/firestore_paths.dart';
import '../models/government_scheme_model.dart';
import '../services/firestore_service.dart';

abstract class SchemeRepository {
  Future<List<GovernmentSchemeModel>> getActiveSchemes();

  Future<List<GovernmentSchemeModel>> recommendSchemes({
    required String state,
    required String crop,
    String? farmerCategory,
    double? farmSize,
  });

  Future<GovernmentSchemeModel?> getScheme(String schemeId);
}

class FirebaseSchemeRepository implements SchemeRepository {
  FirebaseSchemeRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<GovernmentSchemeModel>> getActiveSchemes() async {
    final data = await _firestoreService.getCollection(
      FirestoreCollections.schemes,
      queryBuilder: (collection) => collection.where(
        'active',
        isEqualTo: true,
      ),
    );

    final schemes = data
        .map((item) => GovernmentSchemeModel.fromMap(item))
        .toList(growable: false);
    return _sortByName(schemes);
  }

  @override
  Future<List<GovernmentSchemeModel>> recommendSchemes({
    required String state,
    required String crop,
    String? farmerCategory,
    double? farmSize,
  }) async {
    final data = await _firestoreService.getCollection(
      FirestoreCollections.schemes,
      queryBuilder: (collection) => collection
          .where('active', isEqualTo: true)
          .where('states', arrayContains: state),
    );

    final schemes =
        data.map((item) => GovernmentSchemeModel.fromMap(item)).where((scheme) {
      final cropMatches = scheme.crops.isEmpty || scheme.crops.contains(crop);
      final categoryMatches = farmerCategory == null ||
          scheme.farmerCategories.isEmpty ||
          scheme.farmerCategories.contains(farmerCategory);
      final minFarmSize = scheme.minFarmSize;
      final maxFarmSize = scheme.maxFarmSize;
      final minMatches =
          farmSize == null || minFarmSize == null || farmSize >= minFarmSize;
      final maxMatches =
          farmSize == null || maxFarmSize == null || farmSize <= maxFarmSize;

      return cropMatches && categoryMatches && minMatches && maxMatches;
    }).toList(growable: false);
    return _sortByName(schemes);
  }

  @override
  Future<GovernmentSchemeModel?> getScheme(String schemeId) async {
    final data = await _firestoreService.getDocument(
      FirestorePaths.scheme(schemeId),
    );

    return data == null
        ? null
        : GovernmentSchemeModel.fromMap(data, id: schemeId);
  }

  List<GovernmentSchemeModel> _sortByName(
    List<GovernmentSchemeModel> schemes,
  ) {
    return schemes.toList(growable: false)
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
  }
}
