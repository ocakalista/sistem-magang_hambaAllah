import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

import '../../models/admin_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';

class AdminLowonganDetailScreen extends StatelessWidget {
  const AdminLowonganDetailScreen({super.key, required this.lowongan});

  final PendingLowongan lowongan;

  @override
  Widget build(BuildContext context) {
    final pending = lowongan.status == LowonganApprovalStatus.pending;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tinjau Lowongan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          _section(context, 'Informasi', [
            _row('Posisi', lowongan.position),
            _row('Mitra', lowongan.companyName),
            _row('Kategori', lowongan.companyCategory),
            _row('Lokasi', lowongan.location),
            _row('Tipe kerja', lowongan.workType),
            _row('Kontrak', lowongan.contractType),
            _row('Kuota', '${lowongan.quota}'),
            _row(
              'Deadline',
              lowongan.deadline == null
                  ? '-'
                  : '${lowongan.deadline!.day}/${lowongan.deadline!.month}/${lowongan.deadline!.year}',
            ),
          ]),
          const SizedBox(height: 14),
          _section(context, 'Deskripsi', [
            Text(
              lowongan.requestDescription.isEmpty
                  ? 'Belum tersedia.'
                  : lowongan.requestDescription,
            ),
          ]),
          const SizedBox(height: 14),
          _section(context, 'Persyaratan', [
            Text(
              lowongan.requirements.isEmpty
                  ? 'Belum tersedia.'
                  : lowongan.requirements,
            ),
          ]),
          const SizedBox(height: 14),
          _section(context, 'Benefit', [
            Text(
              lowongan.benefits.isEmpty ? 'Belum tersedia.' : lowongan.benefits,
            ),
          ]),
        ],
      ),
      bottomSheet:
          pending
              ? SafeArea(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _reject(context),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approve(context),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Flexible(
          child: Text(
            value.isEmpty ? '-' : value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Future<void> _approve(BuildContext context) async {
    try {
      await NexusScope.of(context).approveLowongan(lowongan.id);
      if (context.mounted) Navigator.pop(context);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _reject(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Alasan penolakan'),
            content: TextField(controller: controller, maxLines: 3),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(dialogContext, controller.text.trim()),
                child: const Text('Tolak'),
              ),
            ],
          ),
    );
    controller.dispose();
    if (reason == null || reason.isEmpty || !context.mounted) return;
    try {
      await NexusScope.of(context).rejectLowongan(lowongan.id, reason);
      if (context.mounted) Navigator.pop(context);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
