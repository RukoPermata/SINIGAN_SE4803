import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sini_gan/app.dart';
import 'package:sini_gan/features/student/screens/room_catalog_screen.dart';
import 'package:sini_gan/features/student/screens/room_detail_screen.dart';
import 'package:sini_gan/features/student/screens/student_home_screen.dart';

void main() {
  testWidgets('Student can log in, open the catalog, and open a room detail',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SiniGanApp());
    await tester.pumpAndSettle();

    // Login as student.
    await tester.tap(find.text('Masuk sebagai Mahasiswa'));
    await tester.pumpAndSettle();
    expect(find.byType(StudentHomeScreen), findsOneWidget);

    // Switch to the Explore (catalog) tab.
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.byType(RoomCatalogScreen), findsOneWidget);
    expect(find.text('Room Catalog'), findsOneWidget);

    // Open a room detail.
    await tester.tap(find.text('TULT-0701').first);
    await tester.pumpAndSettle();
    expect(find.byType(RoomDetailScreen), findsOneWidget);
  });

  testWidgets('Room catalog search filters the room list', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SiniGanApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk sebagai Mahasiswa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Aula');
    await tester.pumpAndSettle();

    expect(find.text('Aula Tokong Nanas'), findsOneWidget);
    expect(find.text('TULT-0701'), findsNothing);
  });
}
