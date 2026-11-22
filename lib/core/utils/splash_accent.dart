import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

const _channel = MethodChannel('snapmyauto/splash');

// tells android which colour the native splash should use next launch
Future<void> setSplashAccent(AppAccent accent) async {
  if (defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await _channel.invokeMethod<void>('setAccent', accent.name);
  } on MissingPluginException {
    // tests run without the android side
  } on PlatformException {
    // not worth breaking the app over a splash colour
  }
}
