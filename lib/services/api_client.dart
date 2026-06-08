import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/api_config.dart';

class ApiClient {
  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await FirebaseAuth.instance.currentUser?.getIdToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
              if (token != null && token.isNotEmpty) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            } catch (_) {
              // Fall through to propagate the original 401.
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;
}
