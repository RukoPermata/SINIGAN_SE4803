import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'room_management_screen.dart';

/// Tab "Profil" admin: identitas pengelola, akses ke Manajemen Ruangan
/// (dipindahkan dari bottom nav), dan logout.
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Pengelola'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 28),
          _buildSectionTitle('Manajemen'),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            icon: Icons.meeting_room_outlined,
            title: 'Manajemen Ruangan',
            subtitle: 'Kelola data master ruangan & status aktif',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RoomManagementScreen()),
            ),
          ),
          const SizedBox(height: 28),
          _buildSectionTitle('Akun'),
          const SizedBox(height: 12),
          _buildLogoutCard(context),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'SINI-GAN • Campus Room Booking',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            AppConstants.currentAdminName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pengelola Ruangan Kampus',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'ID Pengelola',
            value: AppConstants.currentAdminId,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.apartment_outlined,
            label: 'Unit',
            value: AppConstants.currentAdminUnit,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => _confirmLogout(context),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.logout_rounded, color: AppColors.error),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
        subtitle: const Text(
          'Keluar dari sesi pengelola',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
