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
        ),
      );
      expect(result.success, isTrue);
      expect(result.stagePrompts, hasLength(entry.value));
      expect(result.generatedPrompt, contains('Acme'));
      expect(result.promptVersion, 'firebase-static-v1');
    }
  });
}
