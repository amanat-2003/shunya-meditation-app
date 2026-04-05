// GENERATED CODE - Manually written Hive adapter for MeditationSession

part of 'meditation_session.dart';

class MeditationSessionAdapter extends TypeAdapter<MeditationSession> {
  @override
  final int typeId = 0;

  @override
  MeditationSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return MeditationSession(
      id: fields[0] as String,
      userId: fields[1] as String,
      totalTaps: fields[2] as int,
      durationSeconds: fields[3] as int,
      goalReached: fields[4] as bool,
      createdAt: fields[5] as DateTime,
      syncStatus: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationSession obj) {
    writer
      ..writeByte(7) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.totalTaps)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.goalReached)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
