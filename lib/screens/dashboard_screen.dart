import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/prompt_generate_request.dart';
import '../providers/app_providers.dart';
import '../providers/prompt_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/prompt_output.dart';
import '../widgets/sidebar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessType = TextEditingController();
  final _businessSize = TextEditingController();
  final _location = TextEditingController();
  final _currentProcess = TextEditingController();
  final _biggestProblem = TextEditingController();
  final _currentSoftware = TextEditingController();
  final _targetGoal = TextEditingController();
  final _additionalNotes = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(promptNotifierProvider.notifier).loadHistory());
  }

  @override
  void dispose() {
    _businessType.dispose();
    _businessSize.dispose();
    _location.dispose();
    _currentProcess.dispose();
    _biggestProblem.dispose();
    _currentSoftware.dispose();
    _targetGoal.dispose();
    _additionalNotes.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    final request = PromptGenerateRequest(
      businessType: _businessType.text.trim(),
      businessSize: _businessSize.text.trim(),
      location: _location.text.trim(),
      currentProcess: _currentProcess.text.trim(),
      biggestProblem: _biggestProblem.text.trim(),
      currentSoftware: _currentSoftware.text.trim(),
      targetGoal: _targetGoal.text.trim(),
      additionalNotes: _additionalNotes.text.trim(),
    );
    await ref.read(promptNotifierProvider.notifier).generate(request);
  }

  void _resetForNewPrompt() {
    _formKey.currentState?.reset();
    _businessType.clear();
    _businessSize.clear();
    _location.clear();
    _currentProcess.clear();
    _biggestProblem.clear();
    _currentSoftware.clear();
    _targetGoal.clear();
    _additionalNotes.clear();
    ref.read(promptNotifierProvider.notifier).clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    final promptState = ref.watch(promptNotifierProvider);
    final isMobile = MediaQuery.of(context).size.width < 980;

    final selectedPromptId = promptState.selectedPrompt?.id ?? promptState.generated?.promptId;

    Widget content = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Prompt Generator', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          if (promptState.error != null) ...[
            ErrorState(message: promptState.error!),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: isMobile
                ? ListView(
                    children: [
                      _buildFormCard(promptState.isLoading),
                      const SizedBox(height: 16),
                      SizedBox(height: 420, child: _buildOutputPane(promptState)),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 4, child: _buildFormCard(promptState.isLoading)),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: _buildOutputPane(promptState)),
                    ],
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms);

    final side = Sidebar(
      prompts: promptState.history,
      isLoading: promptState.isHistoryLoading,
      selectedPromptId: selectedPromptId,
      onNewPrompt: _resetForNewPrompt,
      onOpenPrompt: (id) => ref.read(promptNotifierProvider.notifier).openPrompt(id),
      onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
    );

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(title: const Text('PromptOS')),
        drawer: Drawer(child: SafeArea(child: side)),
        body: content,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          side,
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool loading) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(controller: _businessType, label: 'Business Type', validator: _req),
              const SizedBox(height: 10),
              AppTextField(controller: _businessSize, label: 'Business Size', validator: _req),
              const SizedBox(height: 10),
              AppTextField(controller: _location, label: 'Location', validator: _req),
              const SizedBox(height: 10),
              AppTextField(controller: _currentProcess, label: 'Current Process', maxLines: 4, validator: _reqLong),
              const SizedBox(height: 10),
              AppTextField(controller: _biggestProblem, label: 'Biggest Problem', maxLines: 4, validator: _reqLong),
              const SizedBox(height: 10),
              AppTextField(controller: _currentSoftware, label: 'Current Software', maxLines: 2, validator: _req),
              const SizedBox(height: 10),
              AppTextField(controller: _targetGoal, label: 'Target Goal', maxLines: 3, validator: _reqLong),
              const SizedBox(height: 10),
              AppTextField(controller: _additionalNotes, label: 'Additional Notes', maxLines: 3),
              const SizedBox(height: 16),
              AppButton(label: 'Generate Prompt', onPressed: _generate, loading: loading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutputPane(PromptState promptState) {
    if (promptState.selectedPrompt != null) {
      final detail = promptState.selectedPrompt!;
      return PromptOutput(
        title: '${detail.title} • ${DateFormat('dd MMM yyyy').format(detail.createdAt.toLocal())}',
        prompt: detail.generatedPrompt,
        onCopy: () => _copy(detail.generatedPrompt),
      );
    }

    if (promptState.generated != null) {
      final generated = promptState.generated!;
      return PromptOutput(
        title: '${generated.title} • ${generated.promptVersion}',
        prompt: generated.generatedPrompt,
        onCopy: () => _copy(generated.generatedPrompt),
      );
    }

    return const Card(
      child: EmptyState(
        message: 'Generate a prompt or open one from history to view it here.',
      ),
    );
  }

  String? _req(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _reqLong(String? value) {
    if (value == null || value.trim().length < 10) return 'Please enter at least 10 characters';
    return null;
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prompt copied')));
  }
}
