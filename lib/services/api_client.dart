import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/api_config.dart';
import '../core/api_log.dart';
import 'dio_web_adapter_stub.dart'
    if (dart.library.html) 'dio_web_adapter.dart';

class ApiClient {
  ApiClient() {
    apiLog('ApiClient init — baseUrl=${ApiConfig.baseUrl}');

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
      ),
    );
    configureWebAdapter(dio);
    if (kIsWeb) {
      apiLog('Dio web adapter: withCredentials=false (Bearer auth)');
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          final token = await user?.getIdToken();
          final hasToken = token != null && token.isNotEmpty;

          if (hasToken) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          apiLog(
            '→ ${options.method} ${options.uri} '
            '(auth=${hasToken ? 'yes uid=${user?.uid}' : 'NO TOKEN — sign in first'})',
          );

          handler.next(options);
        },
        onResponse: (response, handler) {
          apiLog(
            '← ${response.statusCode} ${response.requestOptions.method} '
            '${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          _logDioError(error);

          if (error.response?.statusCode == 401) {
            apiLog('401 received — refreshing Firebase ID token and retrying once…');
            try {
              final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
              if (token != null && token.isNotEmpty) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await dio.fetch(error.requestOptions);
                apiLog('← retry ${response.statusCode} ${error.requestOptions.uri}');
                return handler.resolve(response);
              }
              apiLog('token refresh failed — no signed-in user');
            } catch (retryError) {
              apiLog('token refresh/retry failed: $retryError');
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;

  void _logDioError(DioException error) {
    final req = error.requestOptions;
    final status = error.response?.statusCode;
    final detail = error.response?.data;

    final buffer = StringBuffer()
      ..write('✗ ${req.method} ${req.uri}')
      ..write(' | type=${error.type.name}');

    if (status != null) {
      buffer.write(' | status=$status');
    }
    if (detail != null) {
      buffer.write(' | body=$detail');
    }
    if (error.message != null) {
      buffer.write(' | message=${error.message}');
    }

    apiLog(buffer.toString());

    if (error.type == DioExceptionType.connectionError) {
      apiLog(
        'Connection failed to ${req.baseUrl}. '
        'If the backend shows no POST ${req.path}, check Chrome DevTools → Network '
        '(CSP connect-src or CORS). Full restart Flutter (q, run again) after index.html changes.',
      );
    }
  }
}
