import 'package:flutter/services.dart';

class HapticService {
  /// Trigger feedback on tap with configurable intensity
  /// [intensity] should be: 'light' (recommended), 'medium', or 'heavy'
  static Future<void> triggerTapFeedback(
    int tapCount,
    int interval, {
    String intensity = 'light',
  }) async {
    if (interval <= 0) return;
    if (tapCount % interval == 0) {
      switch (intensity) {
        case 'heavy':
          await HapticFeedback.heavyImpact();
          break;
        case 'medium':
          await HapticFeedback.mediumImpact();
          break;
        case 'light':
        default:
          await HapticFeedback.lightImpact();
          break;
      }
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
