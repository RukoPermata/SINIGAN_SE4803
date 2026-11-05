import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sini_gan/core/theme/app_theme.dart';
import 'package:sini_gan/data/mock_data_store.dart';
import 'package:sini_gan/features/admin/screens/admin_dashboard_screen.dart';
import 'package:sini_gan/features/admin/screens/room_management_screen.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: child,
    );
  }

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('RoomManagementScreen renders summary stats, rooms list, and search bar', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget(const RoomManagementScreen()));
    await tester.pump();

    // Verify AppBar title
    expect(find.text('Manajemen Ruangan'), findsOneWidget);

    // Verify Statistics overview
    expect(find.text('Total Ruang'), findsOneWidget);
    expect(find.text('Aktif'), findsAtLeastNWidgets(1));
    expect(find.text('Nonaktif'), findsAtLeastNWidgets(1));

    // Verify rooms from mock data are displayed
    expect(find.text('TULT-0701'), findsOneWidget);

    // Verify search bar is present
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Toggling switch changes room status in MockDataStore', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget(const RoomManagementScreen()));
    await tester.pump();

    final initialRoom = MockDataStore.instance.getRoomById('room-tult-0701');
    expect(initialRoom, isNotNull);
    final initialStatus = initialRoom!.isActive;

    // Find switches
    final switches = find.byType(Switch);
    expect(switches, findsWidgets);

    await tester.tap(switches.first);
    await tester.pump();

    final updatedRoom = MockDataStore.instance.getRoomById('room-tult-0701');
    expect(updatedRoom!.isActive, !initialStatus);

    // Toggle back to original state
    await tester.tap(switches.first);
    await tester.pump();
    expect(MockDataStore.instance.getRoomById('room-tult-0701')!.isActive, initialStatus);
  });

  testWidgets('Search query filters rooms list correctly', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget(const RoomManagementScreen()));
    await tester.pump();

    // Search for 'Aula Tokong'
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Aula Tokong');
    await tester.pump();

    expect(find.text('Aula Tokong Nanas'), findsOneWidget);
    expect(find.text('TULT-0701'), findsNothing);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.text('TULT-0701'), findsOneWidget);
  });

  testWidgets('Filter by status works properly', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget(const RoomManagementScreen()));
    await tester.pump();

    // Tap 'Nonaktif' chip
    final nonaktifChip = find.widgetWithText(ChoiceChip, 'Nonaktif');
    await tester.tap(nonaktifChip);
    await tester.pump();

    // All default mock rooms are active, so nonaktif should show empty state or 0
    final emptyTitle = find.text('Ruangan Tidak Ditemukan');
    expect(emptyTitle, findsOneWidget);

    // Tap 'Semua' chip
    final semuaChip = find.widgetWithText(ChoiceChip, 'Semua');
    await tester.tap(semuaChip);
    await tester.pump();

    expect(find.text('TULT-0701'), findsOneWidget);
  });

  testWidgets('Can open Add Room modal and submit new room', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget(const RoomManagementScreen()));
    await tester.pump();

    // Open add room modal via AppBar action
    final addIcon = find.byIcon(Icons.add_circle_outline);
    await tester.tap(addIcon);
    await tester.pumpAndSettle();

    expect(find.text('Tambah Ruangan Baru'), findsOneWidget);

    // Fill form
    final nameField = find.widgetWithText(TextFormField, 'Nama / Kode Ruangan *');
    await tester.enterText(nameField, 'KU3.05.01');

    final submitButton = find.widgetWithText(ElevatedButton, 'Tambahkan Ruangan');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Check MockDataStore has the new room
    expect(MockDataStore.instance.rooms.any((r) => r.name == 'KU3.05.01'), isTrue);

    // Verify it appears in search results
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'KU3.05.01');
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(Card), matching: find.text('KU3.05.01')),
      findsOneWidget,
    );
  });

  testWidgets('AdminDashboardScreen mounts RoomManagementScreen on tab index 1', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget(const AdminDashboardScreen()));
    await tester.pump();

    // Tap tab 'Ruangan'
    final ruanganTab = find.text('Ruangan');
    expect(ruanganTab, findsOneWidget);

    await tester.tap(ruanganTab);
    await tester.pump();

    expect(find.byType(RoomManagementScreen), findsOneWidget);
    expect(find.text('Manajemen Ruangan'), findsOneWidget);
  });
}
