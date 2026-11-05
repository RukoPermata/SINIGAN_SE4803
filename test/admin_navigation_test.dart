import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sini_gan/app.dart';
import 'package:sini_gan/features/admin/screens/admin_dashboard_screen.dart';
import 'package:sini_gan/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('Masuk sebagai Admin and navigating back works without exception', (tester) async {
    await tester.pumpWidget(const SiniGanApp());
    expect(find.byType(LoginScreen), findsOneWidget);

    // Tap "Masuk sebagai Admin".
    final adminDemoBtn = find.text('Masuk sebagai Admin');
    expect(adminDemoBtn, findsOneWidget);
    await tester.ensureVisible(adminDemoBtn);
    await tester.tap(adminDemoBtn);
    await tester.pumpAndSettle();

    // Verify AdminDashboardScreen is displayed.
    expect(find.byType(AdminDashboardScreen), findsOneWidget);

    // Switch to the 'Jadwal' tab.
    final jadwalTab = find.text('Jadwal');
    expect(jadwalTab, findsOneWidget);
    await tester.tap(jadwalTab);
    await tester.pumpAndSettle();
    expect(find.text('Jadwal & Blokir Tanggal'), findsOneWidget);

    // Trigger back (system pop / back navigation):
    // 1st back from a non-first tab returns to tab 0.
    final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
    await widgetsAppState.didPopRoute();
    await tester.pumpAndSettle();

    // 2nd back from tab 0 leaves the shell back to LoginScreen.
    await widgetsAppState.didPopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
