import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  static const routeName = '/notification-settings';

  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const _approvalKey = 'notification_logbook_approval';
  static const _revisionKey = 'notification_logbook_revision';
  static const _studentKey = 'notification_student_activity';
  static const _systemKey = 'notification_system_updates';

  bool _loading = true;
  bool _approval = true;
  bool _revision = true;
  bool _studentActivity = true;
  bool _systemUpdates = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _approval = preferences.getBool(_approvalKey) ?? true;
      _revision = preferences.getBool(_revisionKey) ?? true;
      _studentActivity = preferences.getBool(_studentKey) ?? true;
      _systemUpdates = preferences.getBool(_systemKey) ?? true;
      _loading = false;
    });
  }

  Future<void> _update(String key, bool value) async {
    await (await SharedPreferences.getInstance()).setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pengaturan Notifikasi')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Preferensi Notifikasi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih informasi yang ingin ditampilkan sebagai notifikasi.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
                  ),
                  const SizedBox(height: 20),
                  _SettingsCard(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.verified_outlined),
                        title: const Text('Logbook disetujui'),
                        subtitle: const Text(
                          'Pemberitahuan aktivitas persetujuan logbook.',
                        ),
                        value: _approval,
                        onChanged: (value) {
                          setState(() => _approval = value);
                          _update(_approvalKey, value);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.rate_review_outlined),
                        title: const Text('Permintaan revisi'),
                        subtitle: const Text(
                          'Pemberitahuan logbook yang memerlukan revisi.',
                        ),
                        value: _revision,
                        onChanged: (value) {
                          setState(() => _revision = value);
                          _update(_revisionKey, value);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.school_outlined),
                        title: const Text('Aktivitas mahasiswa'),
                        subtitle: const Text(
                          'Logbook baru dari mahasiswa bimbingan.',
                        ),
                        value: _studentActivity,
                        onChanged: (value) {
                          setState(() => _studentActivity = value);
                          _update(_studentKey, value);
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.campaign_outlined),
                        title: const Text('Pembaruan sistem'),
                        subtitle: const Text(
                          'Informasi umum dan pembaruan platform.',
                        ),
                        value: _systemUpdates,
                        onChanged: (value) {
                          setState(() => _systemUpdates = value);
                          _update(_systemKey, value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Preferensi ini tersimpan pada perangkat ini.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                  ),
                ],
              ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
