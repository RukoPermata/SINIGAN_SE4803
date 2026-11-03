import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sini_gan/data/mock_data_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Reset the store to a clean set of mock data before each test by setting a
  // mismatched seed version, forcing MockDataStore.load() to reseed.
  setUp(() async {
    SharedPreferences.setMockInitialValues({'sg_seed_version': 999});
    await MockDataStore.instance.load();
  });

  test('load() seeds mock data when the stored version mismatches', () {
    expect(MockDataStore.instance.rooms, isNotEmpty);
    expect(MockDataStore.instance.bookings, isNotEmpty);
    expect(MockDataStore.instance.regularSchedules, isNotEmpty);
  });

  test('load() restores collections from stored JSON', () async {
    SharedPreferences.setMockInitialValues({
      'sg_seed_version': 1,
      'sg_rooms': jsonEncode([
        {
          'id': 'room-test',
          'name': 'Ruang Uji',
          'building': 'Gedung Uji',
          'floor': 4,
          'capacity': 25,
          'facilities': ['AC'],
          'imageUrl': '',
          'isActive': true,
          'targetLayout': 'Standar',
          'description': '',
          'locationNotes': '',
        }
      ]),
      'sg_bookings': jsonEncode([]),
      'sg_schedules': jsonEncode([]),
      'sg_blackouts': jsonEncode([]),
    });

    await MockDataStore.instance.load();

    expect(MockDataStore.instance.rooms.length, 1);
    expect(MockDataStore.instance.rooms.single.name, 'Ruang Uji');
    expect(MockDataStore.instance.rooms.single.floor, 4);
  });

  test('bookingsForUser filters bookings by NIM', () {
    final raka = MockDataStore.instance.bookingsForUser('103022400032');

    expect(raka, isNotEmpty);
    expect(raka.every((b) => b.userNim == '103022400032'), isTrue);
  });

  test('isSlotAvailable blocks class hours but allows free weekend slots', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.add(Duration(days: (8 - now.weekday) % 7));
    final sunday = monday.add(const Duration(days: 6));

    // TULT-0701 has a Monday 07:30-10:30 class, so 08:00-09:00 is taken.
    expect(
      MockDataStore.instance
          .isSlotAvailable('room-tult-0701', monday, 8 * 60, 9 * 60),
      isFalse,
    );

    // Sunday has no class or booking for that room.
    expect(
      MockDataStore.instance
          .isSlotAvailable('room-tult-0701', sunday, 8 * 60, 9 * 60),
      isTrue,
    );

    // Invalid range (end <= start) is never available.
    expect(
      MockDataStore.instance
          .isSlotAvailable('room-tult-0701', sunday, 9 * 60, 9 * 60),
      isFalse,
    );
  });

  test('metric getters reflect the current data', () {
    expect(MockDataStore.instance.activeRoomCount, greaterThan(0));
    expect(
      MockDataStore.instance.pendingCount,
      MockDataStore.instance.bookings
          .where((b) => b.status.value == 'pending')
          .length,
    );
  });
}
