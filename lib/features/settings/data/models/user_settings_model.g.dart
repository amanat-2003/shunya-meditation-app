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
      dailyTapGoal: fields[0] as int,
      dailyTimeGoalSeconds: fields[1] as int,
      hapticInterval: fields[2] as int,
      audioReminderEnabled: fields[3] as bool,
      audioReminderSound: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingsModel obj) {
    writer
      ..writeByte(5) // number of fields
      ..writeByte(0)
      ..write(obj.dailyTapGoal)
      ..writeByte(1)
      ..write(obj.dailyTimeGoalSeconds)
      ..writeByte(2)
      ..write(obj.hapticInterval)
      ..writeByte(3)
      ..write(obj.audioReminderEnabled)
      ..writeByte(4)
      ..write(obj.audioReminderSound);
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
