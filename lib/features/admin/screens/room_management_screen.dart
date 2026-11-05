// PIC: Fityah - Room Management Screen - FR-10

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/room.dart';
import '../../auth/screens/login_screen.dart';

/// Layar utama pengelolaan master data ruangan kampus oleh Administrator (FR-10).
/// Mendukung pemantauan reaktif, pencarian, pemfilteran gedung/status,
/// pengubahan status aktif/nonaktif melalui switch toggle, serta penambahan
/// dan pengeditan ruangan baru ke MockDataStore.
class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'Semua'; // 'Semua', 'Aktif', 'Nonaktif'
  String _buildingFilter = 'Semua'; // 'Semua' atau nama gedung tertentu

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showRoomFormModal({Room? room}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RoomFormSheet(
        room: room,
        onSave: (savedRoom) {
          if (room != null) {
            MockDataStore.instance.updateRoom(savedRoom);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ruangan ${savedRoom.name} berhasil diperbarui.'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            MockDataStore.instance.addRoom(savedRoom);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ruangan ${savedRoom.name} berhasil ditambahkan.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _confirmDeleteRoom(Room room) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Ruangan?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${room.name}" (${room.building}) dari master data ruangan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () {
              MockDataStore.instance.deleteRoom(room.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ruangan ${room.name} berhasil dihapus.'),
                  backgroundColor: AppColors.textPrimary,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Ruangan'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Tambah Ruangan',
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showRoomFormModal(),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'room_management_fab',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tambah Ruangan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        onPressed: () => _showRoomFormModal(),
      ),
      body: ListenableBuilder(
        listenable: MockDataStore.instance,
        builder: (context, _) {
          final allRooms = MockDataStore.instance.rooms;

          // Hitung ringkasan statistik
          final totalRooms = allRooms.length;
          final activeRooms = allRooms.where((r) => r.isActive).length;
          final inactiveRooms = allRooms.where((r) => !r.isActive).length;

          // Ambil daftar gedung unik untuk filter dropdown
          final buildings = <String>{'Semua'};
          for (final r in allRooms) {
            buildings.add(r.building);
          }

          // Terapkan filter dan pencarian
          final filteredRooms = allRooms.where((r) {
            // Filter status
            if (_statusFilter == 'Aktif' && !r.isActive) return false;
            if (_statusFilter == 'Nonaktif' && r.isActive) return false;

            // Filter gedung
            if (_buildingFilter != 'Semua' && r.building != _buildingFilter) {
              return false;
            }

            // Filter kata kunci pencarian
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final matchName = r.name.toLowerCase().contains(query);
              final matchBuilding = r.building.toLowerCase().contains(query);
              final matchNotes = r.locationNotes.toLowerCase().contains(query);
              final matchFacilities = r.facilities.any(
                (f) => f.toLowerCase().contains(query),
              );
              if (!matchName && !matchBuilding && !matchNotes && !matchFacilities) {
                return false;
              }
            }

            return true;
          }).toList();

          return CustomScrollView(
            slivers: [
              // 1. Ringkasan Statistik
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _buildStatisticsOverview(
                    total: totalRooms,
                    active: activeRooms,
                    inactive: inactiveRooms,
                  ),
                ),
              ),

              // 2. Kontrol Pencarian & Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 10),
                      _buildFilterRow(buildings.toList()),
                    ],
                  ),
                ),
              ),

              // 3. Header Hasil / Informasi Jumlah
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Ruangan (${filteredRooms.length})',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                      ),
                      if (_searchQuery.isNotEmpty ||
                          _statusFilter != 'Semua' ||
                          _buildingFilter != 'Semua')
                        InkWell(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _statusFilter = 'Semua';
                              _buildingFilter = 'Semua';
                            });
                          },
                          child: const Text(
                            'Reset Filter',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 4. Daftar Kartu Ruangan atau Kondisi Kosong
              if (filteredRooms.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final room = filteredRooms[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildRoomCard(room),
                        );
                      },
                      childCount: filteredRooms.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Ringkasan statistik 3 metrik utama: Total, Aktif, dan Nonaktif.
  Widget _buildStatisticsOverview({
    required int total,
    required int active,
    required int inactive,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Total Ruang',
            count: total,
            icon: Icons.meeting_room_outlined,
            bgColor: AppColors.lavender.withValues(alpha: 0.45),
            accentColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            label: 'Aktif',
            count: active,
            icon: Icons.check_circle_outline,
            bgColor: AppColors.successLight,
            accentColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            label: 'Nonaktif',
            count: inactive,
            icon: Icons.cancel_outlined,
            bgColor: AppColors.errorLight,
            accentColor: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required int count,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              Icon(icon, size: 20, color: accentColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Kolom pencarian ruangan
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (val) {
        setState(() {
          _searchQuery = val.trim();
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari nama ruangan, gedung, fasilitas...',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  /// Filter baris: status chips dan building selector dropdown
  Widget _buildFilterRow(List<String> availableBuildings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatusChip('Semua'),
              const SizedBox(width: 8),
              _buildStatusChip('Aktif'),
              const SizedBox(width: 8),
              _buildStatusChip('Nonaktif'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Gedung selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: availableBuildings.contains(_buildingFilter)
                  ? _buildingFilter
                  : 'Semua',
              isExpanded: true,
              icon: const Icon(Icons.apartment, size: 20, color: AppColors.primary),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              items: availableBuildings.map((building) {
                return DropdownMenuItem<String>(
                  value: building,
                  child: Text(
                    building == 'Semua' ? '🏢 Semua Gedung Kampus' : '🏢 $building',
                  ),
                );
              }).toList(),
              onChanged: (newBuilding) {
                if (newBuilding != null) {
                  setState(() {
                    _buildingFilter = newBuilding;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _statusFilter == status;
    Color activeBg;
    Color activeText;

    if (status == 'Aktif') {
      activeBg = AppColors.successLight;
      activeText = AppColors.success;
    } else if (status == 'Nonaktif') {
      activeBg = AppColors.errorLight;
      activeText = AppColors.error;
    } else {
      activeBg = AppColors.lavender;
      activeText = AppColors.primary;
    }

    return ChoiceChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _statusFilter = status;
          });
        }
      },
      selectedColor: activeBg,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? activeText : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? activeText.withValues(alpha: 0.5) : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  /// Kartu data master ruangan
  Widget _buildRoomCard(Room room) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Foto mini, Identitas Ruangan, dan Switch Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail foto
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: AppColors.lavender,
                    child: room.imageUrl.isNotEmpty
                        ? Image.network(
                            room.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.meeting_room_outlined,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          )
                        : const Icon(
                            Icons.meeting_room_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nama ruangan, gedung, dan lantai
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.name,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          StatusBadge(status: room.isActive ? 'active' : 'inactive'),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${room.building} • Lantai ${room.floor}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kapasitas: ${room.capacity} org',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'Layout: ${room.targetLayout}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Catatan Lokasi (jika ada)
            if (room.locationNotes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      room.locationNotes,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Fasilitas Chip
            if (room.facilities.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: room.facilities.take(4).map((f) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      f,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList()
                  ..addAll(
                    room.facilities.length > 4
                        ? [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lavender.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${room.facilities.length - 4}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ]
                        : [],
                  ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 8),

            // Baris Aksi Bawah: Switch Toggle & Tombol Edit/Hapus
            Row(
              children: [
                // Switch Status Aktif/Nonaktif
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch.adaptive(
                      value: room.isActive,
                      activeThumbColor: AppColors.success,
                      activeTrackColor: AppColors.successLight,
                      inactiveThumbColor: AppColors.error,
                      inactiveTrackColor: AppColors.errorLight,
                      onChanged: (val) {
                        MockDataStore.instance.toggleRoomStatus(room.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              val
                                  ? 'Ruangan ${room.name} kini berstatus Aktif (dapat dipinjam).'
                                  : 'Ruangan ${room.name} dinonaktifkan dari peminjaman.',
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor:
                                val ? AppColors.success : AppColors.error,
                          ),
                        );
                      },
                    ),
                    Text(
                      room.isActive ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: room.isActive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Tombol Edit Ruangan
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(0, 32),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.primary),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  onPressed: () => _showRoomFormModal(room: room),
                ),
                const SizedBox(width: 8),
                // Tombol Hapus Ruangan
                IconButton(
                  tooltip: 'Hapus Ruangan',
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  onPressed: () => _confirmDeleteRoom(room),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Tampilan jika hasil filter/pencarian kosong
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Ruangan Tidak Ditemukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tidak ada ruangan yang cocok dengan kata kunci atau filter yang Anda pilih.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(140, 40),
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _statusFilter = 'Semua';
                  _buildingFilter = 'Semua';
                });
              },
              child: const Text('Reset Pencarian'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal Form Tambah atau Edit Ruangan Kampus
class _RoomFormSheet extends StatefulWidget {
  const _RoomFormSheet({
    required this.room,
    required this.onSave,
  });

  final Room? room;
  final ValueChanged<Room> onSave;

  @override
  State<_RoomFormSheet> createState() => _RoomFormSheetState();
}

class _RoomFormSheetState extends State<_RoomFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _buildingController;
  late TextEditingController _floorController;
  late TextEditingController _capacityController;
  late TextEditingController _facilitiesController;
  late TextEditingController _imageUrlController;
  late TextEditingController _locationNotesController;
  late TextEditingController _descriptionController;

  late String _targetLayout;
  late bool _isActive;

  final List<String> _layoutOptions = const ['Standar', 'Ujian', 'Diskusi', 'Seminar'];
  final List<String> _commonBuildings = const [
    'Gedung TULT',
    'Gedung Tokong Nanas (KU3)',
    'Gedung Panambulai (FIF)',
    'Gedung Student Center',
    'Gedung Kuliah Bersama (GKB)',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _nameController = TextEditingController(text: r?.name ?? '');
    _buildingController = TextEditingController(text: r?.building ?? _commonBuildings.first);
    _floorController = TextEditingController(text: r?.floor.toString() ?? '1');
    _capacityController = TextEditingController(text: r?.capacity.toString() ?? '40');
    _facilitiesController = TextEditingController(text: r?.facilities.join(', ') ?? 'Proyektor HD, AC, Papan Tulis, Wi-Fi Eduroam');
    _imageUrlController = TextEditingController(
      text: r?.imageUrl ??
          'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=800&q=80',
    );
    _locationNotesController = TextEditingController(text: r?.locationNotes ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');
    _targetLayout = r?.targetLayout ?? 'Standar';
    _isActive = r?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _capacityController.dispose();
    _facilitiesController.dispose();
    _imageUrlController.dispose();
    _locationNotesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final facilities = _facilitiesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final room = Room(
      id: widget.room?.id ?? 'room-${_nameController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')}-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      building: _buildingController.text.trim(),
      floor: int.tryParse(_floorController.text.trim()) ?? 1,
      capacity: int.tryParse(_capacityController.text.trim()) ?? 40,
      facilities: facilities.isNotEmpty ? facilities : ['AC', 'Papan Tulis'],
      imageUrl: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=800&q=80',
      isActive: _isActive,
      targetLayout: _targetLayout,
      description: _descriptionController.text.trim(),
      locationNotes: _locationNotesController.text.trim(),
    );

    widget.onSave(room);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.room != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Judul Modal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Ruangan Kampus' : 'Tambah Ruangan Baru',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isEdit
                      ? 'Perbarui detail data master ruangan dan status keaktifan.'
                      : 'Lengkapi data master ruangan untuk dimasukkan ke katalog kampus.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Kode/Nama Ruangan
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama / Kode Ruangan *',
                    hintText: 'Contoh: TULT-0801 atau Lab Multimedia 2',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama ruangan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),

                // Gedung (Pilihan Cepat & Kustomisasi)
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _commonBuildings.contains(_buildingController.text)
                      ? _buildingController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Gedung Kampus',
                  ),
                  items: _commonBuildings.map((b) {
                    return DropdownMenuItem<String>(
                      value: b,
                      child: Text(b, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _buildingController.text = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _buildingController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Gedung *',
                    hintText: 'Atau sesuaikan nama gedung...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Gedung wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),

                // Lantai & Kapasitas
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _floorController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Lantai *',
                          hintText: 'Misal: 7',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                          if (int.tryParse(v.trim()) == null) return 'Harus angka';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kapasitas (Orang) *',
                          hintText: 'Misal: 40',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                          if (int.tryParse(v.trim()) == null) return 'Harus angka';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tata Letak Target Ruangan
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _targetLayout,
                  decoration: const InputDecoration(
                    labelText: 'Tata Letak Standar (AI Verifikasi)',
                  ),
                  items: _layoutOptions.map((layout) {
                    return DropdownMenuItem<String>(
                      value: layout,
                      child: Text(layout),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _targetLayout = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Fasilitas
                TextFormField(
                  controller: _facilitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Fasilitas (Pisahkan dengan koma)',
                    hintText: 'AC, Proyektor, Papan Tulis, Wi-Fi',
                  ),
                ),
                const SizedBox(height: 14),

                // Catatan Posisi / Lokasi
                TextFormField(
                  controller: _locationNotesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan Lokasi',
                    hintText: 'Contoh: Sayap Barat, dekat tangga darurat lantai 7',
                  ),
                ),
                const SizedBox(height: 14),

                // Deskripsi Ruangan
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Singkat',
                    hintText: 'Kesesuaian fungsi ruangan (kelas teori, lab, dsb)',
                  ),
                ),
                const SizedBox(height: 14),

                // URL Foto
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Foto Ruangan',
                    hintText: 'https://...',
                  ),
                ),
                const SizedBox(height: 14),

                // Toggle Keaktifan Ruangan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Keaktifan Ruangan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _isActive
                                ? 'Ruangan dapat dicari dan dipinjam mahasiswa'
                                : 'Ruangan dinonaktifkan sementara',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isActive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isActive,
                        activeThumbColor: AppColors.success,
                        activeTrackColor: AppColors.successLight,
                        onChanged: (val) {
                          setState(() {
                            _isActive = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambahkan Ruangan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
