import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._apiClient);
  final ApiClient _apiClient;

  Future<String> login({required String email, required String password}) async {
    final response = await _apiClient.dio.post(
      '/auth/jwt/login',
      data: {'username': email, 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final token = response.data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Invalid login response',
      );
    }
    return token;
  }

  Future<void> register({required String email, required String password}) async {
    await _apiClient.dio.post('/auth/register', data: {'email': email, 'password': password});
  }
}
