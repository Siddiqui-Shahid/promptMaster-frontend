class PromptGenerateResponse {
  PromptGenerateResponse({
    required this.success,
    required this.businessCategory,
    required this.detectedProblems,
    required this.recommendedSoftware,
    required this.generatedPrompt,
    required this.promptVersion,
    required this.title,
    required this.businessType,
  });

  final bool success;
  final String businessCategory;
  final List<String> detectedProblems;
  final List<String> recommendedSoftware;
  final String generatedPrompt;
  final String promptVersion;
  final String title;
  final String businessType;

  factory PromptGenerateResponse.fromJson(Map<String, dynamic> json) {
    return PromptGenerateResponse(
      success: json['success'] as bool,
      businessCategory: json['business_category'] as String,
      detectedProblems: (json['detected_problems'] as List).map((e) => e.toString()).toList(),
      recommendedSoftware: (json['recommended_software'] as List).map((e) => e.toString()).toList(),
      generatedPrompt: json['generated_prompt'] as String,
      promptVersion: json['prompt_version'] as String,
      title: json['title'] as String,
      businessType: json['business_type'] as String,
    );
  }
}
