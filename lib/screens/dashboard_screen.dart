import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_log.dart';
import '../models/prompt_generate_request.dart';
import '../providers/app_providers.dart';
import '../providers/prompt_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/form_section.dart';
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
  final _budgetMin = TextEditingController();
  final _budgetMax = TextEditingController();

  final _businessTypeFocus = FocusNode();
  final _businessSizeFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _currentProcessFocus = FocusNode();
  final _biggestProblemFocus = FocusNode();
  final _currentSoftwareFocus = FocusNode();
  final _targetGoalFocus = FocusNode();
  final _budgetMinFocus = FocusNode();
  final _budgetMaxFocus = FocusNode();
  final _additionalNotesFocus = FocusNode();

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
    _budgetMin.dispose();
    _budgetMax.dispose();
    _businessTypeFocus.dispose();
    _businessSizeFocus.dispose();
    _locationFocus.dispose();
    _currentProcessFocus.dispose();
    _biggestProblemFocus.dispose();
    _currentSoftwareFocus.dispose();
    _targetGoalFocus.dispose();
    _budgetMinFocus.dispose();
    _budgetMaxFocus.dispose();
    _additionalNotesFocus.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    appLog('Dashboard: Generate Prompt tapped');
    if (!_formKey.currentState!.validate()) {
      appLog('Dashboard: form validation failed — fix highlighted fields');
      return;
    }
    FocusScope.of(context).unfocus();
    final request = PromptGenerateRequest(
      businessType: _trim(_businessType),
      businessSize: _trim(_businessSize),
      location: _trim(_location),
      currentProcess: _trim(_currentProcess),
      biggestProblem: _trim(_biggestProblem),
      currentSoftware: _trim(_currentSoftware),
      targetGoal: _trim(_targetGoal),
      additionalNotes: _trim(_additionalNotes),
      budgetMin: _parseBudget(_budgetMin),
      budgetMax: _parseBudget(_budgetMax),
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
    _budgetMin.clear();
    _budgetMax.clear();
    ref.read(promptNotifierProvider.notifier).clearGenerated();
  }

  String _trim(TextEditingController c) => c.text.trim();

  int? _parseBudget(TextEditingController c) {
    final raw = c.text.trim().replaceAll(',', '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  @override
  Widget build(BuildContext context) {
    final promptState = ref.watch(promptNotifierProvider);
    final isMobile = MediaQuery.of(context).size.width < 980;
    final padding = isMobile ? 16.0 : 20.0;

    final side = Sidebar(
      onNewPrompt: _resetForNewPrompt,
      onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
    );

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const AppLogo(size: 28, showTitle: true, compact: true),
          centerTitle: false,
        ),
        drawer: Drawer(child: SafeArea(child: side)),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(padding),
            children: [
              if (promptState.error != null) ...[
                ErrorState(message: promptState.error!),
                const SizedBox(height: 12),
              ],
              _buildFormCard(promptState.isLoading, scrollable: false),
              const SizedBox(height: 16),
              _buildOutputPane(promptState, expand: false),
            ],
          ).animate().fadeIn(duration: 220.ms),
        ),
      );
    }

    final content = Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (promptState.error != null) ...[
            ErrorState(message: promptState.error!),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 4, child: _buildFormCard(promptState.isLoading, scrollable: true)),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: _buildOutputPane(promptState, expand: true)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms);

    return Scaffold(
      body: Row(
        children: [
          side,
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool loading, {required bool scrollable}) {
    final fields = _buildFormFields(loading);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: scrollable
              ? ListView(children: fields)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: fields,
                ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(bool loading) {
    return [
              FormSection(
                title: 'Business profile',
                subtitle: 'Who you are advising',
                icon: Icons.storefront_outlined,
                children: [
                  AppTextField(
                    controller: _businessType,
                    focusNode: _businessTypeFocus,
                    label: 'Business Type',
                    hintText: 'e.g. Gym, Clinic, Retail shop',
                    prefixIcon: Icons.category_outlined,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _businessSizeFocus.requestFocus(),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _businessSize,
                    focusNode: _businessSizeFocus,
                    label: 'Business Size',
                    hintText: 'e.g. 50 employees, 3 branches',
                    prefixIcon: Icons.groups_outlined,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _location,
                    focusNode: _locationFocus,
                    label: 'Location',
                    hintText: 'City, state, or region',
                    prefixIcon: Icons.location_on_outlined,
                    keyboardType: TextInputType.streetAddress,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _currentProcessFocus.requestFocus(),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              FormSection(
                title: 'Operations',
                subtitle: 'How they work today',
                icon: Icons.sync_alt_rounded,
                children: [
                  AppTextField(
                    controller: _currentProcess,
                    focusNode: _currentProcessFocus,
                    label: 'Current Process',
                    hintText: 'Describe day-to-day workflow',
                    prefixIcon: Icons.account_tree_outlined,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _biggestProblem,
                    focusNode: _biggestProblemFocus,
                    label: 'Biggest Problem',
                    hintText: 'Main pain point to solve',
                    prefixIcon: Icons.report_problem_outlined,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _currentSoftware,
                    focusNode: _currentSoftwareFocus,
                    label: 'Current Software',
                    hintText: 'Excel, WhatsApp, Tally, POS…',
                    prefixIcon: Icons.computer_outlined,
                    maxLines: 2,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _targetGoalFocus.requestFocus(),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              FormSection(
                title: 'Goals & budget',
                subtitle: 'What success looks like',
                icon: Icons.flag_outlined,
                children: [
                  AppTextField(
                    controller: _targetGoal,
                    focusNode: _targetGoalFocus,
                    label: 'Target Goal',
                    hintText: 'Revenue, efficiency, retention…',
                    prefixIcon: Icons.track_changes_outlined,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 14),
                  _buildBudgetRow(),
                ],
              ),
              const SizedBox(height: 22),
              FormSection(
                title: 'Extra context',
                icon: Icons.notes_outlined,
                children: [
                  AppTextField(
                    controller: _additionalNotes,
                    focusNode: _additionalNotesFocus,
                    label: 'Additional Notes',
                    hintText: 'Paste Google Maps listing, reviews, or any research (up to 100k chars)',
                    prefixIcon: Icons.note_add_outlined,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _generate(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Generate Prompt',
                icon: Icons.auto_awesome,
                onPressed: _generate,
                loading: loading,
              ),
    ];
  }

  Widget _buildBudgetRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Development budget (INR)', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          'Optional — min = lowest spend, max = cap. Blank max defaults to ₹2,00,000 in prompt.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _budgetMin,
                focusNode: _budgetMinFocus,
                label: 'Min (₹)',
                hintText: '50000',
                helperText: 'Minimum',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                validator: _validateBudgetMin,
                onFieldSubmitted: (_) => _budgetMaxFocus.requestFocus(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _budgetMax,
                focusNode: _budgetMaxFocus,
                label: 'Max (₹)',
                hintText: '200000',
                helperText: 'Maximum',
                prefixIcon: Icons.savings_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                validator: _validateBudgetMax,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutputPane(PromptState promptState, {required bool expand}) {
    if (promptState.isLoading) {
      final card = Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Building your prompt…', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );
      return expand ? card : SizedBox(height: 200, child: card);
    }

    if (promptState.generated != null) {
      final generated = promptState.generated!;
      return PromptOutput(
        title: '${generated.title} • ${generated.promptVersion}',
        prompt: generated.generatedPrompt,
        expand: expand,
        onCopy: () => _copy(generated.generatedPrompt),
        onLaunchMessage: (message) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    }

    const card = Card(
      child: EmptyState(
        icon: Icons.auto_awesome_outlined,
        message: 'Fill in any fields you have, then tap Generate Prompt. Empty fields are skipped.',
      ),
    );
    return expand ? card : const SizedBox(height: 160, child: card);
  }

  String? _validateBudgetMin(String? value) {
    final min = _parseBudget(_budgetMin);
    final max = _parseBudget(_budgetMax);
    if (value != null && value.trim().isNotEmpty && min == null) return 'Enter a valid amount';
    if (min != null && max != null && min > max) return 'Min cannot exceed max';
    return null;
  }

  String? _validateBudgetMax(String? value) {
    final min = _parseBudget(_budgetMin);
    final max = _parseBudget(_budgetMax);
    if (value != null && value.trim().isNotEmpty && max == null) return 'Enter a valid amount';
    if (min != null && max != null && min > max) return 'Max must be ≥ min';
    return null;
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prompt copied to clipboard')),
    );
  }
}
