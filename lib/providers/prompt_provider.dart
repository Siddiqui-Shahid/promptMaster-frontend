import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_log.dart';
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
    apiLog(
      'generatePrompt called — flow=${request.flow.apiValue} '
      'businessType="${request.businessType}" '
      'location="${request.location}" notesLen=${request.additionalNotes.length}',
    );
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _promptService.generatePrompt(request);
      apiLog('generatePrompt OK — title="${response.title}"');
      state = state.copyWith(isLoading: false, generated: response);
    } catch (e, st) {
      apiLog('generatePrompt unexpected error — $e\n$st');
      state =
          state.copyWith(isLoading: false, error: 'Failed to generate prompt');
    }
  }

  void clearGenerated() {
    state = state.copyWith(clearGenerated: true);
  }

  void reset() {
    state = const PromptState();
  }
}
