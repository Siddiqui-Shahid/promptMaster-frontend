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
  OutreachFlow _flow = OutreachFlow.linkedin;
  final List<String> _recentTitles = [];

  final _linkedinUrl = TextEditingController();
  final _companyName = TextEditingController();
  final _website = TextEditingController();
  final _contactName = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactRole = TextEditingController();
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

  final _linkedinUrlFocus = FocusNode();
  final _companyNameFocus = FocusNode();
  final _websiteFocus = FocusNode();
  final _contactNameFocus = FocusNode();
  final _contactEmailFocus = FocusNode();
  final _contactRoleFocus = FocusNode();
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
    _linkedinUrl.dispose();
    _companyName.dispose();
    _website.dispose();
    _contactName.dispose();
    _contactEmail.dispose();
    _contactRole.dispose();
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
    _linkedinUrlFocus.dispose();
    _companyNameFocus.dispose();
    _websiteFocus.dispose();
    _contactNameFocus.dispose();
    _contactEmailFocus.dispose();
    _contactRoleFocus.dispose();
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
    appLog('Dashboard: Generate Prompt tapped flow=${_flow.apiValue}');
    if (!_formKey.currentState!.validate()) {
      appLog('Dashboard: form validation failed — fix highlighted fields');
      return;
    }
    FocusScope.of(context).unfocus();
    final request = PromptGenerateRequest(
      flow: _flow,
      linkedinUrl: _trim(_linkedinUrl),
      companyName: _trim(_companyName),
      website: _trim(_website),
      contactName: _trim(_contactName),
      contactEmail: _trim(_contactEmail),
      contactRole: _trim(_contactRole),
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
    final generated = ref.read(promptNotifierProvider).generated;
    if (generated != null) {
      setState(() => _recentTitles.insert(0, generated.title));
    }
  }

  void _resetForNewPrompt() {
    _formKey.currentState?.reset();
    _linkedinUrl.clear();
    _companyName.clear();
    _website.clear();
    _contactName.clear();
    _contactEmail.clear();
    _contactRole.clear();
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
    setState(() => _flow = OutreachFlow.linkedin);
    ref.read(promptNotifierProvider.notifier).reset();
  }

  void _resetActiveForm() {
    _formKey.currentState?.reset();
    switch (_flow) {
      case OutreachFlow.linkedin:
        _linkedinUrl.clear();
        _additionalNotes.clear();
        break;
      case OutreachFlow.email:
        _companyName.clear();
        _website.clear();
        _contactName.clear();
        _contactEmail.clear();
        _contactRole.clear();
        _location.clear();
        _additionalNotes.clear();
        break;
      case OutreachFlow.verification:
        _companyName.clear();
        _website.clear();
        _contactName.clear();
        _contactRole.clear();
        _additionalNotes.clear();
        break;
      case OutreachFlow.coldCall:
      case OutreachFlow.coldMessage:
        _contactName.clear();
        _companyName.clear();
        _linkedinUrl.clear();
        _website.clear();
        _contactRole.clear();
        _additionalNotes.clear();
        break;
      case OutreachFlow.legacy:
        _website.clear();
        _companyName.clear();
        _location.clear();
        _businessType.clear();
        _businessSize.clear();
        _additionalNotes.clear();
        _budgetMin.clear();
        _budgetMax.clear();
        break;
    }
  }

  String _trim(TextEditingController c) => c.text.trim();

  int? _parseBudget(TextEditingController c) {
    final raw = c.text.trim().replaceAll(',', '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  String get _generateButtonLabel {
    switch (_flow) {
      case OutreachFlow.linkedin:
        return 'Generate LinkedIn Prompt';
      case OutreachFlow.email:
        return 'Generate Email Prompts';
      case OutreachFlow.verification:
        return 'Generate Verification Candidates';
      case OutreachFlow.coldCall:
        return 'Generate Cold Call Prompts';
      case OutreachFlow.coldMessage:
        return 'Generate Cold Message Prompt';
      case OutreachFlow.legacy:
        return 'Generate Digital Audit';
    }
  }

  @override
  Widget build(BuildContext context) {
    final promptState = ref.watch(promptNotifierProvider);
    final isMobile = MediaQuery.of(context).size.width < 980;
    final padding = isMobile ? 16.0 : 20.0;

    final side = Sidebar(
      onNewPrompt: _resetForNewPrompt,
      onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
      selectedFlow: _flow,
      onSelectFlow: (flow) {
        if (flow != _flow) {
          ref.read(promptNotifierProvider.notifier).clearGenerated();
        }
        setState(() => _flow = flow);
      },
      historyTitles: _recentTitles,
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
              ..._buildErrorBanner(promptState),
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
          ..._buildErrorBanner(promptState),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    flex: 4,
                    child: _buildFormCard(promptState.isLoading,
                        scrollable: true)),
                const SizedBox(width: 16),
                Expanded(
                    flex: 5,
                    child: _buildOutputPane(promptState, expand: true)),
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

  List<Widget> _buildErrorBanner(PromptState promptState) {
    if (promptState.error == null) return const [];
    return [
      ErrorState(message: promptState.error!),
      if (promptState.isDuplicate) ...[
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            onPressed: promptState.isLoading ? null : _forcePush,
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('Force Push (bypass duplicate)'),
          ),
        ),
      ],
      const SizedBox(height: 12),
    ];
  }

  Future<void> _forcePush() async {
    appLog('Dashboard: Force Push tapped');
    FocusScope.of(context).unfocus();
    await ref.read(promptNotifierProvider.notifier).forcePush();
    final generated = ref.read(promptNotifierProvider).generated;
    if (generated != null) {
      setState(() => _recentTitles.insert(0, generated.title));
    }
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
      ..._buildFlowSpecificFields(),
      const SizedBox(height: 20),
      OutlinedButton.icon(
        onPressed: _resetActiveForm,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Reset Form'),
      ),
      const SizedBox(height: 12),
      AppButton(
        label: _generateButtonLabel,
        icon: Icons.auto_awesome,
        onPressed: _generate,
        loading: loading,
      ),
    ];
  }

  List<Widget> _buildFlowSpecificFields() {
    switch (_flow) {
      case OutreachFlow.linkedin:
        return _buildLinkedInFields();
      case OutreachFlow.email:
        return _buildEmailFields();
      case OutreachFlow.verification:
        return _buildVerificationFields();
      case OutreachFlow.coldCall:
      case OutreachFlow.coldMessage:
        return _buildColdOutreachFields();
      case OutreachFlow.legacy:
        return _buildLegacyFields();
    }
  }

  List<Widget> _buildLinkedInFields() {
    return [
      FormSection(
        title: 'LinkedIn prospect',
        subtitle: 'Paste an executive profile URL',
        icon: Icons.person_search_outlined,
        children: [
          AppTextField(
            controller: _linkedinUrl,
            focusNode: _linkedinUrlFocus,
            label: 'LinkedIn Profile URL',
            hintText: 'https://www.linkedin.com/in/username',
            prefixIcon: Icons.link,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            validator: _validateLinkedInUrl,
            onFieldSubmitted: (_) => _additionalNotesFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _additionalNotes,
            focusNode: _additionalNotesFocus,
            label: 'Additional Notes (optional)',
            hintText: 'Industry preference, suspected pain point, etc.',
            prefixIcon: Icons.note_add_outlined,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _generate(),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildEmailFields() {
    return [
      FormSection(
        title: 'Prospect details',
        subtitle: 'Company and contact for email outreach',
        icon: Icons.business_outlined,
        children: [
          AppTextField(
            controller: _companyName,
            focusNode: _companyNameFocus,
            label: 'Company Name',
            hintText: 'Acme Corp',
            prefixIcon: Icons.apartment_outlined,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _websiteFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _website,
            focusNode: _websiteFocus,
            label: 'Website',
            hintText: 'https://example.com',
            prefixIcon: Icons.language_outlined,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            validator: _validateEmailProspect,
            onFieldSubmitted: (_) => _contactNameFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _contactName,
            focusNode: _contactNameFocus,
            label: 'Contact Name',
            hintText: 'Jane Smith',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _contactRoleFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _contactRole,
            focusNode: _contactRoleFocus,
            label: 'Contact Role',
            hintText: 'COO, Founder, VP Operations',
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _contactEmailFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _contactEmail,
            focusNode: _contactEmailFocus,
            label: 'Contact Email',
            hintText: 'jane@company.com',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _locationFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _location,
            focusNode: _locationFocus,
            label: 'Location (optional)',
            hintText: 'City, country',
            prefixIcon: Icons.location_on_outlined,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _additionalNotesFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _additionalNotes,
            focusNode: _additionalNotesFocus,
            label: 'Additional Notes (optional)',
            hintText: 'Research, pain points, context from CRM',
            prefixIcon: Icons.note_add_outlined,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _generate(),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildColdOutreachFields() {
    final isColdCall = _flow == OutreachFlow.coldCall;
    final nameRequired = _flow == OutreachFlow.coldMessage;
    return [
      FormSection(
        title: 'Cold outreach prospect',
        subtitle: isColdCall
            ? 'Company name required — all other fields optional'
            : nameRequired
                ? 'Contact and company details for personalized script'
                : 'Company and LinkedIn details — name optional if unknown',
        icon: Icons.person_search_outlined,
        children: [
          AppTextField(
            controller: _contactName,
            focusNode: _contactNameFocus,
            label: nameRequired ? 'Contact Name' : 'Contact Name (optional)',
            hintText: nameRequired
                ? 'Jane Smith'
                : 'Leave blank if unknown — script will adapt',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: nameRequired ? _validateColdOutreachContactName : null,
            onFieldSubmitted: (_) => _companyNameFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _companyName,
            focusNode: _companyNameFocus,
            label: 'Company Name',
            hintText: 'Acme Corp',
            prefixIcon: Icons.apartment_outlined,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: _validateColdOutreachCompanyName,
            onFieldSubmitted: (_) => _linkedinUrlFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _linkedinUrl,
            focusNode: _linkedinUrlFocus,
            label: isColdCall
                ? 'LinkedIn Profile URL (optional)'
                : 'LinkedIn Profile URL',
            hintText: isColdCall
                ? 'Leave blank to discover via research'
                : 'https://www.linkedin.com/in/username',
            prefixIcon: Icons.link,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            validator: isColdCall
                ? _validateOptionalLinkedInUrl
                : _validateLinkedInUrl,
            onFieldSubmitted: (_) => _websiteFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _website,
            focusNode: _websiteFocus,
            label:
                isColdCall ? 'Company Website (optional)' : 'Company Website',
            hintText: isColdCall
                ? 'Leave blank to discover via research'
                : 'https://example.com',
            prefixIcon: Icons.language_outlined,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            validator: isColdCall ? null : _validateColdOutreachWebsite,
            onFieldSubmitted: (_) => _contactRoleFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _contactRole,
            focusNode: _contactRoleFocus,
            label: 'Contact Role (optional)',
            hintText: 'COO, Founder, VP Engineering',
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _additionalNotesFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _additionalNotes,
            focusNode: _additionalNotesFocus,
            label: 'Additional Notes (optional)',
            hintText:
                'Industry context, suspected pain points, prior touchpoints',
            prefixIcon: Icons.note_add_outlined,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _generate(),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildLegacyFields() {
    return [
      FormSection(
        title: 'Business URL',
        subtitle: 'Website, Google Maps, or directory listing',
        icon: Icons.fact_check_outlined,
        children: [
          AppTextField(
            controller: _website,
            focusNode: _websiteFocus,
            label: 'Business URL',
            hintText: 'https://example.com or Maps / directory link',
            prefixIcon: Icons.link,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            validator: _validateAuditWebsite,
            onFieldSubmitted: (_) => _companyNameFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _companyName,
            focusNode: _companyNameFocus,
            label: 'Company Name (optional)',
            hintText: 'If known — otherwise the audit will extract it',
            prefixIcon: Icons.business_outlined,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _locationFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _location,
            focusNode: _locationFocus,
            label: 'Location (optional)',
            hintText: 'City, state, or region',
            prefixIcon: Icons.location_on_outlined,
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _businessTypeFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _businessType,
            focusNode: _businessTypeFocus,
            label: 'Industry hint (optional)',
            hintText: 'e.g. Roofing, Clinic, Gym',
            prefixIcon: Icons.category_outlined,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _additionalNotesFocus.requestFocus(),
          ),
        ],
      ),
      const SizedBox(height: 22),
      FormSection(
        title: 'Budget (optional)',
        subtitle: 'Caps development recommendations in INR',
        icon: Icons.payments_outlined,
        children: [
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
            label: 'Additional Notes (optional)',
            hintText: 'Owner name, known issues, scraped notes…',
            prefixIcon: Icons.note_add_outlined,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _generate(),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildVerificationFields() {
    return [
      FormSection(
        title: 'Email verification',
        subtitle: 'Generate likely work emails with confidence',
        icon: Icons.verified_outlined,
        children: [
          AppTextField(
            controller: _companyName,
            focusNode: _companyNameFocus,
            label: 'Company Name',
            hintText: 'Acme Corp',
            prefixIcon: Icons.business_outlined,
            textInputAction: TextInputAction.next,
            validator: _validateEmailProspect,
            onFieldSubmitted: (_) => _websiteFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _website,
            focusNode: _websiteFocus,
            label: 'Website',
            hintText: 'https://acme.com',
            prefixIcon: Icons.language_outlined,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _contactNameFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _contactName,
            focusNode: _contactNameFocus,
            label: 'Employee Name (optional)',
            hintText: 'Jane Smith',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _contactRoleFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _contactRole,
            focusNode: _contactRoleFocus,
            label: 'Role (optional)',
            hintText: 'VP Operations',
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _generate(),
          ),
        ],
      ),
    ];
  }

  Widget _buildBudgetRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Development budget (INR)',
            style: Theme.of(context).textTheme.bodyMedium),
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
              Text('Building your prompt…',
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );
      return expand ? card : SizedBox(height: 200, child: card);
    }

    final showStagedOutput =
        promptState.generated != null || _flow == OutreachFlow.email;

    if (showStagedOutput) {
      final generated = promptState.generated;
      final title = generated != null
          ? '${generated.title} • ${generated.promptVersion}'
          : 'Email Outreach • Send';
      return PromptOutput(
        key:
            ValueKey('output-${_flow.apiValue}-${generated?.title ?? 'empty'}'),
        title: title,
        prompt: generated?.generatedPrompt ?? '',
        stagePrompts: generated?.stagePrompts ?? const [],
        usageHint: generated?.usageHint ?? '',
        flow: generated?.flow ?? _flow.apiValue,
        expand: expand,
        onCopy: () => _copy(),
        onLaunchMessage: (message) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        },
      );
    }

    final emptyMessage = switch (_flow) {
      OutreachFlow.linkedin =>
        'Paste a LinkedIn profile URL, then tap Generate LinkedIn Prompt. Run Stage 1 → Stage 2 in the same AI chat.',
      OutreachFlow.email =>
        'Fill prospect details, then tap Generate Email Prompts.',
      OutreachFlow.verification =>
        'Enter company or website, then tap Generate Verification Candidates.',
      OutreachFlow.coldCall =>
        'Enter a company name — other fields are optional. Then tap Generate Cold Call Prompts.',
      OutreachFlow.coldMessage =>
        'Fill contact, company, LinkedIn, and website, then tap Generate Cold Message Prompt.',
      OutreachFlow.legacy =>
        'Paste a business URL, then tap Generate Digital Audit. Run Stages 1–5 in the same AI chat (web search on).',
    };

    final card = Card(
      child: EmptyState(
        icon: Icons.auto_awesome_outlined,
        message: emptyMessage,
      ),
    );
    return expand ? card : SizedBox(height: 160, child: card);
  }

  String? _validateLinkedInUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return 'LinkedIn profile URL is required';
    if (!url.toLowerCase().contains('linkedin.com/in/')) {
      return 'Enter a valid LinkedIn profile URL (linkedin.com/in/...)';
    }
    return null;
  }

  String? _validateOptionalLinkedInUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return null;
    if (!url.toLowerCase().contains('linkedin.com/in/')) {
      return 'Enter a valid LinkedIn profile URL (linkedin.com/in/...)';
    }
    return null;
  }

  String? _validateColdOutreachContactName(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Contact name is required';
    return null;
  }

  String? _validateColdOutreachCompanyName(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Company name is required';
    return null;
  }

  String? _validateColdOutreachWebsite(String? value) {
    if ((value?.trim() ?? '').isEmpty) return 'Company website is required';
    return null;
  }

  String? _validateEmailProspect(String? value) {
    final company = _trim(_companyName);
    final website = value?.trim() ?? '';
    final contact = _trim(_contactName);
    if (company.isEmpty && website.isEmpty && contact.isEmpty) {
      return 'Enter company name, website, or contact name';
    }
    return null;
  }

  String? _validateAuditWebsite(String? value) {
    final website = value?.trim() ?? '';
    if (website.isEmpty) return 'Business URL is required';
    return null;
  }

  String? _validateBudgetMin(String? value) {
    final min = _parseBudget(_budgetMin);
    final max = _parseBudget(_budgetMax);
    if (value != null && value.trim().isNotEmpty && min == null) {
      return 'Enter a valid amount';
    }
    if (min != null && max != null && min > max) return 'Min cannot exceed max';
    return null;
  }

  String? _validateBudgetMax(String? value) {
    final min = _parseBudget(_budgetMin);
    final max = _parseBudget(_budgetMax);
    if (value != null && value.trim().isNotEmpty && max == null) {
      return 'Enter a valid amount';
    }
    if (min != null && max != null && min > max) return 'Max must be ≥ min';
    return null;
  }

  void _copy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prompt copied to clipboard')),
    );
  }
}
