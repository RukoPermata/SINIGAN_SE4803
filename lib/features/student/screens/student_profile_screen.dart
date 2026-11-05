// PIC: Farrel - Student Profile Screen - FR-20

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../shared/widgets/profile_widgets.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _notificationsEnabled = true;

  Future<void> _logout() async {
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
              ProfileIdentityCard(
                avatar: const Text(
                  'RP',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                name: AppConstants.currentStudentName,
                subtitle: AppConstants.currentStudentEmail,
                infoRows: const [
                  ProfileInfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Student ID',
                    value: AppConstants.currentStudentNim,
                  ),
                  ProfileInfoRow(
                    icon: Icons.school_outlined,
                    label: 'Program',
                    value: 'S1 Software Engineering',
                  ),
                  ProfileInfoRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Status',
                    value: 'Active Student',
                    valueColor: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildQuotaCard(),
              const SizedBox(height: 28),
              const ProfileSectionTitle('Settings'),
              const SizedBox(height: 12),
              ProfileSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: 'Booking Notifications',
                subtitle: 'Receive updates about your reservations',
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
              const SizedBox(height: 12),
              ProfileMenuTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English',
                onTap: () {},
              ),
              const SizedBox(height: 28),
              const ProfileSectionTitle('Account'),
              const SizedBox(height: 12),
              ProfileMenuTile(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Switch to Administrator View',
                onTap: () => Get.offNamed(AppRoutes.adminDashboard),
              ),
              const SizedBox(height: 12),
              ProfileLogoutTile(onTap: _logout),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'SINI-GAN • Campus Room Booking',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotaCard() {
    return ProfileCard(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Booking Quota',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '8',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5, left: 5),
                child: Text(
                  'of 10 bookings used',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: 0.8,
              minHeight: 8,
              backgroundColor: AppColors.lavender,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '2 bookings remaining this month',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
