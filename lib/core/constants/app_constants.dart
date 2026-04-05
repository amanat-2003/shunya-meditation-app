import 'dart:math';

class AppConstants {
  AppConstants._();

  // Tap & Timing
  static const Duration tapThrottleDuration = Duration(milliseconds: 150);
  static const Duration exitLongPressDuration = Duration(seconds: 3);
  static const Duration hintDisplayDuration = Duration(seconds: 3);
  static const int rapidTapThreshold = 5;
  static const Duration rapidTapWindow = Duration(seconds: 2);
  static const int autoSaveInterval = 10; // taps

  // Audio Reminders
  static const int audioReminderMinMinutes = 8;
  static const int audioReminderMaxMinutes = 15;

  // Haptic intervals
  static const List<int> hapticIntervalOptions = [1, 10, 20, 50];

  // Default goals
  static const int defaultDailyTapGoal = 1080;
  static const int defaultDailyTimeGoalSeconds = 600; // 10 minutes

  // Hive box names
  static const String sessionsBoxName = 'meditation_sessions';
  static const String settingsBoxName = 'user_settings';
  static const String appStateBoxName = 'app_state';

  // Motivational / Spiritual quotes
  static const List<String> quotes = [
    '"The mind is everything. What you think you become." — Buddha',
    '"In the silence of meditation, the soul finds its voice."',
    '"Be still, and know." — Psalm 46:10',
    '"The quieter you become, the more you can hear." — Ram Dass',
    '"Meditation is not about stopping thoughts, but recognizing that we are more than our thoughts."',
    '"Om is the imperishable word. It is the universe, and this is its exposition." — Mandukya Upanishad',
    '"When meditation is mastered, the mind is unwavering like the flame of a candle in a windless place." — Bhagavad Gita',
    '"Your calm mind is the ultimate weapon against your challenges."',
    '"The present moment is the only moment available to us, and it is the door to all moments." — Thich Nhat Hanh',
    '"Peace comes from within. Do not seek it without." — Buddha',
    '"In the middle of movement and chaos, keep stillness inside of you." — Deepak Chopra',
    '"Meditation brings wisdom; lack of meditation leaves ignorance." — Buddha',
    '"The goal of meditation is not to control your thoughts, it is to stop letting them control you."',
    '"Feelings come and go like clouds in a windy sky. Conscious breathing is my anchor." — Thich Nhat Hanh',
    '"One who is established in the Self is established in peace." — Bhagavad Gita',
    '"Silence is the language of God, all else is poor translation." — Rumi',
    '"Empty yourself and let the universe fill you."',
    '"Mala beads are not just counters — they are a bridge between you and the Divine."',
    '"108 beads, 108 chances to be present."',
    '"Each bead is a breath, each round is a prayer."',
    '"When you own your breath, nobody can steal your peace." — Unknown',
    '"The mind is like water. When it\'s turbulent, it\'s difficult to see. When it\'s calm, everything becomes clear."',
    '"Jaap is the silent conversation between the soul and the infinite."',
    '"Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment." — Buddha',
    '"Through meditation and by giving full attention to one thing at a time, we can learn to direct attention where we choose." — Eknath Easwaran',
    '"The soul always knows what to do to heal itself. The challenge is to silence the mind." — Caroline Myss',
    '"Sat Nam — Truth is my identity." — Kundalini Mantra',
    '"Meditation is the dissolution of thoughts in eternal awareness." — Voltaire',
    '"You should sit in meditation for 20 minutes every day — unless you\'re too busy. Then you should sit for an hour." — Zen Proverb',
    '"Let go of the thoughts that don\'t make you strong."',
  ];

  /// Returns the quote of the day (changes daily, deterministic)
  static String getQuoteOfTheDay() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  /// Random duration for audio reminder interval
  static Duration getRandomReminderInterval() {
    final random = Random();
    final minutes = audioReminderMinMinutes +
        random.nextInt(audioReminderMaxMinutes - audioReminderMinMinutes + 1);
    return Duration(minutes: minutes);
  }
}
