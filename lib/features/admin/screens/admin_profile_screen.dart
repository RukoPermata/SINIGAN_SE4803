import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/profile_widgets.dart';
import 'room_management_screen.dart';

/// Admin "Profile" tab: identity card, access to Room Management (moved out of
/// the bottom nav), and logout.
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your account and preferences.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 28),
              const ProfileIdentityCard(
                avatar: Text(
                  'AD',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                name: AppConstants.currentAdminName,
                subtitle: 'Room Manager • SINI-GAN',
                infoRows: [
                  ProfileInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Admin ID',
                    value: AppConstants.currentAdminId,
                  ),
                  ProfileInfoRow(
                    icon: Icons.apartment_outlined,
                    label: 'Unit',
                    value: 'Facilities & Infrastructure Bureau',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const ProfileSectionTitle('Management'),
              const SizedBox(height: 12),
              ProfileMenuTile(
                icon: Icons.meeting_room_outlined,
                title: 'Room Management',
                subtitle: 'Manage the room master data & availability',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RoomManagementScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const ProfileSectionTitle('Account'),
              const SizedBox(height: 12),
              ProfileLogoutTile(onTap: () => _logout(context)),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'SINI-GAN • Campus Room Booking',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
