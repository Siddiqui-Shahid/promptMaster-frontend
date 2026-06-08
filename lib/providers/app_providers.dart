import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/prompt_service.dart';
import 'auth_provider.dart';
import 'prompt_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final promptServiceProvider = Provider<PromptService>((ref) {
  return PromptService(ref.read(apiClientProvider));
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthStateModel>((ref) {
  return AuthNotifier(
    authService: ref.read(authServiceProvider),
  )..bootstrap();
});

final promptNotifierProvider = StateNotifierProvider<PromptNotifier, PromptState>((ref) {
  return PromptNotifier(ref.read(promptServiceProvider));
});
