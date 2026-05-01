import 'package:flutter/foundation.dart';

String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:8080/api/v1';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:8080/api/v1';
    case TargetPlatform.iOS:
      return 'http://localhost:8080/api/v1';
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return 'http://localhost:8080/api/v1';
    case TargetPlatform.fuchsia:
      return 'http://localhost:8080/api/v1';
  }
}
