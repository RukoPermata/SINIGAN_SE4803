import '../models/blackout_period.dart';

/// Data tiruan (mock data) periode blackout / pemblokiran ruangan kampus untuk demonstrasi UTS.
final List<BlackoutPeriod> mockBlackoutPeriods = [
  BlackoutPeriod(
    id: 'bo-001',
    roomId: null, // Berlaku global untuk semua ruangan
    roomName: 'All Campus Rooms',
    title: 'Midterm Exam Week (Even Semester)',
    reason: 'All classrooms and laboratories are allocated for centralized written exams.',
    startDate: DateTime(2025, 4, 14, 0, 0),
    endDate: DateTime(2025, 4, 25, 23, 59),
    isActive: true,
    createdBy: 'Academic Administration Bureau (BAA)',
  ),
  BlackoutPeriod(
    id: 'bo-002',
    roomId: 'room-fif-lab-multi',
    roomName: 'Lab Multimedia FIF',
    title: 'Network Maintenance & Workstation Upgrade',
    reason: 'Installing new GPUs and upgrading the multimedia lab server storage for industry certification.',
    startDate: DateTime(2025, 3, 20, 8, 0),
    endDate: DateTime(2025, 3, 22, 17, 0),
    isActive: true,
    createdBy: 'FIF Laboratory',
  ),
  BlackoutPeriod(
    id: 'bo-003',
    roomId: 'room-aula-ku3',
    roomName: 'Aula Tokong Nanas',
    title: 'Rehearsal & Open Graduation Ceremony (Wave II)',
    reason: 'Room preparation for the university graduation protocol.',
    startDate: DateTime(2025, 5, 2, 7, 0),
    endDate: DateTime(2025, 5, 3, 22, 0),
    isActive: true,
    createdBy: 'Logistics & Facilities Division',
  ),
];
