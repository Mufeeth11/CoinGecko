import 'package:flutter/foundation.dart';

/// Central place for backend configuration.
///
/// Override at build/run time with:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api`
class ApiConfig {
  const ApiConfig._();

  static const String urlOverride = String.fromEnvironment('API_BASE_URL');
  static const Duration requestTimeout = Duration(seconds: 10);

  static List<String> get candidateBaseUrls {
    if (urlOverride.trim().isNotEmpty) return [urlOverride.trim()];
    if (kIsWeb) return const ['http://localhost:3000/api'];
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Try localhost (works on physical devices with adb reverse) first,
        // then fall back to 10.0.2.2 for Android emulators.
        return const [
          'http://localhost:3000/api',
          'http://10.0.2.2:3000/api',
        ];
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const ['http://localhost:3000/api'];
    }
  }

  static String get baseUrl => candidateBaseUrls.first;
}
