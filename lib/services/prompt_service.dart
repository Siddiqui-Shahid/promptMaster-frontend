import '../models/prompt_generate_request.dart';
import '../models/prompt_generate_response.dart';

class PromptService {
  Future<PromptGenerateResponse> generatePrompt(
      PromptGenerateRequest request) async {
    final subject = _first(
      [
        request.companyName,
        request.businessType,
        request.website,
        request.contactName
      ],
      'the target business',
    );
    final context = _context(request);
    final stages = switch (request.flow) {
      OutreachFlow.linkedin => _linkedin(request, subject, context),
      OutreachFlow.email => _email(request, subject, context),
      OutreachFlow.verification => _verification(request, subject, context),
      OutreachFlow.coldCall => _coldCall(request, subject, context),
      OutreachFlow.coldMessage => _coldMessage(request, subject, context),
      OutreachFlow.legacy => _audit(request, subject, context),
    };

    return PromptGenerateResponse(
      success: true,
      flow: request.flow.apiValue,
      businessCategory: request.flow.apiValue,
      detectedProblems: [
        if (request.biggestProblem.trim().isNotEmpty)
          request.biggestProblem.trim(),
        if (request.currentProcess.trim().isNotEmpty)
          request.currentProcess.trim(),
      ],
      recommendedSoftware: const [],
      generatedPrompt: stages.join('\n\n---\n\n'),
      stagePrompts: stages,
      usageHint:
          'Run each stage in order in the same ChatGPT or Claude conversation.',
      promptVersion: 'firebase-static-v1',
      title: '${_title(request.flow)} — $subject',
      businessType:
          _first([request.businessType, request.companyName], subject),
    );
  }

  List<String> _linkedin(
          PromptGenerateRequest r, String subject, String context) =>
      [
        '''STAGE 1 — LINKEDIN RESEARCH
Act as a careful B2B researcher. Review this public LinkedIn profile: ${r.linkedinUrl}.
$context
Identify the person's responsibilities, likely priorities, credible conversation hooks, and three problems our services could solve. Separate confirmed facts from assumptions. Do not invent personal details. Return concise bullets with source links where possible.''',
        '''STAGE 2 — LINKEDIN OUTREACH
Using only the verified findings from Stage 1, write a connection note and two follow-up messages for ${r.contactName.isEmpty ? subject : r.contactName}.
Be specific, respectful, and helpful. Avoid hype, fake familiarity, and immediate pitching. Each message must have one clear purpose and stay under 90 words. End with a low-pressure question.''',
      ];

  List<String> _email(
          PromptGenerateRequest r, String subject, String context) =>
      [
        '''STAGE 1 — COMPANY AND CONTACT RESEARCH
Research $subject using its website (${r.website.isEmpty ? 'not supplied' : r.website}) and reliable public sources.
$context
Find three evidence-backed operational or growth opportunities relevant to ${r.contactName.isEmpty ? 'the decision maker' : r.contactName}. Label every inference and include source links. Do not fabricate metrics.''',
        '''STAGE 2 — OUTREACH ANGLE
Turn Stage 1 into one useful outreach angle. Explain the observed signal, likely business impact, and a small practical first step. Choose the strongest angle, not a list of generic services. Keep claims conservative and personalized to $subject.''',
        '''STAGE 3 — EMAIL SEQUENCE
Write a three-email sequence for ${r.contactName.isEmpty ? 'the appropriate decision maker' : r.contactName} at $subject using the approved angle.
Email 1: observation and useful idea. Email 2: practical example or mini-audit. Email 3: polite close-the-loop.
Use plain language, subject lines under seven words, bodies under 120 words, and one low-pressure CTA. Do not claim work or results we cannot verify.''',
      ];

  List<String> _verification(
          PromptGenerateRequest r, String subject, String context) =>
      [
        '''EMAIL VERIFICATION RESEARCH
Find the most likely professional email format for ${r.contactName.isEmpty ? 'the target employee' : r.contactName} at $subject (${r.website}).
$context
Use only public, ethical sources. First identify the official domain, then cite evidence for the company's email pattern, and finally provide ranked candidates with confidence levels. Do not send email, bypass access controls, or present an unverified address as confirmed.''',
      ];

  List<String> _coldCall(
          PromptGenerateRequest r, String subject, String context) =>
      [
        '''STAGE 1 — CALL RESEARCH
Research $subject and prepare a factual pre-call brief.
$context
List verified company signals, likely priorities, a relevant trigger, and five discovery questions. Clearly mark assumptions.''',
        '''STAGE 2 — CALL PLAN
Create a 60-second cold-call opening for $subject. Include permission to continue, one evidence-based reason for calling, two discovery questions, and responses to “not interested,” “send information,” and “we already have a provider.” Keep it natural and non-manipulative.''',
        '''STAGE 3 — ROLE PLAY
Role-play a realistic decision maker at $subject. Challenge vague claims and ask for evidence. After the simulation, score the caller on clarity, relevance, listening, objection handling, and next-step quality, then provide three specific improvements.''',
      ];

  List<String> _coldMessage(
          PromptGenerateRequest r, String subject, String context) =>
      [
        '''COLD LINKEDIN MESSAGE
Research ${r.contactName} at $subject using ${r.linkedinUrl} and ${r.website}.
$context
Write one connection note and two short follow-ups. Lead with a verified observation, offer one useful idea, and ask a low-pressure question. Never invent familiarity, achievements, pain points, or client results. Keep each message under 80 words.''',
      ];

  List<String> _audit(
          PromptGenerateRequest r, String subject, String context) =>
      [
        '''STAGE 1 — BUSINESS RESEARCH
Audit ${r.website} and reliable public sources for $subject.
$context
Summarize what the business does, its customers, digital touchpoints, and observable operational signals. Cite sources and separate facts from assumptions.''',
        '''STAGE 2 — CUSTOMER EXPERIENCE
Using Stage 1, map the likely customer journey from discovery to repeat purchase. Identify friction only where evidence supports it, explain impact, and suggest simple validation questions.''',
        '''STAGE 3 — OPERATIONS
Assess likely workflow, reporting, communication, and handoff opportunities for $subject. Prioritize five improvements by impact, effort, and confidence. Avoid recommending software before defining the process problem.''',
        '''STAGE 4 — SOLUTION OPTIONS
For the top three validated opportunities, propose a minimum solution, a scalable option, expected implementation steps, major risks, and measurable success criteria. Respect this budget context: ${_budget(r)}.''',
        '''STAGE 5 — ACTION PLAN
Create a 30/60/90-day digital improvement plan for $subject. Start with low-risk validation, assign clear owners, define weekly measures, and list assumptions that still require confirmation. Finish with the five best questions to ask the business owner.''',
      ];

  String _context(PromptGenerateRequest r) {
    final values = <String>[
      if (r.companyName.trim().isNotEmpty) 'Company: ${r.companyName.trim()}',
      if (r.website.trim().isNotEmpty) 'Website: ${r.website.trim()}',
      if (r.contactRole.trim().isNotEmpty)
        'Contact role: ${r.contactRole.trim()}',
      if (r.businessSize.trim().isNotEmpty)
        'Business size: ${r.businessSize.trim()}',
      if (r.location.trim().isNotEmpty) 'Location: ${r.location.trim()}',
      if (r.currentProcess.trim().isNotEmpty)
        'Current process: ${r.currentProcess.trim()}',
      if (r.biggestProblem.trim().isNotEmpty)
        'Known problem: ${r.biggestProblem.trim()}',
      if (r.currentSoftware.trim().isNotEmpty)
        'Current software: ${r.currentSoftware.trim()}',
      if (r.targetGoal.trim().isNotEmpty) 'Target goal: ${r.targetGoal.trim()}',
      if (r.additionalNotes.trim().isNotEmpty)
        'Additional notes: ${r.additionalNotes.trim()}',
    ];
    return values.isEmpty
        ? 'No additional context was supplied.'
        : values.join('\n');
  }

  String _budget(PromptGenerateRequest r) {
    if (r.budgetMin == null && r.budgetMax == null) return 'not supplied';
    return 'INR ${r.budgetMin ?? 0}–${r.budgetMax ?? 'open'}';
  }

  String _first(List<String> values, String fallback) => values
      .map((value) => value.trim())
      .firstWhere((value) => value.isNotEmpty, orElse: () => fallback);

  String _title(OutreachFlow flow) => switch (flow) {
        OutreachFlow.linkedin => 'LinkedIn Outreach',
        OutreachFlow.email => 'Email Outreach',
        OutreachFlow.verification => 'Email Verification',
        OutreachFlow.coldCall => 'Cold Call',
        OutreachFlow.coldMessage => 'Cold Message',
        OutreachFlow.legacy => 'Digital Audit',
      };
}
