import '../core/utils/map_utils.dart';

class MarketPriceModel {
  const MarketPriceModel({
    required this.id,
    required this.cropName,
    required this.marketName,
    required this.district,
    required this.state,
    required this.minimumPrice,
    required this.maximumPrice,
    required this.averagePrice,
    required this.unit,
    required this.priceDate,
    required this.trendDirection,
    required this.advisoryNote,
  });

  final String id;
  final String cropName;
  final String marketName;
  final String district;
  final String state;
  final double minimumPrice;
  final double maximumPrice;
  final double averagePrice;
  final String unit;
  final DateTime priceDate;
  final String trendDirection;
  final String advisoryNote;

  factory MarketPriceModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MarketPriceModel(
      id: id ?? map['id'] as String? ?? '',
      cropName: map['cropName'] as String? ?? '',
      marketName: map['marketName'] as String? ?? '',
      district: map['district'] as String? ?? '',
      state: map['state'] as String? ?? '',
      minimumPrice: (map['minimumPrice'] as num?)?.toDouble() ?? 0,
      maximumPrice: (map['maximumPrice'] as num?)?.toDouble() ?? 0,
      averagePrice: (map['averagePrice'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'quintal',
      priceDate: MapUtils.dateTimeFromValue(map['priceDate']) ??
          MapUtils.dateTimeFromValue(map['updatedAt']) ??
          DateTime.now(),
      trendDirection: map['trendDirection'] as String? ?? 'stable',
      advisoryNote: map['advisoryNote'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'marketName': marketName,
      'district': district,
      'state': state,
      'minimumPrice': minimumPrice,
      'maximumPrice': maximumPrice,
      'averagePrice': averagePrice,
      'unit': unit,
      'priceDate': priceDate,
      'trendDirection': trendDirection,
      'advisoryNote': advisoryNote,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel.fromMap(json);
  }
}
