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
    expect(find.text('Schedule & Date Blocks'), findsOneWidget);

    // Verify Tab headers
    expect(find.byType(Tab), findsNWidgets(2));

    // Verify day filter chips
    expect(find.widgetWithText(FilterChip, 'All Days'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Monday'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Tuesday'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Wednesday'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Thursday'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Friday'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Saturday'), findsOneWidget);

    // Verify schedule items from mock data
    expect(find.text('Mobile Application Programming'), findsOneWidget);
    expect(find.text('SE4803'), findsOneWidget);
    expect(find.text('Dr. Budi Santoso, M.Kom.'), findsOneWidget);

    // Verify FloatingActionButton
    expect(find.text('Add Schedule'), findsOneWidget);
  });

  testWidgets('Filtering regular schedules by day works properly', (tester) async {
    await tester.pumpWidget(buildTestableWidget(const ScheduleManagementScreen()));
    await tester.pumpAndSettle();

    // Tap on 'Tuesday' filter chip
    await tester.tap(find.widgetWithText(FilterChip, 'Tuesday'));
    await tester.pumpAndSettle();

    // Should show schedule on Tuesday: Konstruksi & Pengujian Perangkat Lunak
    expect(find.text('Software Construction & Testing'), findsOneWidget);
    // Should NOT show schedule on Monday: Pemrograman Aplikasi Bergerak
    expect(find.text('Mobile Application Programming'), findsNothing);

    // Tap on 'Reset Filters'
    await tester.tap(find.text('Reset Filters'));
    await tester.pumpAndSettle();

    expect(find.text('Mobile Application Programming'), findsOneWidget);
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
      semester: 'Even Semester 2024/2025',
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
    expect(find.text('Delete Class Schedule?'), findsOneWidget);

    // Tap 'Delete Schedule'
    final confirmButton = find.widgetWithText(ElevatedButton, 'Delete Schedule');
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
    expect(find.textContaining('Blackout periods automatically disable'), findsOneWidget);
    expect(find.textContaining('All ('), findsOneWidget);
    expect(find.textContaining('Active ('), findsOneWidget);
    expect(find.textContaining('Inactive ('), findsOneWidget);

    // Verify mock blackout items
    expect(find.text('Midterm Exam Week (Even Semester)'), findsOneWidget);
    expect(find.text('Network Maintenance & Workstation Upgrade'), findsOneWidget);

    // Verify FAB changed to 'Block Dates'
    expect(find.widgetWithText(FloatingActionButton, 'Block Dates'), findsOneWidget);
  });

  testWidgets('Can delete a blackout period with confirmation dialog', (tester) async {
    final initialCount = MockDataStore.instance.blackoutPeriods.length;

    await tester.pumpWidget(buildTestableWidget(const ScheduleManagementScreen()));
    await tester.pumpAndSettle();

    // Go to Blackout tab via its unique icon
    final blackoutTabIcon = find.byIcon(Icons.block_outlined);
    await tester.tap(blackoutTabIcon);
    await tester.pumpAndSettle();

    // Tap 'Cancel & Delete' on the first visible card
    final cancelBtn = find.widgetWithText(TextButton, 'Cancel & Delete').first;
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    expect(find.text('Cancel & Delete Blackout?'), findsOneWidget);

    final confirmBtn = find.widgetWithText(ElevatedButton, 'Cancel & Delete');
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
    final jadwalNav = find.text('Schedule');
    expect(jadwalNav, findsOneWidget);

    await tester.tap(jadwalNav);
    await tester.pumpAndSettle();

    expect(find.text('Schedule & Date Blocks'), findsOneWidget);
    expect(find.byType(ScheduleManagementScreen), findsOneWidget);
  });
}
