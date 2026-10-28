/// Audit trail record for XP earned by the user.
class XpEvent {
  final String id;
  final String userId;
  final String
      eventType; // 'habit_completion', 'achievement_unlocked', 'streak_bonus'
  final String sourceId;
  final int xpDelta;
  final DateTime createdAt;

  const XpEvent({
    required this.id,
    required this.userId,
    required this.eventType,
    required this.sourceId,
    required this.xpDelta,
    required this.createdAt,
  });

  factory XpEvent.fromJson(Map<String, dynamic> json) {
    return XpEvent(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventType: json['event_type'] as String,
      sourceId: json['source_id'] as String,
      xpDelta: (json['xp_delta'] as num).toInt(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_type': eventType,
      'source_id': sourceId,
      'xp_delta': xpDelta,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
