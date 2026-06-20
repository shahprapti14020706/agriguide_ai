import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: AppConstants.requestTimeout,
                receiveTimeout: AppConstants.requestTimeout,
              ),
            );

  final Dio dio;
}
