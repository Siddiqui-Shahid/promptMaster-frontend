import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/token_storage.dart';
import '../models/auth_state_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/prompt_service.dart';
import 'auth_provider.dart';
import 'prompt_provider.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(tokenStorageProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});

final promptServiceProvider = Provider<PromptService>((ref) {
  return PromptService(ref.read(apiClientProvider));
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthStateModel>((ref) {
  return AuthNotifier(
    authService: ref.read(authServiceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  )..bootstrap();
});

final promptNotifierProvider = StateNotifierProvider<PromptNotifier, PromptState>((ref) {
  return PromptNotifier(ref.read(promptServiceProvider));
});
