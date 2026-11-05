import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/mock_data_store.dart';
import '../widgets/room_card.dart';
import 'room_detail_screen.dart';

/// Katalog & pencarian ruangan kampus untuk mahasiswa (FR-03).
/// Mendukung pencarian instan nama/gedung/fasilitas, filter lantai & kapasitas,
/// serta indikator status ketersediaan tiap ruangan.
class RoomCatalogScreen extends StatefulWidget {
  const RoomCatalogScreen({super.key});

  @override
  State<RoomCatalogScreen> createState() => _RoomCatalogScreenState();
}

class _RoomCatalogScreenState extends State<RoomCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  int? _floor; // null = semua lantai
  int _minCapacity = 0;

  static const Map<String, int> _capacityOptions = {
    'Semua Ukuran': 0,
    '≥ 20 orang': 20,
    '≥ 40 orang': 40,
    '≥ 60 orang': 60,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Ruangan'),
        automaticallyImplyLeading: false,
      ),
      body: GetBuilder<MockDataStore>(
        init: MockDataStore.instance,
        builder: (store) {
          final floors = store.rooms.map((r) => r.floor).toSet().toList()
            ..sort();

          final rooms = store.rooms.where((r) {
            if (_floor != null && r.floor != _floor) return false;
            if (r.capacity < _minCapacity) return false;
            if (_query.isNotEmpty) {
              final q = _query.toLowerCase();
              final matches = r.name.toLowerCase().contains(q) ||
                  r.building.toLowerCase().contains(q) ||
                  r.facilities.any((f) => f.toLowerCase().contains(q));
              if (!matches) return false;
            }
            return true;
          }).toList()
            ..sort((a, b) {
              if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
              return a.name.compareTo(b.name);
            });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _buildSearchBar(),
              ),
              _buildFloorFilters(floors),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: _buildCapacityDropdown(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Text(
                  '${rooms.length} ruangan ditemukan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: rooms.isEmpty
                    ? _buildEmpty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: rooms.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return RoomCard(
                            room: room,
                            onTap: () =>
                                Get.to(() => RoomDetailScreen(room: room)),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value.trim()),
      decoration: InputDecoration(
        hintText: 'Cari nama ruangan, gedung, atau fasilitas...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _query = '';
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildFloorFilters(List<int> floors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _buildFloorChip(label: 'Semua Lantai', value: null),
          for (final floor in floors) ...[
            const SizedBox(width: 8),
            _buildFloorChip(label: 'Lantai $floor', value: floor),
          ],
        ],
      ),
    );
  }

  Widget _buildFloorChip({required String label, required int? value}) {
    final selected = _floor == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: selected ? Colors.white : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      onSelected: (_) => setState(() => _floor = value),
    );
  }

  Widget _buildCapacityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _minCapacity,
          isExpanded: true,
          icon: const Icon(Icons.groups_outlined, size: 20, color: AppColors.primary),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: _capacityOptions.entries
              .map(
                (e) => DropdownMenuItem<int>(
                  value: e.value,
                  child: Text('Kapasitas: ${e.key}'),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _minCapacity = value ?? 0),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coba ubah kata kunci atau filter yang kamu pilih.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _query = '';
                  _floor = null;
                  _minCapacity = 0;
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
