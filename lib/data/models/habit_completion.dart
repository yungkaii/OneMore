/// Represents a completed habit instance on a specific calendar date.
class HabitCompletion {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completionDate;
  final int xpAwarded;
  final DateTime createdAt;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completionDate,
    this.xpAwarded = 15,
    required this.createdAt,
  });

  factory HabitCompletion.fromJson(Map<String, dynamic> json) {
    return HabitCompletion(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      userId: json['user_id'] as String,
      completionDate: json['completion_date'] is String
          ? DateTime.parse(json['completion_date'] as String)
          : (json['completion_date'] as DateTime),
      xpAwarded: (json['xp_awarded'] as num?)?.toInt() ?? 15,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completion_date': completionDate.toIso8601String().substring(0, 10),
      'xp_awarded': xpAwarded,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

