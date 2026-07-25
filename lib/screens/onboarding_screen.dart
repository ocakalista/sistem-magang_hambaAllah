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
      assetPath: 'assets/images/onboarding/onboard1.png',
    ),
    _OnboardingContent(
      title: 'Pantau Progress Lamaran',
      body:
          'Kelola semua aplikasi magangmu dalam satu tempat agar proses seleksi lebih terarah dan mudah dipantau.',
      badge: 'Progress Real-Time',
      accent: AppColors.secondary,
      assetPath: 'assets/images/onboarding/onboard2.png',
    ),
    _OnboardingContent(
      title: 'Siap Terhubung ke Industri',
      body:
          'Bangun langkah awal karier bersama ekosistem magang Universitas Amikom Yogyakarta.',
      badge: 'Amikom Career Path',
      accent: AppColors.tertiary,
      assetPath: 'assets/images/onboarding/onboard3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    AspectRatio(
                      aspectRatio: 1.08,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged:
                            (index) => setState(() => _currentPage = index),
                        itemBuilder:
                            (context, index) =>
                                _HeroCard(content: _pages[index]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Column(
                        key: ValueKey(_currentPage),
                        children: [
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.body,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppColors.neutral,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PageIndicator(selectedIndex: _currentPage),
                  ],
                ),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
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
    required this.assetPath,
  });

  final String title;
  final String body;
  final String badge;
  final Color accent;
  final String assetPath;
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              content.assetPath,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) => Container(
                    color: content.accent,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white,
                      size: 56,
                    ),
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
