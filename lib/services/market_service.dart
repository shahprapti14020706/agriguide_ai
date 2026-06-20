import '../models/crop_model.dart';
import '../models/market_price_model.dart';
import '../models/user_profile_model.dart';

class MarketService {
  List<MarketPriceModel> fallbackPrices({
    UserProfileModel? profile,
    List<CropModel> crops = const [],
  }) {
    final now = DateTime.now();
    final state =
        profile?.state.isNotEmpty == true ? profile!.state : 'Maharashtra';
    final district =
        profile?.district.isNotEmpty == true ? profile!.district : 'Pune';
    final cropNames = crops.isEmpty
        ? const ['Tomato', 'Wheat', 'Soybean']
        : crops.map((crop) => crop.cropName).toSet().toList(growable: false);

    return cropNames.asMap().entries.map((entry) {
      final index = entry.key;
      final crop = entry.value;
      final average = 1800 + (index * 420);
      return MarketPriceModel(
        id: 'local_market_${crop.toLowerCase()}_$index',
        cropName: crop,
        marketName: '$district APMC',
        district: district,
        state: state,
        minimumPrice: average - 250,
        maximumPrice: average + 350,
        averagePrice: average.toDouble(),
        unit: 'quintal',
        priceDate: now.subtract(Duration(days: index)),
        trendDirection: index.isEven ? 'up' : 'stable',
        advisoryNote: index.isEven
            ? 'Prices are improving. Consider selling graded produce in batches.'
            : 'Prices are stable. Compare nearby markets before selling.',
      );
    }).toList(growable: false);
  }

  List<MarketPriceModel> filterPrices({
    required List<MarketPriceModel> prices,
    String query = '',
    String state = '',
    String district = '',
    String market = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedState = state.trim().toLowerCase();
    final normalizedDistrict = district.trim().toLowerCase();
    final normalizedMarket = market.trim().toLowerCase();

    return prices.where((price) {
      final queryMatches = normalizedQuery.isEmpty ||
          price.cropName.toLowerCase().contains(normalizedQuery);
      final stateMatches = normalizedState.isEmpty ||
          price.state.toLowerCase().contains(normalizedState);
      final districtMatches = normalizedDistrict.isEmpty ||
          price.district.toLowerCase().contains(normalizedDistrict);
      final marketMatches = normalizedMarket.isEmpty ||
          price.marketName.toLowerCase().contains(normalizedMarket);
      return queryMatches && stateMatches && districtMatches && marketMatches;
    }).toList(growable: false);
  }

  String bestSellingSuggestion(MarketPriceModel price) {
    if (price.trendDirection == 'up') {
      return 'Sell high-quality produce in small batches while prices rise.';
    }
    if (price.trendDirection == 'down') {
      return 'Sell perishable produce soon and avoid long holding.';
    }
    return 'Compare market arrivals and sell when transport cost is favorable.';
  }
}
