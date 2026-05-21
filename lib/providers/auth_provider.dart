import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/token_storage.dart';
import '../models/auth_state_model.dart';
import '../services/auth_service.dart';

class AuthNotifier extends StateNotifier<AuthStateModel> {
  AuthNotifier({required AuthService authService, required TokenStorage tokenStorage})
      : _authService = authService,
        _tokenStorage = tokenStorage,
        super(const AuthStateModel(isAuthenticated: false, isLoading: true));

  final AuthService _authService;
  final TokenStorage _tokenStorage;

  Future<void> bootstrap() async {
    final token = await _tokenStorage.readToken();
    state = state.copyWith(isAuthenticated: token != null && token.isNotEmpty, isLoading: false, error: null);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _authService.login(email: email, password: password);
      await _tokenStorage.saveToken(token);
      state = state.copyWith(isAuthenticated: true, isLoading: false, error: null);
      return true;
    } on DioException catch (e) {
      final detail = e.response?.data?.toString() ?? 'Login failed';
      state = state.copyWith(isLoading: false, isAuthenticated: false, error: detail);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, isAuthenticated: false, error: 'Login failed');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.register(email: email, password: password);
      state = state.copyWith(isLoading: false, error: null);
      return true;
    } on DioException catch (e) {
      final detail = e.response?.data?.toString() ?? 'Registration failed';
      state = state.copyWith(isLoading: false, error: detail);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Registration failed');
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    state = const AuthStateModel(isAuthenticated: false, isLoading: false);
  }
}
