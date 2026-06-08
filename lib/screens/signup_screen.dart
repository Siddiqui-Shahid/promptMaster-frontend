import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create Account', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  const Text(
                    'Accounts are created when you sign in with Google on the login screen.',
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Go to login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
