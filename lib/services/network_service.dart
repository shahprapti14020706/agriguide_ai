import 'package:dio/dio.dart';

import '../core/errors/app_exception.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';

class NetworkService {
  NetworkService({
    required ApiClient apiClient,
    required NetworkInfo networkInfo,
  })  : _apiClient = apiClient,
        _networkInfo = networkInfo;

  final ApiClient _apiClient;
  final NetworkInfo _networkInfo;

  Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureConnected();
    return _apiClient.dio.get(
      url,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<dynamic>> post(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureConnected();
    return _apiClient.dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<void> _ensureConnected() async {
    if (!await _networkInfo.isConnected) {
      throw const NetworkException('No internet connection available.');
    }
  }
}
