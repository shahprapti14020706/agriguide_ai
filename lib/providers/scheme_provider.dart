import '../core/config/firebase_runtime.dart';
import '../models/crop_model.dart';
import '../models/government_scheme_model.dart';
import '../models/user_profile_model.dart';
import '../repositories/scheme_repository.dart';
import '../services/scheme_service.dart';
import 'base_provider.dart';

class SchemeProvider extends BaseProvider {
  SchemeProvider({
    required SchemeRepository schemeRepository,
    required SchemeService schemeService,
  })  : _schemeRepository = schemeRepository,
        _schemeService = schemeService;

  final SchemeRepository _schemeRepository;
  final SchemeService _schemeService;

  List<GovernmentSchemeModel> _schemes = const [];
  List<GovernmentSchemeModel> _recommendedSchemes = const [];

  List<GovernmentSchemeModel> get schemes => _schemes;
  List<GovernmentSchemeModel> get recommendedSchemes => _recommendedSchemes;
  GovernmentSchemeModel? get dashboardRecommendation =>
      _recommendedSchemes.isEmpty ? null : _recommendedSchemes.first;

  Future<void> loadSchemes({
    UserProfileModel? profile,
    List<CropModel> crops = const [],
  }) async {
    setLoading();
    try {
      if (FirebaseRuntime.isAvailable) {
        try {
          _schemes = await _schemeRepository.getActiveSchemes();
        } catch (_) {
          _schemes = _schemeService.fallbackSchemes();
        }
      }
      if (_schemes.isEmpty) {
        _schemes = _schemeService.fallbackSchemes();
      }
      _recommendedSchemes = _schemeService.recommendSchemes(
        schemes: _schemes,
        profile: profile,
        crops: crops,
      );
      _schemes.isEmpty ? setEmpty() : setSuccess();
    } catch (error) {
      setFailure(error);
    }
  }

  GovernmentSchemeModel? byId(String id) {
    for (final scheme in _schemes) {
      if (scheme.id == id) {
        return scheme;
      }
    }
    return null;
  }
}
