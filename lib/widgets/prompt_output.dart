import 'package:flutter/material.dart';

class PromptOutput extends StatelessWidget {
  const PromptOutput({
    super.key,
    required this.title,
    required this.prompt,
    required this.onCopy,
  });

  final String title;
  final String prompt;
  final VoidCallback onCopy;

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
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
                IconButton(onPressed: onCopy, icon: const Icon(Icons.copy_rounded)),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  prompt,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
