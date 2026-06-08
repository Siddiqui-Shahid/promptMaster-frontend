import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_branding.dart';
import '../providers/app_providers.dart';
import '../widgets/app_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/error_state.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> _signInWithGoogle(WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(size: 56),
                    const SizedBox(height: 24),
                    Text('Welcome to ${AppBranding.name}', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      AppBranding.tagline,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    if (authState.error != null) ...[
                      ErrorState(message: authState.error!),
                      const SizedBox(height: 12),
                    ],
                    AppButton(
                      label: 'Continue with Google',
                      icon: Icons.login_rounded,
                      onPressed: authState.isLoading ? null : () => _signInWithGoogle(ref),
                      loading: authState.isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
