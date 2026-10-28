/// Represents an authenticated user's profile and progress metrics.
class UserProfile {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.timezone = 'Asia/Jakarta',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Deterministic Level calculation rule:
  /// Level 1 starts at 0 XP. Every 100 XP advances 1 level.
  /// Current level = floor(total XP / 100) + 1.
  int get currentLevel => (totalXp / 100).floor() + 1;

  /// XP earned within the current level (0..99).
  int get xpInCurrentLevel => totalXp % 100;

  /// Fixed XP required for each level transition.
  int get xpRequiredForNextLevel => 100;

  /// Progress fraction (0.0 to 1.0) towards the next level.
  double get levelProgress => xpInCurrentLevel / 100.0;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: (json['display_name'] as String?)?.trim().isNotEmpty == true
          ? json['display_name'] as String
          : 'Teman One More',
      avatarUrl: json['avatar_url'] as String?,
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.tryParse(json['last_active_date'].toString())
          : null,
      timezone: json['timezone'] as String? ?? 'Asia/Jakarta',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'total_xp': totalXp,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_active_date': lastActiveDate?.toIso8601String().substring(0, 10),
      'timezone': timezone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
