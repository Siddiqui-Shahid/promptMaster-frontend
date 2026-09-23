enum OutreachFlow {
  linkedin,
  email,
  verification,
  legacy,
  coldCall,
  coldMessage;

  String get apiValue => switch (this) {
        OutreachFlow.coldCall => 'cold_call',
        OutreachFlow.coldMessage => 'cold_message',
        _ => name,
      };
}

class PromptGenerateRequest {
  PromptGenerateRequest({
    this.flow = OutreachFlow.legacy,
    this.linkedinUrl = '',
    this.companyName = '',
    this.website = '',
    this.contactName = '',
    this.contactEmail = '',
    this.contactRole = '',
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
    this.force = false,
  });

  final OutreachFlow flow;
  final String linkedinUrl;
  final String companyName;
  final String website;
  final String contactName;
  final String contactEmail;
  final String contactRole;
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
  final bool force;

  PromptGenerateRequest copyWith({bool? force}) {
    return PromptGenerateRequest(
      flow: flow,
      linkedinUrl: linkedinUrl,
      companyName: companyName,
      website: website,
      contactName: contactName,
      contactEmail: contactEmail,
      contactRole: contactRole,
      businessType: businessType,
      businessSize: businessSize,
      location: location,
      currentProcess: currentProcess,
      biggestProblem: biggestProblem,
      currentSoftware: currentSoftware,
      targetGoal: targetGoal,
      additionalNotes: additionalNotes,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      force: force ?? this.force,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'flow': flow.apiValue,
      'force': force,
      'linkedin_url': linkedinUrl,
      'company_name': companyName,
      'website': website,
      'contact_name': contactName,
      'contact_email': contactEmail,
      'contact_role': contactRole,
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
