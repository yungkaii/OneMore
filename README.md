# One More

> **One more step. One more day. One more you.**

One More adalah aplikasi pelacak kebiasaan (*personal habit tracker*) Android berbasis Flutter dan Supabase yang dirancang untuk membangun konsistensi harian melalui tindakan-tindakan kecil yang bermakna. Pengguna menyelesaikan misi harian, memperoleh XP, meningkatkan level pribadi, menjaga streak konsistensi, serta merayakan pencapaian tanpa beban kompetisi yang memberatkan.

---

## 1. Identitas & Prinsip Produk

- **Kemajuan di atas kesempurnaan (*Progress over perfection*)**: Tindakan kecil setiap hari lebih bermakna daripada target muluk yang mudah ditinggalkan.
- **Konsistensi tanpa intimidasi**: Tidak pernah mempermalukan pengguna ketika melewatkan satu hari.
- **Statistik Berbasis Data Riil**: Semua metrik kemajuan, persentase kepatuhan, streak, dan grafik 7 hari dihitung langsung dari data persisten di PostgreSQL.
- **Integritas XP & Keamanan**: XP dihitung secara otoritatif di sisi backend melalui transaksi PostgreSQL aman (`complete_habit`). Tidak ada celah manipulasi XP dari sisi klien ataupun duplikasi klaim pada tanggal yang sama.

---

## 2. Arsitektur & Teknologi

- **Platform**: Android (Material 3 dengan estetika warm restrained dark-first)
- **Framework**: Flutter 3.47+ & Dart 3.13+
- **State Management**: Riverpod 2.6
- **Routing**: GoRouter 14.8 (authentication-aware routing dengan StatefulShellRoute)
- **Backend**: Supabase Auth & Supabase PostgreSQL
- **Keamanan**: PostgreSQL Row Level Security (RLS) pada seluruh tabel pengguna
- **Notifikasi**: Flutter Local Notifications dengan penjadwalan timezone-aware (`Asia/Jakarta`)
- **Penyimpanan Lokal**: SharedPreferences untuk preferensi non-sensitif (tema, status onboarding)

### Struktur Direktori

```text
lib/
├── app/
│   └── app.dart                    # Root MaterialApp & tema
├── core/
│   ├── config/
│   │   └── env_config.dart         # Pengaturan runtime (--dart-define)
│   ├── constants/
│   │   ├── app_colors.dart         # Design tokens (#15171D, #20232B, #A8DDA0, #F6A65A, dll)
│   │   ├── app_strings.dart        # Konstanta teks Bahasa Indonesia
│   │   └── app_typography.dart     # Plus Jakarta Sans & angka tabular
│   ├── errors/
│   │   └── app_exception.dart      # Hierarki exception terstandarisasi
│   ├── providers/
│   │   └── app_providers.dart      # Dependency injection & state notifiers Riverpod
│   ├── routing/
│   │   └── app_router.dart         # Konfigurasi GoRouter & BottomNav Shell
│   ├── services/
│   │   ├── notification_service.dart# Penjadwalan pengingat lokal
│   │   └── storage_service.dart    # SharedPreferences wrapper
│   ├── theme/
│   │   └── app_theme.dart          # Dark Theme (default) & Light Theme M3
│   └── widgets/
│       ├── app_button.dart         # Tombol interaktif (loading & variant support)
│       ├── app_card.dart           # Surface card dengan border halus
│       ├── app_text_field.dart     # Form input field
│       ├── empty_state.dart        # Tampilan kosong informatif
│       ├── level_up_dialog.dart    # Modal perayaan naik level
│       ├── streak_badge.dart       # Badge api streak harian
│       └── xp_badge.dart           # Badge perolehan XP
├── data/
│   ├── models/
│   │   ├── achievement.dart        # Definisi pencapaian
│   │   ├── habit.dart              # Model kebiasaan & jadwal hari aktif
│   │   ├── habit_completion.dart   # Model penyelesaian misi per tanggal
│   │   ├── user_profile.dart       # Model profil pengguna, total XP, streak & level
│   │   └── xp_event.dart           # Audit trail transaksi XP
│   └── repositories/
│       ├── achievement_repository.dart
│       ├── auth_repository.dart
│       ├── habit_repository.dart
│       ├── profile_repository.dart
│       └── stats_repository.dart
├── features/
│   ├── achievements/               # Halaman katalog pencapaian (terbuka vs terkunci)
│   ├── authentication/             # Masuk, Daftar, Reset Kata Sandi & Panduan Setup
│   ├── dashboard/                  # Beranda misi harian, kartu XP & level progress
│   ├── habits/                     # Manajemen kebiasaan (tambah, edit, arsip, detail)
│   ├── onboarding/                 # 3-langkah pengenalan & pemilihan kebiasaan awal
│   ├── profile/                    # Profil pengguna, ubah nama, tema, & keluar akun
│   └── progress/                   # Grafik aktivitas mingguan & rasio kepatuhan
└── main.dart                       # Entry point aplikasi
```

---

## 3. Database & SQL Migrations

File migration lengkap tersedia di:
`supabase/migrations/20261028000000_init_onemore_schema.sql`

Skema mencakup:
1. `profiles`: Terhubung 1:1 dengan `auth.users(id)`. Menyimpan total XP, current streak, longest streak, last active date, dan timezone.
2. `habits`: Menyimpan kebiasaan aktif/arsip milik pengguna beserta jadwal hari (`active_weekdays`) dan pengingat waktu.
3. `habit_completions`: Enforces constraint `UNIQUE (habit_id, completion_date)` sehingga kebiasaan hanya dapat diselesaikan 1 kali per tanggal lokal.
4. `xp_events`: Audit trail perolehan XP dengan constraint `UNIQUE (user_id, event_type, source_id)` guna menjamin idempoten.
5. `achievements`: Katalog kanonikal pencapaian (First Step, Getting Started, Three in a Row, A Full Week, Consistent Action, Master of Habit).
6. `user_achievements`: Rekam jejak pencapaian yang terbuka per pengguna.
7. **Transaksi Otoritatif (`complete_habit`)**:
   Fungsi `SECURITY DEFINER` di PostgreSQL yang memvalidasi pemilik kebiasaan, memeriksa jadwal hari aktif, menyisipkan completion, mencatat event XP (+15 XP), menghitung kenaikan streak dan longest streak, serta membuka pencapaian yang memenuhi syarat secara atomik.

---

## 4. Cara Menjalankan Aplikasi

### A. Persiapan Konfigurasi Supabase

1. Buat project di [Supabase Dashboard](https://supabase.com).
2. Buka menu **SQL Editor**, buka file `supabase/migrations/20261028000000_init_onemore_schema.sql`, lalu klik **Run**.
3. Buat file `config.json` pada root proyek (dapat mencontoh `config.example.json`):

```json
{
  "SUPABASE_URL": "https://<your-project-ref>.supabase.co",
  "SUPABASE_ANON_KEY": "<your-anon-publishable-key>",
  "APP_TIMEZONE": "Asia/Jakarta"
}
```

> File `config.json` telah dimasukkan ke `.gitignore` sehingga kunci kredensial Anda aman dari commit publik.

### B. Menjalankan di Mode Debug

Jalankan perintah berikut:

```bash
flutter run --dart-define-from-file=config.json
```

Jika dijalankan tanpa Supabase, aplikasi akan menampilkan panduan setup interaktif yang memandu konfigurasi.

---

## 5. Pengujian (Testing)

Proyek dilengkapi dengan pengujian terotomatisasi mencakup logika matematika level, transisi tanggal streak, validasi model, dan widget:

```bash
flutter test
```

### Lingkup Test:
- **Level & XP**: Memverifikasi formula `floor(total_xp / 100) + 1` dan sisa progress `total_xp % 100` untuk nilai 0 XP, 70 XP, 100 XP, 250 XP, dan tingkat tinggi.
- **Streak State Machine**:
  - Penyelesaian pertama (streak = 1, longest = 1).
  - Multi-penyelesaian pada hari yang sama (streak tidak bertambah ganda).
  - Penyelesaian hari berurutan (streak +1, longest streak diperbarui).
  - Melewatkan hari (streak reset ke 1 tanpa menghapus longest streak).
  - Transisi batas akhir bulan (28 Feb -> 1 Mar) dan akhir tahun (31 Des -> 1 Jan).
- **Validasi Jadwal**: Hari aktif 1-7 ISO DOW dan penanganan kebiasaan diarsipkan.
- **UI Widget Testing**: Komponen `XpBadge`, `StreakBadge`, tombol loading, dan kartu interaktif misi.

---

## 6. Membangun APK Android

Untuk mengompilasi APK debug:

```bash
flutter build apk --debug --dart-define-from-file=config.json
```

Hasil kompilasi akan berada di:
`build/app/outputs/flutter-apk/app-debug.apk`
