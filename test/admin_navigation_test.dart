import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sini_gan/app.dart';
import 'package:sini_gan/features/admin/screens/admin_dashboard_screen.dart';
import 'package:sini_gan/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('Masuk sebagai Admin and navigating back works without exception', (tester) async {
    await tester.pumpWidget(const SiniGanApp());
    expect(find.byType(LoginScreen), findsOneWidget);

    // Tap "Masuk sebagai Admin"
    final adminDemoBtn = find.text('Masuk sebagai Admin');
    expect(adminDemoBtn, findsOneWidget);
    await tester.ensureVisible(adminDemoBtn);
    await tester.tap(adminDemoBtn);
    await tester.pumpAndSettle();

    // Verify AdminDashboardScreen is displayed
    expect(find.byType(AdminDashboardScreen), findsOneWidget);

    // Switch to tab index 1 (Room Management)
    final roomNavIcon = find.byIcon(Icons.meeting_room_outlined);
    expect(roomNavIcon, findsOneWidget);
    await tester.tap(roomNavIcon);
    await tester.pumpAndSettle();

    // Switch to tab index 2 (Schedule Management)
    final scheduleTab = find.text('Jadwal');
    expect(scheduleTab, findsOneWidget);
    await tester.tap(scheduleTab);
    await tester.pumpAndSettle();

    // Trigger back (system pop / back navigation)
    // 1st back from tab index 2 returns to tab index 0
    final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
    await widgetsAppState.didPopRoute();
    await tester.pumpAndSettle();

    // 2nd back from tab index 0 returns to LoginScreen
    await widgetsAppState.didPopRoute();
    await tester.pumpAndSettle();

    // Should now be back at LoginScreen without any exception
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
