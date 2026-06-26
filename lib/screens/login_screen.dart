import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../models/nexus_app_state.dart';
import 'mahasiswa/dashboard_mahasiswa.dart';
import 'admin/admin_dashboard_screen.dart';
import 'dosen/dosen_dashboard_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Nexus',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Row(
            children: [
              const Icon(
                Icons.school_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'AMIKOM',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.login_rounded,
                          color: AppColors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 30),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock your future internship at Universitas Amikom',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email or NIM',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  setState(() => _isLoading = true);

                                  final emailOrNim =
                                      _emailController.text.trim();
                                  final password =
                                      _passwordController.text.trim();

                                  // Validasi input
                                  if (emailOrNim.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Harap isi email/NIM dan password',
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    setState(() => _isLoading = false);
                                    return;
                                  }

                                  // Tembak API Backend
                                  final response = await ApiService.login(
                                    emailOrNim,
                                    password,
                                  );

                                  setState(() => _isLoading = false);

                                  if (!mounted) return;

                                  // Cek apakah berhasil mendapat token
                                  if (response.containsKey('token')) {
                                    final state = NexusScope.of(context);

                                    // Ambil role dari database
                                    final roleStr =
                                        response['role'] ?? 'mahasiswa';
                                    UserRole role;

                                    if (roleStr == 'admin') {
                                      role = UserRole.admin;
                                    } else if (roleStr == 'dosen') {
                                      role = UserRole.dosen;
                                    } else {
                                      role = UserRole.student;
                                    }

                                    state.setUserRole(role);

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login Berhasil!'),
                                        ),
                                      );

                                      // Arahkan ke dashboard yang sesuai
                                      if (role == UserRole.admin) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AdminDashboardScreen.routeName,
                                        );
                                      } else if (role == UserRole.dosen) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          DosenDashboardScreen.routeName,
                                        );
                                      } else {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          DashboardMahasiswa.routeName,
                                        );
                                      }
                                    }
                                  } else {
                                    // Tampilkan error message
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response['message'] ??
                                                'Gagal terhubung ke server. Harap pastikan backend Laravel berjalan di http://127.0.0.1:8000',
                                          ),
                                          backgroundColor: Colors.red.shade400,
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  }
                                },
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : const Text('LOGIN TO NEXUS →'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Gunakan akun ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Amikom',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' untuk login',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(child: _Badge(label: 'Secure Encryption')),
                  const SizedBox(width: 12),
                  Expanded(child: _Badge(label: 'Amikom Certified')),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '© 2024 Universitas Amikom Yogyakarta • Internship Nexus',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5DDF3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
