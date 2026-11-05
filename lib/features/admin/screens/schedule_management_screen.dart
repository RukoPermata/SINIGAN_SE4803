// PIC: Fityah - Schedule Management Screen - FR-11, FR-12

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/mock_data_store.dart';
import '../../../models/blackout_period.dart';
import '../../../models/regular_schedule.dart';
import '../../../models/room.dart';
import '../../auth/screens/login_screen.dart';

/// Layar Pengelolaan Jadwal Perkuliahan Reguler (FR-11)
/// dan Pemblokiran Tanggal Nonaktif / Blackout Dates (FR-12).
class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Filter Tab 1: Jadwal Reguler
  int? _selectedDayFilter; // null = Semua Hari, 1 = Senin, ..., 6 = Sabtu
  String? _selectedRoomFilter; // null = Semua Ruangan

  // Filter Tab 2: Blackout Dates
  String _blackoutFilter = 'all'; // 'all', 'active', 'inactive'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out of the admin account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MockDataStore>(
      init: MockDataStore.instance,
      builder: (_) {
        final regularSchedules = MockDataStore.instance.regularSchedules;
        final blackoutPeriods = MockDataStore.instance.blackoutPeriods;
        final rooms = MockDataStore.instance.rooms;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Schedule & Date Blocks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Manage class schedules & room blackout dates',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: AppColors.textSecondary),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(Icons.calendar_today_outlined, size: 20),
                  text: 'Class Schedules (${regularSchedules.length})',
                ),
                Tab(
                  icon: const Icon(Icons.block_outlined, size: 20),
                  text: 'Date Blocks (${blackoutPeriods.length})',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildRegularSchedulesTab(regularSchedules, rooms),
              _buildBlackoutPeriodsTab(blackoutPeriods, rooms),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'schedule_management_fab',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: Icon(
              _tabController.index == 0 ? Icons.add : Icons.add_moderator,
              size: 20,
            ),
            label: Text(
              _tabController.index == 0 ? 'Add Schedule' : 'Block Dates',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              if (_tabController.index == 0) {
                _showAddScheduleDialog(rooms);
              } else {
                _showAddBlackoutDialog(rooms);
              }
            },
          ),
        );
      },
    );
  }

  // ===========================================================================
  // TAB 1: JADWAL PERKULIAHAN REGULER (FR-11)
  // ===========================================================================

  Widget _buildRegularSchedulesTab(List<RegularSchedule> schedules, List<Room> rooms) {
    // Terapkan filter hari & ruangan
    final filteredSchedules = schedules.where((s) {
      if (_selectedDayFilter != null && s.dayOfWeek != _selectedDayFilter) {
        return false;
      }
      if (_selectedRoomFilter != null && s.roomId != _selectedRoomFilter) {
        return false;
      }
      return true;
    }).toList();

    // Urutkan berdasarkan hari (Senin -> Sabtu), lalu jam mulai
    filteredSchedules.sort((a, b) {
      final dayCmp = a.dayOfWeek.compareTo(b.dayOfWeek);
      if (dayCmp != 0) return dayCmp;
      return a.startTime.compareTo(b.startTime);
    });

    final days = [
      {'name': 'All Days', 'value': null},
      {'name': 'Monday', 'value': 1},
      {'name': 'Tuesday', 'value': 2},
      {'name': 'Wednesday', 'value': 3},
      {'name': 'Thursday', 'value': 4},
      {'name': 'Friday', 'value': 5},
      {'name': 'Saturday', 'value': 6},
    ];

    return Column(
      children: [
        // Filter Section
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown Filter Ruangan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _selectedRoomFilter,
                    hint: const Row(
                      children: [
                        Icon(Icons.meeting_room_outlined, size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('All Campus Rooms', style: AppTextStyles.body),
                      ],
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Row(
                          children: [
                            Icon(Icons.clear_all, size: 18, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Text('All Campus Rooms', style: AppTextStyles.body),
                          ],
                        ),
                      ),
                      ...rooms.map(
                        (r) => DropdownMenuItem<String?>(
                          value: r.id,
                          child: Row(
                            children: [
                              const Icon(Icons.meeting_room, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${r.name} (${r.building})',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedRoomFilter = val;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Hari Horizontal Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: days.map((day) {
                    final isSelected = _selectedDayFilter == day['value'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(day['name'] as String),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedDayFilter = day['value'] as int?;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Result Count Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${filteredSchedules.length} class schedules',
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
              ),
              if (_selectedDayFilter != null || _selectedRoomFilter != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayFilter = null;
                      _selectedRoomFilter = null;
                    });
                  },
                  child: const Text(
                    'Reset Filters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // List Jadwal
        Expanded(
          child: filteredSchedules.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event_note_outlined,
                  title: 'No Class Schedules',
                  subtitle: _selectedDayFilter != null || _selectedRoomFilter != null
                      ? 'No schedules match the selected filter.'
                      : 'No regular class schedules have been added yet.',
                  actionLabel: 'Add New Schedule',
                  onAction: () => _showAddScheduleDialog(rooms),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                  itemCount: filteredSchedules.length,
                  itemBuilder: (context, index) {
                    final item = filteredSchedules[index];
                    return _buildScheduleCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(RegularSchedule item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Hari, Jam, Status Switch & Delete Button
            Row(
              children: [
                // Day Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.dayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Time Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        item.timeRange,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Toggle Switch Status Keaktifan
                Tooltip(
                  message: item.isActive ? 'Deactivate Schedule' : 'Activate Schedule',
                  child: Switch(
                    value: item.isActive,
                    activeThumbColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (_) {
                      MockDataStore.instance.toggleRegularScheduleStatus(item.id);
                    },
                  ),
                ),

                // Delete Button
                IconButton(
                  tooltip: 'Delete Schedule',
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  onPressed: () => _confirmDeleteSchedule(item),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: 8),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Course Title & Code
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.courseName,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 16,
                      color: item.isActive ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.courseCode,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),

            // Schedule Details
            Row(
              children: [
                const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  item.roomName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.groups_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  item.classGroup,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.lecturerName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.school_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Semester ${item.semester}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (!item.isActive) ...[
                  const SizedBox(width: 8),
                  const StatusBadge(
                    status: 'inactive',
                    customLabel: 'Inactive / Holiday Schedule',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2: PEMBLOKIRAN TANGGAL NONAKTIF / BLACKOUT DATES (FR-12)
  // ===========================================================================

  Widget _buildBlackoutPeriodsTab(List<BlackoutPeriod> blackoutPeriods, List<Room> rooms) {
    // Terapkan filter status
    final filteredBlackouts = blackoutPeriods.where((b) {
      if (_blackoutFilter == 'active') return b.isActive;
      if (_blackoutFilter == 'inactive') return !b.isActive;
      return true;
    }).toList();

    final activeCount = blackoutPeriods.where((b) => b.isActive).length;
    final inactiveCount = blackoutPeriods.length - activeCount;

    return Column(
      children: [
        // Edu Banner
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Blackout periods automatically disable a room so students cannot book it (e.g. midterms, finals, maintenance, or campus holidays).',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips (Semua, Aktif, Nonaktif)
              Row(
                children: [
                  _buildFilterTabChip(
                    label: 'All (${blackoutPeriods.length})',
                    isSelected: _blackoutFilter == 'all',
                    onTap: () => setState(() => _blackoutFilter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTabChip(
                    label: 'Active ($activeCount)',
                    isSelected: _blackoutFilter == 'active',
                    onTap: () => setState(() => _blackoutFilter = 'active'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTabChip(
                    label: 'Inactive ($inactiveCount)',
                    isSelected: _blackoutFilter == 'inactive',
                    onTap: () => setState(() => _blackoutFilter = 'inactive'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List Blackout
        Expanded(
          child: filteredBlackouts.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No Date Blocks',
                  subtitle: _blackoutFilter != 'all'
                      ? 'No blackouts with the selected status.'
                      : 'No inactive blackout dates have been added.',
                  actionLabel: 'Add New Blackout',
                  onAction: () => _showAddBlackoutDialog(rooms),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: filteredBlackouts.length,
                  itemBuilder: (context, index) {
                    final item = filteredBlackouts[index];
                    return _buildBlackoutCard(item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterTabChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBlackoutCard(BlackoutPeriod item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.isActive ? AppColors.border : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status, Ruangan Scope, and Toggle Switch
            Row(
              children: [
                StatusBadge(
                  status: item.isActive ? 'active' : 'inactive',
                  customLabel: item.isActive ? 'Active' : 'Inactive',
                ),
                const SizedBox(width: 8),

                // Scope Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.appliesToAllRooms
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.appliesToAllRooms ? Icons.public : Icons.meeting_room,
                        size: 13,
                        color: item.appliesToAllRooms ? AppColors.primary : Colors.amber.shade900,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.roomName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: item.appliesToAllRooms ? AppColors.primaryDark : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Toggle Switch
                Switch(
                  value: item.isActive,
                  activeThumbColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) {
                    MockDataStore.instance.toggleBlackoutStatus(item.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              item.title,
              style: AppTextStyles.cardTitle.copyWith(
                fontSize: 16,
                color: item.isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // Date Range Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${DateTimeUtils.formatDate(item.startDate)} to ${DateTimeUtils.formatDate(item.endDate)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Reason / Alasan
            Text(
              item.reason,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),

            // Footer: Created By & Action Hapus
            Row(
              children: [
                const Icon(Icons.admin_panel_settings_outlined, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.createdBy,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  onPressed: () => _confirmDeleteBlackout(item),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text(
                    'Cancel & Delete',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DIALOG TAMBAH JADWAL PERKULIAHAN REGULER (FR-11)
  // ===========================================================================

  void _showAddScheduleDialog(List<Room> rooms) {
    if (rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No rooms available')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    String selectedRoomId = rooms.first.id;
    int selectedDay = 1; // Senin
    TimeOfDay startTime = const TimeOfDay(hour: 7, minute: 30);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 30);

    final courseCodeCtrl = TextEditingController();
    final courseNameCtrl = TextEditingController();
    final lecturerCtrl = TextEditingController();
    final classGroupCtrl = TextEditingController(text: 'SE-48-01');
    final semesterCtrl = TextEditingController(text: 'Even Semester 2024/2025');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final selectedRoom = rooms.firstWhere(
              (r) => r.id == selectedRoomId,
              orElse: () => rooms.first,
            );

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lavender,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_chart_outlined, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Add Regular Schedule',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Class Room *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedRoomId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          items: rooms.map((r) {
                            return DropdownMenuItem(
                              value: r.id,
                              child: Text('${r.name} - ${r.building}', overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => selectedRoomId = val);
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // Hari & Waktu
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Day *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<int>(
                                    initialValue: selectedDay,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 1, child: Text('Monday')),
                                      DropdownMenuItem(value: 2, child: Text('Tuesday')),
                                      DropdownMenuItem(value: 3, child: Text('Wednesday')),
                                      DropdownMenuItem(value: 4, child: Text('Thursday')),
                                      DropdownMenuItem(value: 5, child: Text('Friday')),
                                      DropdownMenuItem(value: 6, child: Text('Saturday')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setDialogState(() => selectedDay = val);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Jam Mulai & Jam Selesai
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Start Time *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: startTime,
                                      );
                                      if (picked != null) {
                                        setDialogState(() => startTime = picked);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.border),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateTimeUtils.formatTime(startTime),
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'End Time *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: endTime,
                                      );
                                      if (picked != null) {
                                        setDialogState(() => endTime = picked);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.border),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16, color: AppColors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateTimeUtils.formatTime(endTime),
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Nama Mata Kuliah
                        const Text(
                          'Course Name *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: courseNameCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Mobile Application Programming',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Course name is required' : null,
                        ),
                        const SizedBox(height: 14),

                        // Kode MK & Kelas
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Course Code *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: courseCodeCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'SE4803',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Class / Group *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: classGroupCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'SE-48-01',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    validator: (val) =>
                                        val == null || val.trim().isEmpty ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Dosen Pengampu
                        const Text(
                          'Lecturer *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: lecturerCtrl,
                          decoration: InputDecoration(
                            hintText: 'Lecturer full name with title',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Lecturer name is required' : null,
                        ),
                        const SizedBox(height: 14),

                        // Semester
                        const Text(
                          'Semester *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: semesterCtrl,
                          decoration: InputDecoration(
                            hintText: 'Even Semester 2024/2025',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final newSchedule = RegularSchedule(
                        id: 'sched-${DateTime.now().millisecondsSinceEpoch}',
                        roomId: selectedRoom.id,
                        roomName: selectedRoom.name,
                        courseCode: courseCodeCtrl.text.trim().toUpperCase(),
                        courseName: courseNameCtrl.text.trim(),
                        lecturerName: lecturerCtrl.text.trim(),
                        classGroup: classGroupCtrl.text.trim(),
                        dayOfWeek: selectedDay,
                        startTime: DateTimeUtils.formatTime(startTime),
                        endTime: DateTimeUtils.formatTime(endTime),
                        semester: semesterCtrl.text.trim().isEmpty
                            ? 'Even Semester 2024/2025'
                            : semesterCtrl.text.trim(),
                        isActive: true,
                      );

                      MockDataStore.instance.addRegularSchedule(newSchedule);
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Schedule "${newSchedule.courseName}" saved'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save Schedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteSchedule(RegularSchedule item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class Schedule?'),
        content: Text(
          'Are you sure you want to delete the class "${item.courseName}" (${item.dayName}, ${item.timeRange}) in room ${item.roomName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              MockDataStore.instance.deleteRegularSchedule(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.error,
                  content: Text('Jadwal "${item.courseName}" telah dihapus'),
                ),
              );
            },
            child: const Text('Delete Schedule'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIALOG PEMBLOKIRAN TANGGAL NONAKTIF (FR-12)
  // ===========================================================================

  void _showAddBlackoutDialog(List<Room> rooms) {
    final formKey = GlobalKey<FormState>();
    bool appliesToAllRooms = true;
    String? selectedRoomId = rooms.isNotEmpty ? rooms.first.id : null;

    DateTimeRange selectedDateRange = DateTimeRange(
      start: DateTime.now().add(const Duration(days: 1)),
      end: DateTime.now().add(const Duration(days: 7)),
    );

    final titleCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final createdByCtrl = TextEditingController(text: 'Academic Administration Bureau (BAA)');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.block, color: AppColors.error, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Date Blackout',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cakupan Ruangan
                        const Text(
                          'Blocked Room Scope *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),

                        // Segmented / Radio Cakupan
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setDialogState(() => appliesToAllRooms = true);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: appliesToAllRooms ? AppColors.primary.withValues(alpha: 0.12) : AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: appliesToAllRooms ? AppColors.primary : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.public,
                                        size: 16,
                                        color: appliesToAllRooms ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'All Rooms',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: appliesToAllRooms ? FontWeight.w700 : FontWeight.w500,
                                          color: appliesToAllRooms ? AppColors.primaryDark : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  setDialogState(() => appliesToAllRooms = false);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: !appliesToAllRooms ? AppColors.primary.withValues(alpha: 0.12) : AppColors.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: !appliesToAllRooms ? AppColors.primary : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.meeting_room,
                                        size: 16,
                                        color: !appliesToAllRooms ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Specific Rooms',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: !appliesToAllRooms ? FontWeight.w700 : FontWeight.w500,
                                          color: !appliesToAllRooms ? AppColors.primaryDark : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Dropdown bila Ruangan Khusus
                        if (!appliesToAllRooms) ...[
                          const Text(
                            'Select Specific Room *',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: selectedRoomId,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            items: rooms.map((r) {
                              return DropdownMenuItem(
                                value: r.id,
                                child: Text('${r.name} - ${r.building}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedRoomId = val);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Judul Periode Pemblokiran
                        const Text(
                          'Agenda Title / Blackout Reason *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: titleCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. Midterm Week 2024/2025',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Blackout title is required' : null,
                        ),
                        const SizedBox(height: 14),

                        // Pemilihan Rentang Tanggal
                        const Text(
                          'Blackout Date Range *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2025, 1, 1),
                              lastDate: DateTime(2027, 12, 31),
                              initialDateRange: selectedDateRange,
                              helpText: 'Select Blackout Date Range',
                              confirmText: 'Select',
                              cancelText: 'Cancel',
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDateRange = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.background,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.date_range, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${DateTimeUtils.formatDate(selectedDateRange.start)} - ${DateTimeUtils.formatDate(selectedDateRange.end)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                                const Icon(Icons.edit_calendar_outlined, size: 18, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Alasan Detail
                        const Text(
                          'Description / Policy Notes *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: reasonCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Explain why the room is disabled for booking...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Reason description is required' : null,
                        ),
                        const SizedBox(height: 14),

                        // Unit Pembuat Kebijakan
                        const Text(
                          'Issued By / Unit *',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: createdByCtrl,
                          decoration: InputDecoration(
                            hintText: 'Academic Administration Bureau (BAA)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      String roomName = 'All Campus Rooms';
                      if (!appliesToAllRooms && selectedRoomId != null) {
                        final foundRoom = rooms.firstWhere(
                          (r) => r.id == selectedRoomId,
                          orElse: () => rooms.first,
                        );
                        roomName = foundRoom.name;
                      }

                      final newBlackout = BlackoutPeriod(
                        id: 'bo-${DateTime.now().millisecondsSinceEpoch}',
                        roomId: appliesToAllRooms ? null : selectedRoomId,
                        roomName: roomName,
                        title: titleCtrl.text.trim(),
                        reason: reasonCtrl.text.trim(),
                        startDate: selectedDateRange.start,
                        endDate: selectedDateRange.end,
                        isActive: true,
                        createdBy: createdByCtrl.text.trim().isEmpty
                            ? 'Academic Administration Bureau (BAA)'
                            : createdByCtrl.text.trim(),
                      );

                      MockDataStore.instance.addBlackoutPeriod(newBlackout);
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.success,
                          content: Text('Blackout period "${newBlackout.title}" saved'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save Blackout'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteBlackout(BlackoutPeriod item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel & Delete Blackout?'),
        content: Text(
          'The blackout period "${item.title}" will be removed. Students will be able to book that room and date range again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              MockDataStore.instance.deleteBlackoutPeriod(item.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.error,
                  content: Text('Blackout "${item.title}" cancelled and deleted'),
                ),
              );
            },
            child: const Text('Cancel & Delete'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE HELPER
  // ===========================================================================

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lavender.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
