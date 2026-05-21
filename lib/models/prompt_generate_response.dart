class PromptGenerateResponse {
  PromptGenerateResponse({
    required this.success,
    required this.businessCategory,
    required this.detectedProblems,
    required this.recommendedSoftware,
    required this.generatedPrompt,
    required this.promptVersion,
    required this.promptId,
    required this.title,
    required this.createdAt,
    required this.expiresAt,
  });

  final bool success;
  final String businessCategory;
  final List<String> detectedProblems;
  final List<String> recommendedSoftware;
  final String generatedPrompt;
  final String promptVersion;
  final int promptId;
  final String title;
  final DateTime createdAt;
  final DateTime expiresAt;

  factory PromptGenerateResponse.fromJson(Map<String, dynamic> json) {
    return PromptGenerateResponse(
      success: json['success'] as bool,
      businessCategory: json['business_category'] as String,
      detectedProblems: (json['detected_problems'] as List).map((e) => e.toString()).toList(),
      recommendedSoftware: (json['recommended_software'] as List).map((e) => e.toString()).toList(),
      generatedPrompt: json['generated_prompt'] as String,
      promptVersion: json['prompt_version'] as String,
      promptId: json['prompt_id'] as int,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}
