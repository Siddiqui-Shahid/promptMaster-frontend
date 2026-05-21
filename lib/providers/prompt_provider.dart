import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prompt_detail.dart';
import '../models/prompt_generate_request.dart';
import '../models/prompt_generate_response.dart';
import '../models/prompt_summary.dart';
import '../services/prompt_service.dart';

class PromptState {
  const PromptState({
    this.isLoading = false,
    this.isHistoryLoading = false,
    this.error,
    this.generated,
    this.selectedPrompt,
    this.history = const [],
  });

  final bool isLoading;
  final bool isHistoryLoading;
  final String? error;
  final PromptGenerateResponse? generated;
  final PromptDetail? selectedPrompt;
  final List<PromptSummary> history;

  PromptState copyWith({
    bool? isLoading,
    bool? isHistoryLoading,
    String? error,
    PromptGenerateResponse? generated,
    PromptDetail? selectedPrompt,
    List<PromptSummary>? history,
    bool clearError = false,
  }) {
    return PromptState(
      isLoading: isLoading ?? this.isLoading,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      error: clearError ? null : (error ?? this.error),
      generated: generated ?? this.generated,
      selectedPrompt: selectedPrompt ?? this.selectedPrompt,
      history: history ?? this.history,
    );
  }
}

class PromptNotifier extends StateNotifier<PromptState> {
  PromptNotifier(this._promptService) : super(const PromptState());

  final PromptService _promptService;

  Future<void> loadHistory() async {
    state = state.copyWith(isHistoryLoading: true, clearError: true);
    try {
      final list = await _promptService.fetchPromptHistory();
      state = state.copyWith(isHistoryLoading: false, history: list);
    } on DioException catch (e) {
      state = state.copyWith(isHistoryLoading: false, error: e.response?.data?.toString() ?? 'Failed to load history');
    } catch (_) {
      state = state.copyWith(isHistoryLoading: false, error: 'Failed to load history');
    }
  }

  Future<void> generate(PromptGenerateRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _promptService.generatePrompt(request);
      state = state.copyWith(isLoading: false, generated: response, selectedPrompt: null);
      await loadHistory();
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.response?.data?.toString() ?? 'Failed to generate prompt');
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to generate prompt');
    }
  }

  Future<void> openPrompt(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await _promptService.fetchPromptById(id);
      state = state.copyWith(isLoading: false, selectedPrompt: detail);
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.response?.data?.toString() ?? 'Failed to open prompt');
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to open prompt');
    }
  }

  void clearSelection() {
    state = state.copyWith(selectedPrompt: null);
  }
}
