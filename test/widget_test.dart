import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onemore/core/widgets/app_button.dart';
import 'package:onemore/core/widgets/empty_state.dart';
import 'package:onemore/core/widgets/streak_badge.dart';
import 'package:onemore/core/widgets/xp_badge.dart';
import 'package:onemore/data/models/habit.dart';
import 'package:onemore/features/dashboard/widgets/mission_item_tile.dart';

void main() {
  group('Core UI Component Widget Tests', () {
    testWidgets('XpBadge renders correct label with plus sign', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: XpBadge(xp: 15, showPlus: true),
          ),
        ),
      );

      expect(find.text('+15 XP'), findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });

    testWidgets('StreakBadge displays days count and flame icon',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StreakBadge(days: 7),
          ),
        ),
      );

      expect(find.text('7 Hari'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    });

    testWidgets('AppButton displays loading spinner when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Simpan',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Simpan'), findsNothing);
    });

    testWidgets('EmptyState displays title, message, and invokes CTA on tap',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.track_changes_rounded,
              title: 'Belum Ada Kebiasaan',
              message: 'Mulai buat kebiasaan baru.',
              actionLabel: 'Tambah Kebiasaan',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Belum Ada Kebiasaan'), findsOneWidget);
      expect(find.text('Mulai buat kebiasaan baru.'), findsOneWidget);
      expect(find.text('Tambah Kebiasaan'), findsOneWidget);

      await tester.tap(find.text('Tambah Kebiasaan'));
      await tester.pump();

      expect(actionTriggered, isTrue);
    });

    testWidgets('MissionItemTile renders habit title and responds to tap',
        (tester) async {
      bool toggled = false;
      final habit = Habit(
        id: 'h1',
        userId: 'u1',
        title: 'Membaca Buku 15 Menit',
        category: 'learning',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MissionItemTile(
              habit: habit,
              isCompleted: false,
              isProcessing: false,
              onToggle: () {
                toggled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Membaca Buku 15 Menit'), findsOneWidget);
      expect(find.text('+15 XP'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(toggled, isTrue);
    });
  });
}
