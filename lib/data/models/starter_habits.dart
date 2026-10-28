import 'habit.dart';

/// Preset canonical starter habits matching the design specification.
class StarterHabits {
  StarterHabits._();

  static List<Habit> getRecommended(String userId) {
    final now = DateTime.now();
    return [
      Habit(
        id: '',
        userId: userId,
        title: 'Minum Air 8 Gelas',
        description: 'Minum minimal 8 gelas air dalam sehari (±2 liter).',
        category: 'health',
        iconName: 'water_drop',
        accentColor: 'blue',
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Habit(
        id: '',
        userId: userId,
        title: 'Olahraga 30 Menit',
        description:
            'Aktivitas fisik ringan hingga sedang untuk kebugaran tubuh.',
        category: 'health',
        iconName: 'directions_run',
        accentColor: 'green',
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      Habit(
        id: '',
        userId: userId,
        title: 'Baca Buku 20 Menit',
        description: 'Membaca buku pengembangan diri atau wawasan baru.',
        category: 'learning',
        iconName: 'menu_book',
        accentColor: 'purple',
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      ),
      Habit(
        id: '',
        userId: userId,
        title: 'Tidur 7-8 Jam',
        description: 'Menjaga waktu istirahat yang cukup dan teratur.',
        category: 'routine',
        iconName: 'bedtime',
        accentColor: 'blue',
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        sortOrder: 4,
        createdAt: now,
        updatedAt: now,
      ),
      Habit(
        id: '',
        userId: userId,
        title: 'Jaga Pola Makan',
        description:
            'Konsumsi makanan bergizi seimbang dan kurangi gula berlebih.',
        category: 'health',
        iconName: 'restaurant',
        accentColor: 'orange',
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        sortOrder: 5,
        createdAt: now,
        updatedAt: now,
      ),
      Habit(
        id: '',
        userId: userId,
        title: 'Belajar / Kerja Fokus',
        description: 'Sesi fokus tanpa distraksi selama minimal 45 menit.',
        category: 'productivity',
        iconName: 'workspace_premium',
        accentColor: 'purple',
        activeWeekdays: const [1, 2, 3, 4, 5, 6, 7],
        sortOrder: 6,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
