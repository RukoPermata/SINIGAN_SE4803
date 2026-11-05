import 'package:flutter_test/flutter_test.dart';
import 'package:sini_gan/models/blackout_period.dart';
import 'package:sini_gan/models/booking.dart';
import 'package:sini_gan/models/regular_schedule.dart';
import 'package:sini_gan/models/room.dart';

void main() {
  test('Room JSON round-trip preserves all fields', () {
    const room = Room(
      id: 'r1',
      name: 'R1',
      building: 'Gedung Uji',
      floor: 2,
      capacity: 30,
      facilities: ['AC', 'Proyektor'],
      imageUrl: 'https://example.com/a.jpg',
      isActive: false,
      targetLayout: 'Diskusi',
      description: 'deskripsi',
      locationNotes: 'catatan',
    );

    final restored = Room.fromJson(room.toJson());

    expect(restored.id, 'r1');
    expect(restored.floor, 2);
    expect(restored.capacity, 30);
    expect(restored.facilities, ['AC', 'Proyektor']);
    expect(restored.isActive, isFalse);
    expect(restored.targetLayout, 'Diskusi');
    expect(restored.description, 'deskripsi');
  });

  test('Booking JSON round-trip preserves date, status and CV fields', () {
    final booking = Booking(
      id: 'b1',
      roomId: 'r1',
      roomName: 'R1',
      building: 'B',
      userName: 'Raka',
      userNim: '103022400032',
      date: DateTime(2026, 5, 1),
      startTime: '09:00',
      endTime: '10:00',
      purpose: 'tujuan',
      status: BookingStatus.rejected,
      rejectionReason: 'bentrok jadwal',
      predictedLayout: 'Diskusi',
      cvConfidence: 0.88,
      createdAt: DateTime(2026, 4, 30, 8, 15),
    );

    final restored = Booking.fromJson(booking.toJson());

    expect(restored.date, DateTime(2026, 5, 1));
    expect(restored.status, BookingStatus.rejected);
    expect(restored.rejectionReason, 'bentrok jadwal');
    expect(restored.predictedLayout, 'Diskusi');
    expect(restored.cvConfidence, 0.88);
    expect(restored.createdAt, DateTime(2026, 4, 30, 8, 15));
  });

  test('RegularSchedule JSON round-trip preserves day and active flag', () {
    const schedule = RegularSchedule(
      id: 's1',
      roomId: 'r1',
      roomName: 'R1',
      courseCode: 'SE4803',
      courseName: 'Pemrograman Aplikasi Bergerak',
      lecturerName: 'Dr. Budi',
      classGroup: 'SE-48-03',
      dayOfWeek: 3,
      startTime: '08:00',
      endTime: '09:00',
      semester: 'Genap 2024/2025',
      isActive: false,
    );

    final restored = RegularSchedule.fromJson(schedule.toJson());

    expect(restored.dayOfWeek, 3);
    expect(restored.dayName, 'Wednesday');
    expect(restored.isActive, isFalse);
    expect(restored.courseName, 'Pemrograman Aplikasi Bergerak');
  });

  test('BlackoutPeriod JSON round-trip preserves global scope and dates', () {
    final period = BlackoutPeriod(
      id: 'bo1',
      roomId: null,
      title: 'UTS',
      reason: 'Ujian terpusat',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 2),
      createdBy: 'BAA',
    );

    final restored = BlackoutPeriod.fromJson(period.toJson());

    expect(restored.appliesToAllRooms, isTrue);
    expect(restored.startDate, DateTime(2026, 1, 1));
    expect(restored.endDate, DateTime(2026, 1, 2));
  });
}
