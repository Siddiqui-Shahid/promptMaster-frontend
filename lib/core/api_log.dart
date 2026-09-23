import 'package:flutter/foundation.dart';

/// Logs to the `flutter run` terminal and Chrome DevTools console.
void apiLog(String message) => debugPrint('[API] $message');

void appLog(String message) => debugPrint('[APP] $message');
