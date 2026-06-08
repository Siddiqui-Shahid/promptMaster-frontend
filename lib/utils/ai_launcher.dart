import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Browsers often block ?q= / ?prompt= prefill when opened from another site.
/// Copying to the clipboard first is the reliable path; URL params are best-effort.
const int kMaxUrlPrefillLength = 6000;

String _chatGptLaunchUrl(String prompt) {
  final encoded = Uri.encodeComponent(prompt);
  return 'https://chatgpt.com/?q=$encoded';
}

String _claudeLaunchUrl(String prompt) {
  final encoded = Uri.encodeComponent(prompt);
  return 'https://claude.ai/new?q=$encoded';
}

Future<bool> _openInNewTab(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(
    uri,
    webOnlyWindowName: '_blank',
    mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
  );
}

Future<AiLaunchResult> _launch({
  required String Function(String prompt) buildUrl,
  required String fallbackUrl,
  required String prompt,
  required String serviceName,
}) async {
  final trimmed = prompt.trim();
  if (trimmed.isEmpty) {
    return AiLaunchResult.failed('Prompt is empty');
  }

  await Clipboard.setData(ClipboardData(text: trimmed));
  // Brief delay so the clipboard wins before the new tab takes focus (macOS/web).
  await Future<void>.delayed(const Duration(milliseconds: 200));

  final usePrefill = trimmed.length <= kMaxUrlPrefillLength;
  final url = usePrefill ? buildUrl(trimmed) : fallbackUrl;
  final opened = await _openInNewTab(url);
  if (!opened) {
    return AiLaunchResult.failed('Could not open $serviceName');
  }

  return AiLaunchResult.opened(
    prefilled: usePrefill,
    message:
        'Prompt copied. Opened $serviceName — paste with ${defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS ? '⌘' : 'Ctrl'}+V if the text box is empty.',
  );
}

Future<AiLaunchResult> launchChatGpt(String prompt) => _launch(
      buildUrl: _chatGptLaunchUrl,
      fallbackUrl: 'https://chatgpt.com/',
      prompt: prompt,
      serviceName: 'ChatGPT',
    );

Future<AiLaunchResult> launchClaude(String prompt) => _launch(
      buildUrl: _claudeLaunchUrl,
      fallbackUrl: 'https://claude.ai/new',
      prompt: prompt,
      serviceName: 'Claude',
    );

class AiLaunchResult {
  const AiLaunchResult._(
      {required this.success, this.prefilled = false, this.message});

  factory AiLaunchResult.opened({required bool prefilled, String? message}) =>
      AiLaunchResult._(success: true, prefilled: prefilled, message: message);

  factory AiLaunchResult.failed(String message) =>
      AiLaunchResult._(success: false, message: message);

  final bool success;
  final bool prefilled;
  final String? message;
}
