class PromptGenerateRequest {
  PromptGenerateRequest({
    required this.businessType,
    required this.businessSize,
    required this.location,
    required this.currentProcess,
    required this.biggestProblem,
    required this.currentSoftware,
    required this.targetGoal,
    required this.additionalNotes,
  });

  final String businessType;
  final String businessSize;
  final String location;
  final String currentProcess;
  final String biggestProblem;
  final String currentSoftware;
  final String targetGoal;
  final String additionalNotes;

  Map<String, dynamic> toJson() => {
        'business_type': businessType,
        'business_size': businessSize,
        'location': location,
        'current_process': currentProcess,
        'biggest_problem': biggestProblem,
        'current_software': currentSoftware,
        'target_goal': targetGoal,
        'additional_notes': additionalNotes,
      };
}
