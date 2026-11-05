import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/mock_data_store.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/student/screens/student_home_screen.dart';

/// Binding awal untuk mendaftarkan store data pada container dependensi GetX,
/// sehingga dapat diakses dari mana pun melalui `Get.find` atau `GetBuilder`.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MockDataStore>(MockDataStore.instance, permanent: true);
  }
}

class SiniGanApp extends StatelessWidget {
  const SiniGanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SINI-GAN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      initialBinding: InitialBinding(),
      getPages: [
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: AppRoutes.register,
          page: () => const RegisterScreen(),
        ),
        GetPage(
          name: AppRoutes.studentHome,
          page: () => const StudentHomeScreen(),
        ),
        GetPage(
          name: AppRoutes.adminDashboard,
          page: () => const AdminDashboardScreen(),
        ),
      ],
    );
  }
}
