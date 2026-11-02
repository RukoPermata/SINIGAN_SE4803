import '../models/regular_schedule.dart';

/// Data tiruan (mock data) jadwal perkuliahan reguler mingguan kampus untuk demonstrasi UTS.
final List<RegularSchedule> mockRegularSchedules = [
  const RegularSchedule(
    id: 'sched-001',
    roomId: 'room-tult-0701',
    roomName: 'TULT-0701',
    courseCode: 'SE4803',
    courseName: 'Pemrograman Aplikasi Bergerak',
    lecturerName: 'Dr. Budi Santoso, M.Kom.',
    classGroup: 'SE-48-03',
    dayOfWeek: 1, // Senin
    startTime: '07:30',
    endTime: '10:30',
    semester: 'Genap 2024/2025',
    isActive: true,
  ),
  const RegularSchedule(
    id: 'sched-002',
    roomId: 'room-tult-1102',
    roomName: 'TULT-1102',
    courseCode: 'SE4802',
    courseName: 'Konstruksi & Pengujian Perangkat Lunak',
    lecturerName: 'Siti Nurhaliza, S.T., M.T.',
    classGroup: 'SE-48-01',
    dayOfWeek: 2, // Selasa
    startTime: '09:30',
    endTime: '12:30',
    semester: 'Genap 2024/2025',
    isActive: true,
  ),
  const RegularSchedule(
    id: 'sched-003',
    roomId: 'room-fif-lab-multi',
    roomName: 'Lab Multimedia FIF',
    courseCode: 'MM3204',
    courseName: 'Desain Grafika & Multimedia',
    lecturerName: 'Ahmad Fauzi, M.Ds.',
    classGroup: 'DS-47-02',
    dayOfWeek: 3, // Rabu
    startTime: '08:30',
    endTime: '11:30',
    semester: 'Genap 2024/2025',
    isActive: true,
  ),
  const RegularSchedule(
    id: 'sched-004',
    roomId: 'room-ku3-0301',
    roomName: 'KU3.03.01',
    courseCode: 'CS3101',
    courseName: 'Sistem Manajemen Basis Data Terdistribusi',
    lecturerName: 'Hendra Gunawan, Ph.D.',
    classGroup: 'IF-47-01',
    dayOfWeek: 4, // Kamis
    startTime: '13:30',
    endTime: '16:30',
    semester: 'Genap 2024/2025',
    isActive: true,
  ),
  const RegularSchedule(
    id: 'sched-005',
    roomId: 'room-aula-ku3',
    roomName: 'Aula Tokong Nanas',
    courseCode: 'KU1001',
    courseName: 'Kuliah Umum Kewirausahaan & Etika Profesi',
    lecturerName: 'Tim Dosen Pengampu Kewirausahaan',
    classGroup: 'GABUNGAN-SE-IF',
    dayOfWeek: 5, // Jumat
    startTime: '08:00',
    endTime: '10:30',
    semester: 'Genap 2024/2025',
    isActive: true,
  ),
];
