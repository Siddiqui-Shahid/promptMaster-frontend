import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_assets.dart';
import '../utils/ai_launcher.dart';

class PromptOutput extends StatefulWidget {
  const PromptOutput({
    super.key,
    required this.title,
    required this.prompt,
    required this.onCopy,
    this.stagePrompts = const [],
    this.usageHint = '',
    this.flow = '',
    this.onLaunchMessage,
    this.expand = true,
  });

  final String title;
  final String prompt;
  final List<String> stagePrompts;
  final String usageHint;
  final String flow;
  final VoidCallback onCopy;
  final void Function(String message)? onLaunchMessage;
  final bool expand;

  @override
  State<PromptOutput> createState() => _PromptOutputState();
}

class _PromptOutputState extends State<PromptOutput>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  bool get _hasStageTabs => _stagePromptCount > 0;

  int get _stagePromptCount {
    if (widget.flow == 'linkedin' && widget.stagePrompts.length >= 2) {
      return 2;
    }
    if (widget.flow == 'legacy' && widget.stagePrompts.length >= 5) {
      return 5;
    }
    if (widget.flow == 'legacy' && widget.stagePrompts.length >= 2) {
      return widget.stagePrompts.length.clamp(2, 5);
    }
    if (widget.stagePrompts.length >= 3) {
      return 3;
    }
    return 0;
  }

  int get _tabCount {
    return _hasStageTabs ? _stagePromptCount : 0;
  }

  List<String> get _tabLabels {
    final labels = <String>[];
    if (_hasStageTabs) {
      if (widget.flow == 'linkedin') {
        labels.addAll(const [
          'Stage 1 — Research',
          'Stage 2 — Raw TSV line',
        ]);
      } else if (widget.flow == 'legacy') {
        labels.addAll(const [
          'Stage 1 — Discovery',
          'Stage 2 — Digital Presence',
          'Stage 3 — Journey & Ops',
          'Stage 4 — Opportunities',
          'Stage 5 — Report & Email',
        ].take(widget.stagePrompts.length.clamp(2, 5)));
      } else if (widget.flow == 'cold_call') {
        labels.addAll(const [
          'Stage 1 — Research & Reviews',
          'Stage 2 — Opportunities',
          'Stage 3 — Call Script',
        ]);
      } else {
        labels.addAll(const [
          'Stage 1 — Research',
          'Stage 2 — Opportunities',
          'Stage 3 — Email',
        ]);
      }
    }
    return labels;
  }

  @override
  void initState() {
    super.initState();
    _initTabs();
  }

  int _tabCountForWidget(PromptOutput w) {
    var count = 0;
    if (w.flow == 'linkedin' && w.stagePrompts.length >= 2) {
      count += 2;
    } else if (w.flow == 'legacy' && w.stagePrompts.length >= 2) {
      count += w.stagePrompts.length.clamp(2, 5);
    } else if (w.stagePrompts.length >= 3) {
      count += 3;
    }
    return count;
  }

  @override
  void didUpdateWidget(covariant PromptOutput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabCountForWidget(oldWidget) != _tabCount ||
        oldWidget.flow != widget.flow) {
      _tabController?.dispose();
      _initTabs();
    }
  }

  void _initTabs() {
    if (_tabCount > 1) {
      _tabController = TabController(length: _tabCount, vsync: this);
    } else {
      _tabController = null;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  String get _activePrompt {
    if (_hasStageTabs && _tabController != null) {
      return widget.stagePrompts[_tabController!.index];
    }
    return widget.prompt;
  }

  String get _defaultUsageHint {
    if (_hasStageTabs) {
      if (widget.flow == 'linkedin') {
        return 'Run Stage 1 then Stage 2 in the same AI chat. Stage 2 = one raw line (3 tabs, no header) — paste into Sheets.';
      }
      if (widget.flow == 'legacy') {
        return 'Run Stages 1–5 in the same AI chat with web search. Stage 5 = report + APPS_SCRIPT_PAYLOAD JSON (2 follow-ups).';
      }
      if (widget.flow == 'cold_call') {
        return 'Run stages in order in the same AI chat. Stage 3 has your script and sticky notes for tough moments.';
      }
      return 'Run stages in order. Stage 3 JSON → Google Sheet → Import. Max 350 emails/day via Apps Script.';
    }
    return 'Paste in ChatGPT or Claude. Enable web search in the AI tool.';
  }

  Future<void> _openChatGpt() async {
    final result = await launchChatGpt(_activePrompt);
    if (!mounted) return;
    _handleResult(result);
  }

  Future<void> _openClaude() async {
    final result = await launchClaude(_activePrompt);
    if (!mounted) return;
    _handleResult(result);
  }

  void _handleResult(AiLaunchResult result) {
    if (!result.success) {
      widget.onLaunchMessage?.call(result.message ?? 'Could not open link');
      return;
    }
    widget.onLaunchMessage?.call(result.message ?? 'Opened');
  }

  void _copyActive() {
    Clipboard.setData(ClipboardData(text: _activePrompt));
    widget.onCopy();
  }

  double _scrollablePanelHeight(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    return (viewportHeight * 0.45).clamp(280.0, 420.0);
  }

  Widget _expandOrSized({required bool expand, required Widget child}) {
    if (expand) return Expanded(child: child);
    return SizedBox(height: _scrollablePanelHeight(context), child: child);
  }

  @override
  Widget build(BuildContext context) {
    final usageHint =
        widget.usageHint.isNotEmpty ? widget.usageHint : _defaultUsageHint;

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
                      Icon(Icons.check_circle_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Copy active prompt',
                  child: IconButton.filledTonal(
                    onPressed: _copyActive,
                    icon: const Icon(Icons.copy_rounded, size: 20),
                  ),
                ),
              ],
            ),
            if (_tabCount > 1 && _tabController != null) ...[
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                onTap: (_) => setState(() {}),
                tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
              ),
            ],
            const SizedBox(height: 14),
            ...[
              Text('Open in your AI assistant',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                usageHint,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AiLaunchButton(
                      label: 'ChatGPT',
                      assetPath: AppAssets.chatGptIcon,
                      style: _AiButtonStyle.chatGpt,
                      onPressed: _openChatGpt,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AiLaunchButton(
                      label: 'Claude',
                      assetPath: AppAssets.claudeIcon,
                      style: _AiButtonStyle.claude,
                      onPressed: _openClaude,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildPromptTextArea(context),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.03, end: 0);
  }

  Widget _buildPromptTextArea(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          _activePrompt,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );

    return _expandOrSized(
      expand: widget.expand,
      child: content,
    );
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
        border: isGpt
            ? Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1)
            : null,
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
