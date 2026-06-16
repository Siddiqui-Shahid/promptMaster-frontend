import 'package:dio/dio.dart';
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
      'generatePrompt called — businessType="${request.businessType}" '
      'location="${request.location}" notesLen=${request.additionalNotes.length}',
    );
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _promptService.generatePrompt(request);
      apiLog('generatePrompt OK — title="${response.title}"');
      state = state.copyWith(isLoading: false, generated: response);
    } on DioException catch (e) {
      final message = _dioErrorMessage(e);
      apiLog('generatePrompt failed — $message');
      state = state.copyWith(isLoading: false, error: message);
    } catch (e, st) {
      apiLog('generatePrompt unexpected error — $e\n$st');
      state = state.copyWith(isLoading: false, error: 'Failed to generate prompt');
    }
  }

  String _dioErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List) {
        final lines = <String>[];
        for (final item in detail) {
          if (item is Map) {
            final loc = item['loc'];
            final field = loc is List && loc.isNotEmpty ? loc.last.toString() : 'field';
            final msg = item['msg']?.toString() ?? 'Invalid value';
            lines.add('$field: $msg');
          }
        }
        if (lines.isNotEmpty) return lines.join('\n');
      }
      return 'Request validation failed. Check your input and try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      final base = e.requestOptions.baseUrl;
      return 'Cannot reach the API at $base. '
          'Start the backend first (see RUN.md), then hot restart Flutter (R).';
    }
    return e.message ?? 'Failed to generate prompt';
  }

  void clearGenerated() {
    state = state.copyWith(clearGenerated: true);
  }
}
