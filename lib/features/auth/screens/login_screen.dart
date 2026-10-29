// PIC: Farrel - Login Screen - FR-01, FR-20

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../student/screens/student_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginDemo(String role) {
    if (!_formKey.currentState!.validate()) return;

    _openDemoPage(role);
  }

  void _openDemoPage(String role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => _DemoLandingScreen(role: role)),
    );
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBrand(),
                    const SizedBox(height: 40),

                    Text(
                      'Welcome Back!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk untuk mulai memesan ruangan kampus.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    const _FieldLabel('Email atau NIM/NIP'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _identityController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan email atau NIM/NIP',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email atau NIM/NIP wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),
                    const _FieldLabel('Kata Sandi'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kata sandi wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentHomeScreen(),
                          ),
                        );
                      },
                      child: const Text('Masuk'),
                    ),

                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ATAU COBA DEMO',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StudentHomeScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('Masuk sebagai Mahasiswa'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.lavender),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openDemoPage('admin'),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: const Text('Masuk sebagai Admin'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Belum punya akun?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: _openRegister,
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'S',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'SINI-GAN',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Campus Room Booking',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }
}

/// Halaman sementara untuk menguji tombol demo.
/// Ganti dengan StudentHomeScreen dan AdminDashboardScreen
/// setelah kedua screen tersebut selesai diimplementasikan.
class _DemoLandingScreen extends StatelessWidget {
  const _DemoLandingScreen({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isStudent = role == 'student';

    return Scaffold(
      appBar: AppBar(
        title: Text(isStudent ? 'Demo Mahasiswa' : 'Demo Admin'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isStudent
                    ? Icons.school_outlined
                    : Icons.admin_panel_settings_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                isStudent ? 'Beranda Mahasiswa' : 'Dashboard Admin',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Halaman sementara untuk menguji alur demo.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
