import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prompt_generate_request.dart';
import '../models/prompt_generate_response.dart';
import '../services/prompt_service.dart';

class PromptState {
  const PromptState({
    this.isLoading = false,
    this.error,
    this.generated,
  });

  final bool isLoading;
  final String? error;
  final PromptGenerateResponse? generated;

  PromptState copyWith({
    bool? isLoading,
    String? error,
    PromptGenerateResponse? generated,
    bool clearError = false,
    bool clearGenerated = false,
  }) {
    return PromptState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      generated: clearGenerated ? null : (generated ?? this.generated),
    );
  }
}

class PromptNotifier extends StateNotifier<PromptState> {
  PromptNotifier(this._promptService) : super(const PromptState());

  final PromptService _promptService;

  Future<void> generate(PromptGenerateRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _promptService.generatePrompt(request);
      state = state.copyWith(isLoading: false, generated: response);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.response?.data?.toString() ?? 'Failed to generate prompt');
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to generate prompt');
    }
  }

  void clearGenerated() {
    state = state.copyWith(clearGenerated: true);
  }
}
