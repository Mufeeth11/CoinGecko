import 'package:flutter/foundation.dart';

/// Central place for backend configuration.
///
/// Override at build/run time with:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api`
class ApiConfig {
  const ApiConfig._();

  static const String urlOverride = String.fromEnvironment('API_BASE_URL');
  static const Duration requestTimeout = Duration(seconds: 10);

  static String get baseUrl {
    if (urlOverride.trim().isNotEmpty) return urlOverride.trim();
    if (kIsWeb) return 'http://localhost:3000/api';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Special alias for the host machine from the Android emulator.
        return 'http://10.0.2.2:3000/api';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:3000/api';
    }
  }
}
