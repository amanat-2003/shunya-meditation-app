// GENERATED CODE - Manually written Hive adapter for UserSettingsModel

part of 'user_settings_model.dart';

class UserSettingsModelAdapter extends TypeAdapter<UserSettingsModel> {
  @override
  final int typeId = 1;

  @override
  UserSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return UserSettingsModel(
      dailyTapGoal: fields[0] as int? ?? 1080,
      dailyTimeGoalSeconds: fields[1] as int? ?? 600,
      hapticInterval: fields[2] as int? ?? 1,
      audioReminderEnabled: fields[3] as bool? ?? false,
      audioReminderSound: fields[4] as String? ?? 'om',
      hapticIntensity: fields[5] as String? ?? 'light',
      continuousAudioEnabled: fields[6] as bool? ?? false,
      customAudioPath: fields[7] as String? ?? '',
      customAudioName: fields[8] as String? ?? '',
      brightModeEnabled: fields[9] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsModel obj) {
    writer
      ..writeByte(10) // number of fields
      ..writeByte(0)
      ..write(obj.dailyTapGoal)
      ..writeByte(1)
      ..write(obj.dailyTimeGoalSeconds)
      ..writeByte(2)
      ..write(obj.hapticInterval)
      ..writeByte(3)
      ..write(obj.audioReminderEnabled)
      ..writeByte(4)
      ..write(obj.audioReminderSound)
      ..writeByte(5)
      ..write(obj.hapticIntensity)
      ..writeByte(6)
      ..write(obj.continuousAudioEnabled)
      ..writeByte(7)
      ..write(obj.customAudioPath)
      ..writeByte(8)
      ..write(obj.customAudioName)
      ..writeByte(9)
      ..write(obj.brightModeEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
