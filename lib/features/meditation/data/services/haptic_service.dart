import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'web_vibration.dart';

class HapticService {
  /// Trigger feedback on tap with configurable intensity
  /// [intensity] should be: 'light' (recommended), 'medium', or 'heavy'
  static Future<void> triggerTapFeedback(
    int tapCount,
    int interval, {
    String intensity = 'light',
  }) async {
    if (interval <= 0) return;
    if (tapCount % interval != 0) return;

    if (kIsWeb) {
      // Use Web Vibration API on mobile browsers
      switch (intensity) {
        case 'heavy':
          WebVibration.vibrate(40);
          break;
        case 'medium':
          WebVibration.vibrate(25);
          break;
        case 'light':
        default:
          WebVibration.vibrate(10);
          break;
      }
      return;
    }

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

  /// Trigger a stronger haptic for milestone events
  static Future<void> triggerMilestoneFeedback() async {
    if (kIsWeb) {
      WebVibration.vibrate(50);
      return;
    }
    await HapticFeedback.heavyImpact();
  }

  /// Trigger feedback for the exit gesture confirmation
  static Future<void> triggerExitReady() async {
    if (kIsWeb) {
      WebVibration.vibratePattern([25, 100, 25]);
      return;
    }
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Trigger selection click for UI interactions
  static Future<void> triggerSelectionClick() async {
    if (kIsWeb) {
      WebVibration.vibrate(5);
      return;
    }
    await HapticFeedback.selectionClick();
  }
}
