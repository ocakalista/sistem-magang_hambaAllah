import 'package:flutter/material.dart' hide Text;

import '../models/nexus_app_state.dart';
import '../screens/login_screen.dart';

class RoleGuard extends StatelessWidget {
  const RoleGuard({super.key, required this.requiredRole, required this.child});

  final UserRole requiredRole;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    if (state.currentUserRole != requiredRole) {
      // redirect to login for non-authorized users
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    return child;
  }
}
