import '../core/constants/firestore_paths.dart';
import '../models/disease_report_model.dart';
import '../services/firestore_service.dart';

abstract class DiseaseRepository {
  Future<List<DiseaseReportModel>> getDiseaseReports(String userId);

  Stream<List<DiseaseReportModel>> watchDiseaseReports(String userId);

  Future<String> saveDiseaseReport(DiseaseReportModel report);

  Future<void> deleteDiseaseReport(String userId, String reportId);
}

class FirebaseDiseaseRepository implements DiseaseRepository {
  FirebaseDiseaseRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<DiseaseReportModel>> getDiseaseReports(String userId) async {
    final data = await _firestoreService.getCollection(
      FirestorePaths.userDiseaseReports(userId),
      queryBuilder: (collection) => collection.orderBy(
        'createdAt',
        descending: true,
      ),
    );

    return data
        .map((item) => DiseaseReportModel.fromMap(item))
        .toList(growable: false);
  }

  @override
  Stream<List<DiseaseReportModel>> watchDiseaseReports(String userId) {
    return _firestoreService
        .watchCollection(
          FirestorePaths.userDiseaseReports(userId),
          queryBuilder: (collection) => collection.orderBy(
            'createdAt',
            descending: true,
          ),
        )
        .map(
          (items) => items
              .map((item) => DiseaseReportModel.fromMap(item))
              .toList(growable: false),
        );
  }

  @override
  Future<String> saveDiseaseReport(DiseaseReportModel report) {
    return _firestoreService.setDocumentWithId(
      collectionPath: FirestorePaths.userDiseaseReports(report.userId),
      documentId: report.id,
      data: report.toMap(),
    );
  }

  @override
  Future<void> deleteDiseaseReport(String userId, String reportId) {
    return _firestoreService.deleteDocument(
      FirestorePaths.userDiseaseReport(userId, reportId),
    );
  }
}
