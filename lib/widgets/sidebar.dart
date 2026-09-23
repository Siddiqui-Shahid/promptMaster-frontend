import 'package:flutter/material.dart';

import '../models/prompt_generate_request.dart';
import 'app_logo.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.onNewPrompt,
    required this.onLogout,
    required this.selectedFlow,
    required this.onSelectFlow,
    this.historyTitles = const [],
  });

  final VoidCallback onNewPrompt;
  final VoidCallback onLogout;
  final OutreachFlow selectedFlow;
  final ValueChanged<OutreachFlow> onSelectFlow;
  final List<String> historyTitles;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppLogo(size: 44, compact: true),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: onNewPrompt,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('+ New Prompt'),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 10),
          _sectionTitle(context, 'Research'),
          _flowTile(context, OutreachFlow.linkedin, 'LinkedIn', Icons.link),
          _flowTile(context, OutreachFlow.email, 'Email', Icons.email_outlined),
          _flowTile(context, OutreachFlow.coldCall, 'Cold Call', Icons.phone_outlined),
          _flowTile(context, OutreachFlow.coldMessage, 'Cold Message', Icons.chat_bubble_outline),
          _flowTile(context, OutreachFlow.verification, 'Email Verification', Icons.verified_outlined),
          _flowTile(context, OutreachFlow.legacy, 'Digital Audit', Icons.fact_check_outlined),
          const SizedBox(height: 10),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 10),
          _sectionTitle(context, 'History'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Recent Prompts'),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: historyTitles.take(8).length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Text(
                  historyTitles[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _sectionTitle(context, 'Settings'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }

  Widget _flowTile(BuildContext context, OutreachFlow flow, String label, IconData icon) {
    final selected = selectedFlow == flow;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        dense: true,
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon, size: 18),
        title: Text(label),
        onTap: () => onSelectFlow(flow),
      ),
    );
  }
}
