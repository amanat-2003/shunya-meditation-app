import 'package:hive/hive.dart';

part 'meditation_session.g.dart';

@HiveType(typeId: 0)
class MeditationSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  int totalTaps;

  @HiveField(3)
  int durationSeconds;

  @HiveField(4)
  bool goalReached;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String syncStatus; // 'synced' | 'pending'

  MeditationSession({
    required this.id,
    required this.userId,
    this.totalTaps = 0,
    this.durationSeconds = 0,
    this.goalReached = false,
    DateTime? createdAt,
    this.syncStatus = 'pending',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'total_taps': totalTaps,
        'duration_seconds': durationSeconds,
        'goal_reached': goalReached,
        'created_at': createdAt.toUtc().toIso8601String(),
        'sync_status': syncStatus,
      };

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    return MeditationSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      totalTaps: json['total_taps'] as int? ?? 0,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      goalReached: json['goal_reached'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncStatus: json['sync_status'] as String? ?? 'synced',
    );
  }

  MeditationSession copyWith({
    String? id,
    String? userId,
    int? totalTaps,
    int? durationSeconds,
    bool? goalReached,
    DateTime? createdAt,
    String? syncStatus,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalTaps: totalTaps ?? this.totalTaps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      goalReached: goalReached ?? this.goalReached,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
