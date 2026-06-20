import '../core/config/firebase_runtime.dart';
import '../models/crop_model.dart';
import '../models/market_price_model.dart';
import '../models/user_profile_model.dart';
import '../repositories/market_repository.dart';
import '../services/market_service.dart';
import 'base_provider.dart';

class MarketProvider extends BaseProvider {
  MarketProvider({
    required MarketRepository marketRepository,
    required MarketService marketService,
  })  : _marketRepository = marketRepository,
        _marketService = marketService;

  final MarketRepository _marketRepository;
  final MarketService _marketService;

  List<MarketPriceModel> _prices = const [];
  List<MarketPriceModel> _filteredPrices = const [];

  List<MarketPriceModel> get prices => _filteredPrices;
  MarketPriceModel? get snapshot =>
      _filteredPrices.isEmpty ? null : _filteredPrices.first;

  Future<void> loadPrices({
    required String cropName,
    UserProfileModel? profile,
    List<CropModel> crops = const [],
    String state = '',
    String district = '',
    String market = '',
  }) async {
    setLoading();
    try {
      if (FirebaseRuntime.isAvailable && cropName.trim().isNotEmpty) {
        _prices = await _marketRepository.searchMarketPrices(
          cropName: cropName.trim(),
          state: state.isEmpty ? null : state,
          district: district.isEmpty ? null : district,
        );
      }
      if (_prices.isEmpty) {
        _prices = _marketService.fallbackPrices(profile: profile, crops: crops);
      }
      _filteredPrices = _marketService.filterPrices(
        prices: _prices,
        query: cropName,
        state: state,
        district: district,
        market: market,
      );
      _filteredPrices.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  void applyFilters({
    String query = '',
    String state = '',
    String district = '',
    String market = '',
  }) {
    _filteredPrices = _marketService.filterPrices(
      prices: _prices,
      query: query,
      state: state,
      district: district,
      market: market,
    );
    _filteredPrices.isEmpty ? setEmpty() : setSuccess();
  }

  MarketPriceModel? byId(String id) {
    for (final price in _prices) {
      if (price.id == id) {
        return price;
      }
    }
    return null;
  }

  String suggestionFor(MarketPriceModel price) {
    return _marketService.bestSellingSuggestion(price);
  }
}
