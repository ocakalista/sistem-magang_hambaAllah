import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        color: AppColors.primary,
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Nexus',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: AppColors.white, fontSize: 40),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'INTERNSHIP PORTAL',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.white,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 56,
                child: Text(
                  'Powered by Amikom',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 22,
                child: _DotIndicator(selectedIndex: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isSelected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.white
                    : AppColors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
