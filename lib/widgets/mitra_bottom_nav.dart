import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MitraBottomNavigationBar extends StatelessWidget {
  const MitraBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = <_MitraNavDestination>[
      _MitraNavDestination(label: 'Home', icon: Icons.home_rounded),
      _MitraNavDestination(label: 'Lowongan', icon: Icons.work_rounded),
      _MitraNavDestination(label: 'Alerts', icon: Icons.notifications_rounded),
      _MitraNavDestination(label: 'Profile', icon: Icons.person_rounded),
    ];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(destinations.length, (index) {
          final item = destinations[index];
          final active = index == selectedIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onDestinationSelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            active ? AppColors.primary : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: active ? AppColors.white : AppColors.neutral,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: active ? AppColors.primary : AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MitraNavDestination {
  const _MitraNavDestination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
