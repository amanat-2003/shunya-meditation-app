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

  UserSettingsModel({
    this.dailyTapGoal = 1080,
    this.dailyTimeGoalSeconds = 600,
    this.hapticInterval = 1,
    this.audioReminderEnabled = false,
    this.audioReminderSound = 'om',
  });

  Map<String, dynamic> toJson() => {
        'daily_tap_goal': dailyTapGoal,
        'daily_time_goal_seconds': dailyTimeGoalSeconds,
        'haptic_interval': hapticInterval,
        'audio_reminder_enabled': audioReminderEnabled,
        'audio_reminder_sound': audioReminderSound,
      };

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      dailyTapGoal: json['daily_tap_goal'] as int? ?? 1080,
      dailyTimeGoalSeconds: json['daily_time_goal_seconds'] as int? ?? 600,
      hapticInterval: json['haptic_interval'] as int? ?? 1,
      audioReminderEnabled: json['audio_reminder_enabled'] as bool? ?? false,
      audioReminderSound: json['audio_reminder_sound'] as String? ?? 'om',
    );
  }

  UserSettingsModel copyWith({
    int? dailyTapGoal,
    int? dailyTimeGoalSeconds,
    int? hapticInterval,
    bool? audioReminderEnabled,
    String? audioReminderSound,
  }) {
    return UserSettingsModel(
      dailyTapGoal: dailyTapGoal ?? this.dailyTapGoal,
      dailyTimeGoalSeconds: dailyTimeGoalSeconds ?? this.dailyTimeGoalSeconds,
      hapticInterval: hapticInterval ?? this.hapticInterval,
      audioReminderEnabled: audioReminderEnabled ?? this.audioReminderEnabled,
      audioReminderSound: audioReminderSound ?? this.audioReminderSound,
    );
  }
}
