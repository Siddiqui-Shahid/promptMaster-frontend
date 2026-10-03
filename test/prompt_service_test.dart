import 'package:business_prompt_platform/models/prompt_generate_request.dart';
import 'package:business_prompt_platform/services/prompt_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates every workflow locally without an API', () async {
    final service = PromptService();
    final expectedStages = {
      OutreachFlow.linkedin: 2,
      OutreachFlow.email: 3,
      OutreachFlow.verification: 1,
      OutreachFlow.coldCall: 3,
      OutreachFlow.coldMessage: 1,
      OutreachFlow.legacy: 5,
      OutreachFlow.brainstorm: 2,
    };

    for (final entry in expectedStages.entries) {
      final result = await service.generatePrompt(
        PromptGenerateRequest(
          flow: entry.key,
          companyName: 'Acme',
          contactName: 'Jane',
          website: 'https://acme.example',
          linkedinUrl: 'https://linkedin.com/in/jane',
          biggestProblem: 'Manual reporting',
          deliveryLevel: DeliveryLevel.sprint,
        ),
      );
      expect(result.stagePrompts, hasLength(entry.value));
      expect(result.generatedPrompt, contains('Acme'));
      expect(result.generatedPrompt, contains('CYFUR DELIVERY STANDARD'));
      expect(result.generatedPrompt, contains('14 calendar days'));
      expect(result.generatedPrompt, isNot(contains('one person')));
      expect(result.generatedPrompt, isNot(contains('part-time')));
      expect(result.promptVersion, 'cyfur-guardrail-v2');
    }
  });

  test('applies every delivery level without exposing staffing assumptions',
      () async {
    final service = PromptService();

    for (final level in DeliveryLevel.values) {
      final result = await service.generatePrompt(
        PromptGenerateRequest(
          flow: OutreachFlow.brainstorm,
          deliveryLevel: level,
          companyName: 'Acme',
          biggestProblem: 'Manual reporting',
        ),
      );

      expect(result.generatedPrompt, contains(level.label));
      expect(result.generatedPrompt, contains(level.promptInstruction));
      expect(
          result.generatedPrompt.toLowerCase(), isNot(contains('one person')));
      expect(
          result.generatedPrompt.toLowerCase(), isNot(contains('part-time')));
    }
  });
}
