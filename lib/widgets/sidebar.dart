import 'package:flutter/material.dart';

import 'app_logo.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.onNewPrompt,
    required this.onLogout,
  });

  final VoidCallback onNewPrompt;
  final VoidCallback onLogout;

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
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: onNewPrompt,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('New Prompt'),
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _NavHint(
              icon: Icons.edit_note_outlined,
              label: 'Fill the form, then generate',
            ),
          ),
          const Spacer(),
          const Divider(height: 1, indent: 16, endIndent: 16),
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
}

class _NavHint extends StatelessWidget {
  const _NavHint({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
        ),
      ],
    );
  }
}
