import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class LowonganScreen extends StatelessWidget {
  const LowonganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lowongan'),
      ),
      body: const Center(
        child: Text('Manage Internship Listings - TODO'),
      ),
    );
  }
}
