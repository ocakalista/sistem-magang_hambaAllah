import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

import '../../services/lowongan_draft_service.dart';
import '../../theme/app_theme.dart';

class LowonganDraftsScreen extends StatefulWidget {
  const LowonganDraftsScreen({super.key});

  @override
  State<LowonganDraftsScreen> createState() => _LowonganDraftsScreenState();
}

class _LowonganDraftsScreenState extends State<LowonganDraftsScreen> {
  late Future<List<Map<String, dynamic>>> _drafts;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _drafts = LowonganDraftService.load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Draft Lowongan')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _drafts,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final drafts = snapshot.data ?? const <Map<String, dynamic>>[];
          if (drafts.isEmpty) {
            return const Center(child: Text('Belum ada draft lowongan.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: drafts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return Card(
                child: ExpansionTile(
                  title: Text(
                    draft['judul_posisi']?.toString().trim().isNotEmpty == true
                        ? draft['judul_posisi'].toString()
                        : 'Draft tanpa judul',
                  ),
                  subtitle: Text(
                    'Disimpan ${draft['saved_at']?.toString() ?? ''}',
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        draft['deskripsi']?.toString().trim().isNotEmpty == true
                            ? draft['deskripsi'].toString()
                            : 'Deskripsi belum diisi.',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            await LowonganDraftService.deleteAt(index);
                            if (!mounted) return;
                            setState(_reload);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hapus'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
