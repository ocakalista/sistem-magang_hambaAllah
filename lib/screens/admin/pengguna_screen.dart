import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class PenggunaScreen extends StatelessWidget {
  const PenggunaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengguna')),
      body: const Center(child: Text('Manage Users - TODO')),
    );
  }
}
