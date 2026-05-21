class PromptSummary {
  PromptSummary({required this.id, required this.title, required this.createdAt});

  final int id;
  final String title;
  final DateTime createdAt;

  factory PromptSummary.fromJson(Map<String, dynamic> json) {
    return PromptSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
