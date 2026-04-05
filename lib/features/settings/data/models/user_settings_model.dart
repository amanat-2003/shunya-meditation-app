import 'package:hive/hive.dart';

part 'user_settings_model.g.dart';

@HiveType(typeId: 1)
class UserSettingsModel extends HiveObject {
  @HiveField(0)
  int dailyTapGoal;

  @HiveField(1)
  int dailyTimeGoalSeconds;

  @HiveField(2)
  int hapticInterval;

  @HiveField(3)
  bool audioReminderEnabled;

  @HiveField(4)
  String audioReminderSound;

  /// Haptic intensity: 'light' (default/recommended), 'medium', 'heavy'
  @HiveField(5)
  String hapticIntensity;

  /// Whether to play the selected sound continuously in a loop during meditation
  @HiveField(6)
  bool continuousAudioEnabled;

  /// Path to a custom audio file picked from device. Empty string = use bundled asset.
  @HiveField(7)
  String customAudioPath;

  /// Display name for the custom audio (e.g. "my_mantra.mp3")
  @HiveField(8)
  String customAudioName;

  UserSettingsModel({
    this.dailyTapGoal = 1080,
    this.dailyTimeGoalSeconds = 600,
    this.hapticInterval = 1,
    this.audioReminderEnabled = false,
    this.audioReminderSound = 'om',
    this.hapticIntensity = 'light',
    this.continuousAudioEnabled = true,
    this.customAudioPath = '',
    this.customAudioName = '',
  });

  /// The display name shown in the UI for the current sound
  String get activeAudioDisplayName {
    if (customAudioPath.isNotEmpty && customAudioName.isNotEmpty) {
      return customAudioName;
    }
    // Capitalize first letter of built-in sound name
    if (audioReminderSound.isEmpty) return 'Om';
    return audioReminderSound[0].toUpperCase() + audioReminderSound.substring(1);
  }

  Map<String, dynamic> toJson() => {
        'daily_tap_goal': dailyTapGoal,
        'daily_time_goal_seconds': dailyTimeGoalSeconds,
        'haptic_interval': hapticInterval,
        'audio_reminder_enabled': audioReminderEnabled,
        'audio_reminder_sound': audioReminderSound,
        'haptic_intensity': hapticIntensity,
        'continuous_audio_enabled': continuousAudioEnabled,
        'custom_audio_path': customAudioPath,
        'custom_audio_name': customAudioName,
      };

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      dailyTapGoal: json['daily_tap_goal'] as int? ?? 1080,
      dailyTimeGoalSeconds: json['daily_time_goal_seconds'] as int? ?? 600,
      hapticInterval: json['haptic_interval'] as int? ?? 1,
      audioReminderEnabled: json['audio_reminder_enabled'] as bool? ?? false,
      audioReminderSound: json['audio_reminder_sound'] as String? ?? 'om',
      hapticIntensity: json['haptic_intensity'] as String? ?? 'light',
      continuousAudioEnabled: json['continuous_audio_enabled'] as bool? ?? false,
      customAudioPath: json['custom_audio_path'] as String? ?? '',
      customAudioName: json['custom_audio_name'] as String? ?? '',
    );
  }

  UserSettingsModel copyWith({
    int? dailyTapGoal,
    int? dailyTimeGoalSeconds,
    int? hapticInterval,
    bool? audioReminderEnabled,
    String? audioReminderSound,
    String? hapticIntensity,
    bool? continuousAudioEnabled,
    String? customAudioPath,
    String? customAudioName,
  }) {
    return UserSettingsModel(
      dailyTapGoal: dailyTapGoal ?? this.dailyTapGoal,
      dailyTimeGoalSeconds: dailyTimeGoalSeconds ?? this.dailyTimeGoalSeconds,
      hapticInterval: hapticInterval ?? this.hapticInterval,
      audioReminderEnabled: audioReminderEnabled ?? this.audioReminderEnabled,
      audioReminderSound: audioReminderSound ?? this.audioReminderSound,
      hapticIntensity: hapticIntensity ?? this.hapticIntensity,
      continuousAudioEnabled: continuousAudioEnabled ?? this.continuousAudioEnabled,
      customAudioPath: customAudioPath ?? this.customAudioPath,
      customAudioName: customAudioName ?? this.customAudioName,
    );
  }
}
