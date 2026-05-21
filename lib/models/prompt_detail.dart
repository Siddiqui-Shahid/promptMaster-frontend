class PromptDetail {
  PromptDetail({
    required this.id,
    required this.title,
    required this.businessType,
    required this.generatedPrompt,
    required this.createdAt,
    required this.expiresAt,
  });

  final int id;
  final String title;
  final String businessType;
  final String generatedPrompt;
  final DateTime createdAt;
  final DateTime expiresAt;

  factory PromptDetail.fromJson(Map<String, dynamic> json) {
    return PromptDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      businessType: json['business_type'] as String,
      generatedPrompt: json['generated_prompt'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}
