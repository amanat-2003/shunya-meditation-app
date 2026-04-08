import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Web implementation using the browser Vibration API.
/// Works on mobile browsers (Android Chrome, etc). Silently no-ops on desktop.
class WebVibration {
  static void vibrate(int durationMs) {
    try {
      web.window.navigator.vibrate(durationMs.toJS);
    } catch (_) {
      // Silently fail if Vibration API is not supported (e.g., desktop browsers)
    }
  }

  static void vibratePattern(List<int> pattern) {
    try {
      web.window.navigator.vibrate(pattern.map((e) => e.toJS).toList().toJS);
    } catch (_) {
      // Silently fail
    }
  }
}
