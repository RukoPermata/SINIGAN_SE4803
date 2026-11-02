import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sini_gan/core/theme/app_theme.dart';
import 'package:sini_gan/data/mock_data_store.dart';
import 'package:sini_gan/features/admin/screens/admin_dashboard_screen.dart';
import 'package:sini_gan/features/admin/screens/schedule_management_screen.dart';
import 'package:sini_gan/models/regular_schedule.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: child,
    );
  }

  testWidgets('ScheduleManagementScreen renders with tabs, schedule list, and filters', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const ScheduleManagementScreen()));
    await tester.pumpAndSettle();

    // Verify AppBar title
    expect(find.text('Jadwal & Blokir Tanggal'), findsOneWidget);

    // Verify Tab headers
    expect(find.byType(Tab), findsNWidgets(2));

    // Verify day filter chips
    expect(find.widgetWithText(FilterChip, 'Semua Hari'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Senin'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Selasa'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Rabu'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Kamis'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Jumat'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Sabtu'), findsOneWidget);

    // Verify schedule items from mock data
    expect(find.text('Pemrograman Aplikasi Bergerak'), findsOneWidget);
    expect(find.text('SE4803'), findsOneWidget);
    expect(find.text('Dr. Budi Santoso, M.Kom.'), findsOneWidget);

    // Verify FloatingActionButton
    expect(find.text('Tambah Jadwal'), findsOneWidget);
  });

  testWidgets('Filtering regular schedules by day works properly', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const ScheduleManagementScreen()));
    await tester.pumpAndSettle();

    // Tap on 'Selasa' filter chip
    await tester.tap(find.widgetWithText(FilterChip, 'Selasa'));
    await tester.pumpAndSettle();

    // Should show schedule on Tuesday: Konstruksi & Pengujian Perangkat Lunak
    expect(find.text('Konstruksi & Pengujian Perangkat Lunak'), findsOneWidget);
    // Should NOT show schedule on Monday: Pemrograman Aplikasi Bergerak
    expect(find.text('Pemrograman Aplikasi Bergerak'), findsNothing);

    // Tap on 'Reset Filter'
    await tester.tap(find.text('Reset Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Pemrograman Aplikasi Bergerak'), findsOneWidget);
  });

  testWidgets('Toggling schedule active status updates MockDataStore', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const ScheduleManagementScreen()));
    await tester.pumpAndSettle();

    final schedule = MockDataStore.instance.regularSchedules.first;
    final initialStatus = schedule.isActive;

    // Toggle the first switch
    final switches = find.byType(Switch);
    expect(switches, findsWidgets);

    await tester.tap(switches.first);
    await tester.pumpAndSettle();

    final updated = MockDataStore.instance.regularSchedules.firstWhere((s) => s.id == schedule.id);
    expect(updated.isActive, !initialStatus);

    // Revert back
    await tester.tap(switches.first);
    await tester.pumpAndSettle();
  });

  testWidgets('Can delete regular schedule with confirmation dialog', (tester) async {
    // Add a temporary schedule to safely delete
    const tempSched = RegularSchedule(
      id: 'sched-test-delete',
      roomId: 'room-tult-0701',
      roomName: 'TULT-0701',
      courseCode: 'DEL101',
      courseName: 'Mata Kuliah Hapus Test',
      lecturerName: 'Dosen Hapus',
      classGroup: 'SE-48-99',
      dayOfWeek: 1,
      startTime: '06:00',
      endTime: '07:30',
      semester: 'Genap 2024/2025',
      isActive: true,
    );
    MockDataStore.instance.addRegularSchedule(tempSched);

    await tester.pumpWidget(buildTestableWidget(const ScheduleManagementScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Mata Kuliah Hapus Test'), findsOneWidget);

    // Find delete icon for this schedule
    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsWidgets);

    // Tap first delete button
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Confirm dialog appears
    expect(find.text('Hapus Jadwal Perkuliahan?'), findsOneWidget);

    // Tap 'Hapus Jadwal'
    final confirmButton = find.widgetWithText(ElevatedButton, 'Hapus Jadwal');
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Verify deleted
    expect(
      MockDataStore.instance.regularSchedules.any((s) => s.id == 'sched-test-delete'),
      isFalse,
    );
  });

  testWidgets('Switching to Blackout tab displays blackout periods and FAB changes', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const ScheduleManagementScreen()));
    await tester.pumpAndSettle();

    // Tap second tab via its unique icon (Icons.block_outlined)
    final blackoutTabIcon = find.byIcon(Icons.block_outlined);
    expect(blackoutTabIcon, findsOneWidget);
    await tester.tap(blackoutTabIcon);
    await tester.pumpAndSettle();

    // Verify educational banner and filter chips
    expect(find.textContaining('Periode pemblokiran menonaktifkan ruangan'), findsOneWidget);
    expect(find.textContaining('Semua ('), findsOneWidget);
    expect(find.textContaining('Aktif ('), findsOneWidget);
    expect(find.textContaining('Nonaktif ('), findsOneWidget);

    // Verify mock blackout items
    expect(find.text('Pekan Ujian Tengah Semester (UTS) Genap'), findsOneWidget);
    expect(find.text('Maintenance Jaringan & Upgrade Workstation'), findsOneWidget);

    // Verify FAB changed to 'Blokir Tanggal'
    expect(find.widgetWithText(FloatingActionButton, 'Blokir Tanggal'), findsOneWidget);
  });

  testWidgets('Can delete a blackout period with confirmation dialog', (tester) async {
    final initialCount = MockDataStore.instance.blackoutPeriods.length;

    await tester.pumpWidget(buildTestableWidget(const ScheduleManagementScreen()));
    await tester.pumpAndSettle();

    // Go to Blackout tab via its unique icon
    final blackoutTabIcon = find.byIcon(Icons.block_outlined);
    await tester.tap(blackoutTabIcon);
    await tester.pumpAndSettle();

    // Tap 'Batalkan & Hapus' on the first visible card
    final cancelBtn = find.widgetWithText(TextButton, 'Batalkan & Hapus').first;
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    expect(find.text('Batalkan & Hapus Pemblokiran?'), findsOneWidget);

    final confirmBtn = find.widgetWithText(ElevatedButton, 'Batalkan & Hapus');
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    // Verify one blackout period was removed
    expect(
      MockDataStore.instance.blackoutPeriods.length,
      initialCount - 1,
    );
  });

  testWidgets('AdminDashboardScreen mounts ScheduleManagementScreen at tab index 2', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
    await tester.pumpAndSettle();

    // Tap tab 'Jadwal' on custom BottomNav
    final jadwalNav = find.text('Jadwal');
    expect(jadwalNav, findsOneWidget);

    await tester.tap(jadwalNav);
    await tester.pumpAndSettle();

    expect(find.text('Jadwal & Blokir Tanggal'), findsOneWidget);
    expect(find.byType(ScheduleManagementScreen), findsOneWidget);
  });
}
