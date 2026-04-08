/// Stub for non-web platforms — vibration is handled natively via HapticFeedback
class WebVibration {
  static void vibrate(int durationMs) {
    // No-op on native platforms
  }

  static void vibratePattern(List<int> pattern) {
    // No-op on native platforms
  }
}
