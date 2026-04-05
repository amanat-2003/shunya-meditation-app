import 'package:flutter/services.dart';

class HapticService {
  /// Trigger feedback on tap (based on the configured interval)
  static Future<void> triggerTapFeedback(int tapCount, int interval) async {
    if (interval <= 0) return;
    if (tapCount % interval == 0) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Trigger a stronger haptic for milestone events
  static Future<void> triggerMilestoneFeedback() async {
    await HapticFeedback.heavyImpact();
  }

  /// Trigger feedback for the exit gesture confirmation
  static Future<void> triggerExitReady() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Trigger selection click for UI interactions
  static Future<void> triggerSelectionClick() async {
    await HapticFeedback.selectionClick();
  }
}
