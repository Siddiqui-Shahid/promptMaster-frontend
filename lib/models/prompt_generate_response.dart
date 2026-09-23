class PromptGenerateResponse {
  PromptGenerateResponse({
    required this.success,
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

  final bool success;
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

  factory PromptGenerateResponse.fromJson(Map<String, dynamic> json) {
    return PromptGenerateResponse(
      success: json['success'] as bool,
      flow: json['flow'] as String? ?? 'legacy',
      businessCategory: json['business_category'] as String,
      detectedProblems: (json['detected_problems'] as List).map((e) => e.toString()).toList(),
      recommendedSoftware: (json['recommended_software'] as List).map((e) => e.toString()).toList(),
      generatedPrompt: json['generated_prompt'] as String,
      stagePrompts: (json['stage_prompts'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      usageHint: json['usage_hint'] as String? ?? '',
      promptVersion: json['prompt_version'] as String,
      title: json['title'] as String,
      businessType: json['business_type'] as String,
    );
  }
}
