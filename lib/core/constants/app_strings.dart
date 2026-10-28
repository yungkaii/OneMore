/// Indonesian string constants for One More.
/// Tone: Encouraging, natural, concise, and friendly. Never shaming.
class AppStrings {
  AppStrings._();

  // App Identity
  static const String appName = 'One More';
  static const String tagline = 'One more step. One more day. One more you.';

  // Navigation
  static const String navHome = 'Beranda';
  static const String navHabits = 'Kebiasaan';
  static const String navProgress = 'Kemajuan';
  static const String navProfile = 'Profil';
  static const String navAchievements = 'Pencapaian';

  // Onboarding
  static const String onboardingTitle1 = 'Langkah Kecil Berarti';
  static const String onboardingSubtitle1 =
      'Perubahan besar berawal dari satu tindakan sederhana yang diulang setiap hari.';

  static const String onboardingTitle2 = 'Kumpulkan XP & Level';
  static const String onboardingSubtitle2 =
      'Setiap misi harian yang tuntas menghadiahkan XP untuk meningkatkan level pribadimu.';

  static const String onboardingTitle3 = 'Konsisten Tanpa Beban';
  static const String onboardingSubtitle3 =
      'Pertahankan streak harimu. Bila terlewat, jangan khawatir—mulai lagi langkah barumu.';

  static const String getStarted = 'Mulai Perjalanan';
  static const String continueText = 'Lanjutkan';
  static const String skip = 'Lewati';
  static const String chooseStarterHabits = 'Pilih kebiasaan awalmu:';
  static const String enterDisplayName = 'Siapa nama panggilanmu?';
  static const String displayNameHint = 'Contoh: Alex, Budi, Maya';

  // Auth
  static const String loginTitle = 'Selamat Datang Kembali';
  static const String loginSubtitle = 'Lanjutkan langkah kecilmu hari ini.';
  static const String registerTitle = 'Buat Akun One More';
  static const String registerSubtitle =
      'Mulai bangun kebiasaan yang langgeng.';
  static const String emailLabel = 'Email';
  static const String emailHint = 'nama@email.com';
  static const String passwordLabel = 'Kata Sandi';
  static const String passwordHint = 'Minimal 6 karakter';
  static const String loginAction = 'Masuk';
  static const String registerAction = 'Daftar';
  static const String logoutAction = 'Keluar Akun';
  static const String forgotPassword = 'Lupa kata sandi?';
  static const String resetPasswordTitle = 'Atur Ulang Kata Sandi';
  static const String resetPasswordSubtitle =
      'Kami akan mengirimkan tautan pemulihan ke email Anda.';
  static const String sendResetLink = 'Kirim Tautan';
  static const String noAccountPrompt = 'Belum punya akun?';
  static const String haveAccountPrompt = 'Sudah punya akun?';

  // Dashboard & Missions
  static const String todayGreetingMorning = 'Selamat pagi';
  static const String todayGreetingAfternoon = 'Selamat siang';
  static const String todayGreetingEvening = 'Selamat sore';
  static const String todayGreetingNight = 'Selamat malam';
  static const String todayMissionsTitle = 'Misi Hari Ini';
  static const String allMissionsDone =
      'Luar biasa! Semua misi hari ini selesai.';
  static const String noMissionsScheduled =
      'Tidak ada jadwal kebiasaan untuk hari ini.';
  static const String xpEarnedToast = '+15 XP diraih!';
  static const String levelUpTitle = 'Naik Level!';
  static const String levelUpSubtitle =
      'Selamat! Kamu kini telah mencapai Level';

  // Habits
  static const String habitsTitle = 'Daftar Kebiasaan';
  static const String createHabit = 'Tambah Kebiasaan';
  static const String editHabit = 'Ubah Kebiasaan';
  static const String habitTitleLabel = 'Nama Kebiasaan';
  static const String habitTitleHint = 'Misal: Membaca buku 15 menit';
  static const String habitDescLabel = 'Keterangan (opsional)';
  static const String habitDescHint = 'Tambahkan rincian atau motivasi kecil';
  static const String categoryLabel = 'Kategori';
  static const String activeDaysLabel = 'Hari Aktif';
  static const String reminderTimeLabel = 'Pengingat Waktu (opsional)';
  static const String archiveHabit = 'Arsipkan Kebiasaan';
  static const String unarchiveHabit = 'Aktifkan Kembali';
  static const String deleteHabit = 'Hapus Kebiasaan';
  static const String saveChanges = 'Simpan';
  static const String archivedNotice = 'Kebiasaan ini telah diarsipkan.';

  // Categories
  static const String catHealth = 'Kesehatan';
  static const String catLearning = 'Belajar';
  static const String catMindfulness = 'Pikiran';
  static const String catProductivity = 'Produktivitas';
  static const String catRoutine = 'Rutinitas';

  // Progress & Stats
  static const String weeklyOverview = 'Aktivitas 7 Hari Terakhir';
  static const String totalXpLabel = 'Total XP';
  static const String currentStreakLabel = 'Streak Saat Ini';
  static const String longestStreakLabel = 'Streak Terpanjang';
  static const String completionRateLabel = 'Tingkat Kepatuhan';
  static const String daysSuffix = 'hari';
  static const String completedCountSuffix = 'selesai';

  // Settings & Profile
  static const String settingsTitle = 'Pengaturan';
  static const String profileTitle = 'Profil Pengguna';
  static const String themePreference = 'Tema Aplikasi';
  static const String darkMode = 'Mode Gelap (Bawaan)';
  static const String lightMode = 'Mode Terang';
  static const String systemTheme = 'Mengikuti Sistem';
  static const String notifications = 'Notifikasi & Pengingat';
  static const String enableReminders = 'Aktifkan Pengingat Harian';
  static const String timezoneSetting = 'Zona Waktu';
  static const String aboutApp = 'Tentang One More';
  static const String version = 'Versi 1.0.0';

  // Errors & States
  static const String commonError =
      'Terjadi kendala. Silakan coba sesaat lagi.';
  static const String networkError =
      'Koneksi internet bermasalah. Periksa jaringan Anda.';
  static const String retry = 'Coba Lagi';
  static const String emptyHabitPrompt =
      'Belum ada kebiasaan. Buat kebiasaan pertamamu!';
  static const String missingSupabaseConfig =
      'Konfigurasi Supabase belum terpasang.';
  static const String setupGuideAction = 'Lihat Panduan Setup';
}
