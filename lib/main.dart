import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_providers.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: PromptPlatformApp()));
}

class PromptPlatformApp extends ConsumerWidget {
  const PromptPlatformApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final auth = ref.watch(authNotifierProvider);

    return MaterialApp.router(
      title: 'Business Prompt Platform',
      theme: AppTheme.dark(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) {
        if (auth.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
