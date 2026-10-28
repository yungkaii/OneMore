/// Canonical achievement definition and optional user unlock status.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int xpReward;
  final String
      targetType; // 'total_completions', 'streak_days', 'total_xp', 'level'
  final int targetValue;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.xpReward = 25,
    required this.targetType,
    required this.targetValue,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['icon_name'] as String? ?? 'emoji_events',
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 25,
      targetType: json['target_type'] as String? ?? 'total_completions',
      targetValue: (json['target_value'] as num?)?.toInt() ?? 1,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'xp_reward': xpReward,
      'target_type': targetType,
      'target_value': targetValue,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? xpReward,
    String? targetType,
    int? targetValue,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      xpReward: xpReward ?? this.xpReward,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
