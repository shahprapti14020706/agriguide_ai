import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firestore_paths.dart';
import '../models/market_price_model.dart';
import '../services/firestore_service.dart';

abstract class MarketRepository {
  Future<List<MarketPriceModel>> searchMarketPrices({
    required String cropName,
    String? state,
    String? district,
  });

  Stream<List<MarketPriceModel>> watchMarketPrices({
    required String cropName,
    String? state,
    String? district,
  });
}

class FirebaseMarketRepository implements MarketRepository {
  FirebaseMarketRepository(this._firestoreService);

  final FirestoreService _firestoreService;

  @override
  Future<List<MarketPriceModel>> searchMarketPrices({
    required String cropName,
    String? state,
    String? district,
  }) async {
    final data = await _firestoreService.getCollection(
      FirestoreCollections.marketPrices,
      queryBuilder: (collection) =>
          _marketQuery(collection, cropName, state, district),
    );

    return data
        .map((item) => MarketPriceModel.fromMap(item))
        .toList(growable: false)
      ..sort((a, b) => b.priceDate.compareTo(a.priceDate));
  }

  @override
  Stream<List<MarketPriceModel>> watchMarketPrices({
    required String cropName,
    String? state,
    String? district,
  }) {
    return _firestoreService
        .watchCollection(
          FirestoreCollections.marketPrices,
          queryBuilder: (collection) =>
              _marketQuery(collection, cropName, state, district),
        )
        .map(
          (items) => items
              .map((item) => MarketPriceModel.fromMap(item))
              .toList(growable: false)
            ..sort((a, b) => b.priceDate.compareTo(a.priceDate)),
        );
  }

  Query<Map<String, dynamic>> _marketQuery(
    CollectionReference<Map<String, dynamic>> collection,
    String cropName,
    String? state,
    String? district,
  ) {
    Query<Map<String, dynamic>> query = collection.where(
      'cropName',
      isEqualTo: cropName,
    );

    if (state != null && state.isNotEmpty) {
      query = query.where('state', isEqualTo: state);
    }

    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }

    return query;
  }
}
