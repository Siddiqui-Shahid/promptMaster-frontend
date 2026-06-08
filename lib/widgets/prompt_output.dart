import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_assets.dart';
import '../utils/ai_launcher.dart';

class PromptOutput extends StatelessWidget {
  const PromptOutput({
    super.key,
    required this.title,
    required this.prompt,
    required this.onCopy,
    this.onLaunchMessage,
  });

  final String title;
  final String prompt;
  final VoidCallback onCopy;
  final void Function(String message)? onLaunchMessage;

  Future<void> _openChatGpt(BuildContext context) async {
    final result = await launchChatGpt(prompt);
    if (!context.mounted) return;
    _handleResult(context, result);
  }

  Future<void> _openClaude(BuildContext context) async {
    final result = await launchClaude(prompt);
    if (!context.mounted) return;
    _handleResult(context, result);
  }

  void _handleResult(BuildContext context, AiLaunchResult result) {
    if (!result.success) {
      onLaunchMessage?.call(result.message ?? 'Could not open link');
      return;
    }
    onLaunchMessage?.call(result.message ?? 'Opened');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Copy prompt',
                  child: IconButton.filledTonal(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Open in your AI assistant', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Your prompt is copied automatically. Paste in the chat if it does not appear.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AiLaunchButton(
                    label: 'ChatGPT',
                    assetPath: AppAssets.chatGptIcon,
                    style: _AiButtonStyle.chatGpt,
                    onPressed: () => _openChatGpt(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AiLaunchButton(
                    label: 'Claude',
                    assetPath: AppAssets.claudeIcon,
                    style: _AiButtonStyle.claude,
                    onPressed: () => _openClaude(context),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    prompt,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.03, end: 0);
  }
}

enum _AiButtonStyle { chatGpt, claude }

class _AiLaunchButton extends StatefulWidget {
  const _AiLaunchButton({
    required this.label,
    required this.assetPath,
    required this.style,
    required this.onPressed,
  });

  final String label;
  final String assetPath;
  final _AiButtonStyle style;
  final VoidCallback onPressed;

  @override
  State<_AiLaunchButton> createState() => _AiLaunchButtonState();
}

class _AiLaunchButtonState extends State<_AiLaunchButton> {
  bool _hovered = false;

  static const _claudeOrange = Color(0xFFCC785C);

  @override
  Widget build(BuildContext context) {
    final isGpt = widget.style == _AiButtonStyle.chatGpt;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: isGpt ? Colors.black : _claudeOrange,
          borderRadius: BorderRadius.circular(12),
          elevation: _hovered ? 4 : 0,
          shadowColor: Colors.black54,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: isGpt ? 2 : 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
                child: Row(
                  children: [
                    _BrandLogo(path: widget.assetPath, isGpt: isGpt),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square brand mark from asset (chatGPT.png / Claude.jpeg).
class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.path, required this.isGpt});

  final String path;
  final bool isGpt;

  static const double _size = 40;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: isGpt ? Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        path,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => ColoredBox(
          color: isGpt ? Colors.grey.shade900 : const Color(0xFFCC785C),
          child: Icon(
            isGpt ? Icons.auto_awesome : Icons.psychology_alt_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
