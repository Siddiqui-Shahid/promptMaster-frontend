class PromptGenerateRequest {
  PromptGenerateRequest({
    this.businessType = '',
    this.businessSize = '',
    this.location = '',
    this.currentProcess = '',
    this.biggestProblem = '',
    this.currentSoftware = '',
    this.targetGoal = '',
    this.additionalNotes = '',
    this.budgetMin,
    this.budgetMax,
  });

  final String businessType;
  final String businessSize;
  final String location;
  final String currentProcess;
  final String biggestProblem;
  final String currentSoftware;
  final String targetGoal;
  final String additionalNotes;
  final int? budgetMin;
  final int? budgetMax;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'business_type': businessType,
      'business_size': businessSize,
      'location': location,
      'current_process': currentProcess,
      'biggest_problem': biggestProblem,
      'current_software': currentSoftware,
      'target_goal': targetGoal,
      'additional_notes': additionalNotes,
    };
    if (budgetMin != null) {
      json['budget_min'] = budgetMin;
    }
    if (budgetMax != null) {
      json['budget_max'] = budgetMax;
    }
    return json;
  }
}
