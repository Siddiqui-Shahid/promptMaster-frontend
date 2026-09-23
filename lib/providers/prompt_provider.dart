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
    this.duplicateRequest,
  });

  final bool isLoading;
  final String? error;
  final PromptGenerateResponse? generated;

  /// When the backend rejects an email as a duplicate, this holds the request
  /// so the UI can offer a "Force Push" retry that bypasses the guard.
  final PromptGenerateRequest? duplicateRequest;

  bool get isDuplicate => duplicateRequest != null;

  PromptState copyWith({
    bool? isLoading,
    String? error,
    PromptGenerateResponse? generated,
    PromptGenerateRequest? duplicateRequest,
    bool clearError = false,
    bool clearGenerated = false,
    bool clearDuplicate = false,
  }) {
    return PromptState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      generated: clearGenerated ? null : (generated ?? this.generated),
      duplicateRequest: clearDuplicate ? null : (duplicateRequest ?? this.duplicateRequest),
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
      'location="${request.location}" notesLen=${request.additionalNotes.length} '
      'force=${request.force}',
    );
    state = state.copyWith(isLoading: true, clearError: true, clearDuplicate: true);
    try {
      final response = await _promptService.generatePrompt(request);
      apiLog('generatePrompt OK — title="${response.title}"');
      state = state.copyWith(isLoading: false, generated: response, clearDuplicate: true);
    } on DioException catch (e) {
      final message = _dioErrorMessage(e);
      apiLog('generatePrompt failed — $message');
      if (e.response?.statusCode == 409) {
        state = state.copyWith(
          isLoading: false,
          error: message,
          duplicateRequest: request,
        );
      } else {
        state = state.copyWith(isLoading: false, error: message, clearDuplicate: true);
      }
    } catch (e, st) {
      apiLog('generatePrompt unexpected error — $e\n$st');
      state = state.copyWith(isLoading: false, error: 'Failed to generate prompt', clearDuplicate: true);
    }
  }

  /// Re-run the last duplicate-rejected request with the force flag set, which
  /// tells the backend to bypass the "email already exists" guard.
  Future<void> forcePush() async {
    final pending = state.duplicateRequest;
    if (pending == null) return;
    await generate(pending.copyWith(force: true));
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

  void reset() {
    state = const PromptState();
  }
}
