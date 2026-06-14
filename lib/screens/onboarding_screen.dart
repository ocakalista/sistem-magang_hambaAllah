import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingContent(
      title: 'Cari Lowongan Magang',
      body:
          'Temukan peluang magang terbaik dari perusahaan ternama yang sesuai dengan minat dan bakatmu.',
      badge: '1,200+ Lowongan Aktif',
      accent: AppColors.primary,
    ),
    _OnboardingContent(
      title: 'Pantau Progress Lamaran',
      body:
          'Kelola semua aplikasi magangmu dalam satu tempat agar proses seleksi lebih terarah dan mudah dipantau.',
      badge: 'Progress Real-Time',
      accent: AppColors.secondary,
    ),
    _OnboardingContent(
      title: 'Siap Terhubung ke Industri',
      body:
          'Bangun langkah awal karier bersama ekosistem magang Universitas Amikom Yogyakarta.',
      badge: 'Amikom Career Path',
      accent: AppColors.tertiary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Nexus',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                () => Navigator.pushReplacementNamed(
                  context,
                  LoginScreen.routeName,
                ),
            child: const Text('Lewati'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _HeroCard(content: page),
                        const SizedBox(height: 28),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.neutral, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        _PageIndicator(selectedIndex: _currentPage),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          () => Navigator.pushReplacementNamed(
                            context,
                            LoginScreen.routeName,
                          ),
                      child: const Text('Lanjutkan →'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Geser untuk melihat lainnya',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.neutral),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.title,
    required this.body,
    required this.badge,
    required this.accent,
  });

  final String title;
  final String body;
  final String badge;
  final Color accent;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.08,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  content.accent.withValues(alpha: 0.95),
                  AppColors.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: content.accent.withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    content.badge,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isSelected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFD7D2E3),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
