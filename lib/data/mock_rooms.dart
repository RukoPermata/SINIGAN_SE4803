import '../models/room.dart';

/// Data tiruan (mock data) daftar ruangan kampus untuk keperluan demonstrasi UTS.
final List<Room> mockRooms = [
  const Room(
    id: 'room-tult-0701',
    name: 'TULT-0701',
    building: 'TULT Building',
    floor: 7,
    capacity: 40,
    facilities: ['HD Projector', 'AC', 'Whiteboard', 'Wi-Fi Eduroam', 'Power Outlet per Desk'],
    imageUrl:
        'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standard',
    description:
        'A regular air-conditioned theory classroom with good natural light, suitable for lectures and group study.',
    locationNotes: 'West Wing, near the floor 7 emergency stairs',
  ),
  const Room(
    id: 'room-tult-1102',
    name: 'TULT-1102',
    building: 'TULT Building',
    floor: 11,
    capacity: 45,
    facilities: ['Dual Projector', 'Sound System', 'AC', 'Whiteboard', 'Wi-Fi Eduroam'],
    imageUrl:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standard',
    description:
        'A mid-capacity classroom with an integrated audio system, ideal for large project presentations and workshops.',
    locationNotes: 'North Wing, right in front of the main elevator',
  ),
  const Room(
    id: 'room-ku3-0301',
    name: 'KU3.03.01',
    building: 'Tokong Nanas Building (KU3)',
    floor: 3,
    capacity: 50,
    facilities: ['65-inch Smart TV', 'Projector', 'AC', 'Glass Whiteboard', 'Wi-Fi Eduroam'],
    imageUrl:
        'https://images.unsplash.com/photo-1524178232363-1fb2b075b655?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standard',
    description:
        'An interactive lecture room with a Smart TV and a modern glass whiteboard for easy material visualization.',
    locationNotes: 'Floor 3 central corridor',
  ),
  const Room(
    id: 'room-fif-lab-multi',
    name: 'Lab Multimedia FIF',
    building: 'Panambulai Building (FIF)',
    floor: 2,
    capacity: 35,
    facilities: ['35 PC Workstations', 'Gigabit LAN', 'AC', 'Projector', 'Studio Headsets'],
    imageUrl:
        'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standard',
    description:
        'A high-spec computer laboratory for graphics, game development, and image processing labs.',
    locationNotes: 'Panambulai Building floor 2, next to the AI Lab',
  ),
  const Room(
    id: 'room-aula-ku3',
    name: 'Aula Tokong Nanas',
    building: 'Tokong Nanas Building (KU3)',
    floor: 1,
    capacity: 120,
    facilities: ['Main Stage', 'Premium Sound System', 'Videotron / Giant Projector', 'Central AC', 'Wireless Mic'],
    imageUrl:
        'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Standard',
    description:
        'A large multi-purpose hall for national seminars, guest lectures, student organization meetings, and graduation sessions.',
    locationNotes: 'Main lobby of the Tokong Nanas Building, floor 1',
  ),
  const Room(
    id: 'room-sc-hima',
    name: 'Ruang Rapat HIMA RPL',
    building: 'Student Center Building',
    floor: 2,
    capacity: 20,
    facilities: ['Round Meeting Table', 'Smart Monitor', 'AC', 'Whiteboard', 'Water Dispenser'],
    imageUrl:
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80',
    isActive: true,
    targetLayout: 'Discussion',
    description:
        'A collaborative meeting room with a round-table layout for committee coordination, student council meetings, and team consultations.',
    locationNotes: 'SC Building floor 2, student council secretariat block',
  ),
];
