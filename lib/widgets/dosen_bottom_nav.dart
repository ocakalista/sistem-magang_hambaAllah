import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/app_localizations.dart';

import '../../theme/app_theme.dart';

class DosenBottomNav extends StatelessWidget {
  const DosenBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: tr('Home'),
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school_rounded),
          label: tr('Students'),
        ),
        NavigationDestination(
          icon: Icon(Icons.notifications_none_rounded),
          selectedIcon: Icon(Icons.notifications_rounded),
          label: tr('Alerts'),
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: tr('Profile'),
        ),
      ],
    );
  }
}
