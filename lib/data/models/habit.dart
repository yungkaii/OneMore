/// Represents an individual habit tracked in One More.
class Habit {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String
      category; // 'health', 'learning', 'mindfulness', 'productivity', 'routine'
  final String iconName;
  final String accentColor;
  final List<int> activeWeekdays; // 1=Mon, 2=Tue, ..., 7=Sun
  final String? reminderTime; // 'HH:mm'
  final bool isArchived;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    this.iconName = 'check_circle',
    this.accentColor = 'green',
    this.activeWeekdays = const [1, 2, 3, 4, 5, 6, 7],
    this.reminderTime,
    this.isArchived = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Authoritative XP granted when completing this habit.
  int get xpReward => 15;

  /// Checks if this habit is scheduled for the given date.
  bool isScheduledFor(DateTime date) {
    if (isArchived) return false;
    return activeWeekdays.contains(date.weekday);
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    List<int> parseWeekdays(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => (e as num).toInt()).toList();
      }
      return [1, 2, 3, 4, 5, 6, 7];
    }

    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'routine',
      iconName: json['icon_name'] as String? ?? 'check_circle',
      accentColor: json['accent_color'] as String? ?? 'green',
      activeWeekdays: parseWeekdays(json['active_weekdays']),
      reminderTime: json['reminder_time'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
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
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'icon_name': iconName,
      'accent_color': accentColor,
      'active_weekdays': activeWeekdays,
      'reminder_time': reminderTime,
      'is_archived': isArchived,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? iconName,
    String? accentColor,
    List<int>? activeWeekdays,
    String? reminderTime,
    bool? isArchived,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      accentColor: accentColor ?? this.accentColor,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      reminderTime: reminderTime ?? this.reminderTime,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
