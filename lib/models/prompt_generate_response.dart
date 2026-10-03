class PromptGenerateResponse {
  PromptGenerateResponse({
    required this.flow,
    required this.businessCategory,
    required this.detectedProblems,
    required this.recommendedSoftware,
    required this.generatedPrompt,
    required this.stagePrompts,
    required this.usageHint,
    required this.promptVersion,
    required this.title,
    required this.businessType,
  });

  final String flow;
  final String businessCategory;
  final List<String> detectedProblems;
  final List<String> recommendedSoftware;
  final String generatedPrompt;
  final List<String> stagePrompts;
  final String usageHint;
  final String promptVersion;
  final String title;
  final String businessType;

  bool get hasEmailStages => flow == 'email' && stagePrompts.length >= 3;

  bool get hasColdCallStages => flow == 'cold_call' && stagePrompts.length >= 3;

  bool get hasLinkedInStages => flow == 'linkedin' && stagePrompts.length >= 2;

  bool get hasMultiStagePrompts =>
      hasLinkedInStages || hasEmailStages || hasColdCallStages;
}
