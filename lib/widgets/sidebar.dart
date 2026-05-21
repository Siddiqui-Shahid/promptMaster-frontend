import 'package:flutter/material.dart';

import '../models/prompt_summary.dart';
import 'prompt_card.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.prompts,
    required this.onNewPrompt,
    required this.onOpenPrompt,
    required this.onLogout,
    this.selectedPromptId,
    this.isLoading = false,
  });

  final List<PromptSummary> prompts;
  final VoidCallback onNewPrompt;
  final void Function(int id) onOpenPrompt;
  final VoidCallback onLogout;
  final int? selectedPromptId;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text('PromptOS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: onNewPrompt, child: const Text('New Prompt')),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: prompts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = prompts[index];
                      return PromptCard(
                        prompt: item,
                        selected: selectedPromptId == item.id,
                        onTap: () => onOpenPrompt(item.id),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(onPressed: onLogout, child: const Text('Logout')),
            ),
          ),
        ],
      ),
    );
  }
}
