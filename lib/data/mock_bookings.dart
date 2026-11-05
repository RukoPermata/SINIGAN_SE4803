import '../models/booking.dart';

/// Data tiruan (mock data) daftar peminjaman untuk demonstrasi antarmuka UTS.
final List<Booking> mockBookings = [
  Booking(
    id: 'book-101',
    roomId: 'room-tult-0701',
    roomName: 'TULT-0701',
    building: 'TULT Building',
    userName: 'Raka Pratama',
    userNim: '103022400032',
    date: DateTime.now().add(const Duration(days: 1)),
    startTime: '09:00',
    endTime: '12:00',
    purpose: 'Additional Tutorial for Object-Oriented Programming',
    status: BookingStatus.pending,
    beforePhotoUrl:
        'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=600&q=80',
    afterPhotoUrl:
        'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=600&q=80',
    predictedLayout: 'Standard',
    cvConfidence: 0.92,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  Booking(
    id: 'book-102',
    roomId: 'room-ku3-0301',
    roomName: 'KU3.03.01',
    building: 'Tokong Nanas Building (KU3)',
    userName: 'Siti Nurhaliza',
    userNim: '103022400085',
    date: DateTime.now().add(const Duration(days: 2)),
    startTime: '13:30',
    endTime: '15:30',
    purpose: 'HIMA RPL 2026 Information & Communication Division Work Meeting',
    status: BookingStatus.approved,
    beforePhotoUrl:
        'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?auto=format&fit=crop&w=600&q=80',
    afterPhotoUrl:
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=600&q=80',
    predictedLayout: 'Discussion',
    cvConfidence: 0.88,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Booking(
    id: 'book-103',
    roomId: 'room-fif-lab-multi',
    roomName: 'Lab Multimedia FIF',
    building: 'Panambulai Building (FIF)',
    userName: 'Fajar Hidayat',
    userNim: '103022400096',
    date: DateTime.now().subtract(const Duration(days: 1)),
    startTime: '10:00',
    endTime: '12:30',
    purpose: 'Joint Practice for the Game Development Expo',
    status: BookingStatus.rejected,
    rejectionReason:
        'The room is being used for a regular Computer Graphics lab (schedule conflict).',
    beforePhotoUrl:
        'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=600&q=80',
    afterPhotoUrl:
        'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=600&q=80',
    predictedLayout: 'Standard',
    cvConfidence: 0.95,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  Booking(
    id: 'book-104',
    roomId: 'room-tult-1102',
    roomName: 'TULT-1102',
    building: 'TULT Building',
    userName: 'Raka Pratama',
    userNim: '103022400032',
    date: DateTime.now().subtract(const Duration(days: 2)),
    startTime: '14:00',
    endTime: '16:00',
    purpose: 'Dress Rehearsal for the National Software Engineering Seminar',
    status: BookingStatus.approved,
    beforePhotoUrl:
        'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=600&q=80',
    afterPhotoUrl:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=600&q=80',
    predictedLayout: 'Standard',
    cvConfidence: 0.94,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
