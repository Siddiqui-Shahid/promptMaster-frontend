import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/api_config.dart';
import 'core/api_log.dart';
import 'core/app_branding.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  appLog('Starting ${AppBranding.name}');
  appLog('API_BASE_URL=${ApiConfig.baseUrl}');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  appLog('Firebase initialized project=${DefaultFirebaseOptions.currentPlatform.projectId}');

  runApp(const ProviderScope(child: PromptMasterApp()));
}

class PromptMasterApp extends ConsumerWidget {
  const PromptMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final auth = ref.watch(authNotifierProvider);

    return MaterialApp.router(
      title: AppBranding.name,
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
