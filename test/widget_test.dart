import 'package:business_prompt_platform/screens/dashboard_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts LinkedIn profile and company page URLs', () {
    expect(
      isSupportedLinkedInUrl(
        'https://www.linkedin.com/company/clinicsofamerica/',
      ),
      isTrue,
    );
    expect(
      isSupportedLinkedInUrl(
        'https://uk.linkedin.com/in/jane-doe?originalSubdomain=uk',
      ),
      isTrue,
    );
  });

  test('rejects non-LinkedIn and unsupported LinkedIn URLs', () {
    expect(
      isSupportedLinkedInUrl(
        'https://example.com/linkedin.com/company/clinicsofamerica',
      ),
      isFalse,
    );
    expect(isSupportedLinkedInUrl('https://www.linkedin.com/jobs/'), isFalse);
  });
}
