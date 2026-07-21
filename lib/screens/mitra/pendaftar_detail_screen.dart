import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/application_model.dart';
import '../../models/mitra_model.dart';
import '../../models/mitra_provider.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';

class PendaftarDetailScreen extends StatefulWidget {
  static const routeName = '/mitra/pendaftar-detail';

  const PendaftarDetailScreen({super.key, required this.applicant});

  final PendaftarTerbaru applicant;

  @override
  State<PendaftarDetailScreen> createState() => _PendaftarDetailScreenState();
}

class _PendaftarDetailScreenState extends State<PendaftarDetailScreen> {
  late ApplicationStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.applicant.status;
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<MitraProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Detail Pendaftar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildInfoCard(context),
              const SizedBox(height: 20),
              _buildTimeline(context),
              const SizedBox(height: 20),
              _buildDocumentRow(
                context,
                widget.applicant.cvUrl == null
                    ? 'CV tidak tersedia'
                    : 'CV tersedia di server',
                Icons.description_rounded,
              ),
              const SizedBox(height: 20),
              _buildMotivationSection(context),
            ],
          ),
        ),
      ),
      bottomSheet:
          _status == ApplicationStatus.submitted ||
                  _status == ApplicationStatus.underReview
              ? Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            () => _setStatus(
                              context,
                              state,
                              ApplicationStatus.accepted,
                            ),
                        child: const Text('Terima'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: () => _confirmReject(context, state),
                        child: const Text('Tolak'),
                      ),
                    ),
                  ],
                ),
              )
              : null,
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.16),
            foregroundImage:
                widget.applicant.avatarUrl != null
                    ? NetworkImage(widget.applicant.avatarUrl!)
                    : null,
            child:
                widget.applicant.avatarUrl == null
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.applicant.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.applicant.position,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.applicant.status.mitraBadgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    widget.applicant.status.mitraBadgeLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.applicant.status.mitraBadgeTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final stages = [
      'Lamaran masuk',
      _status == ApplicationStatus.rejected ? 'Ditolak' : 'Diterima',
    ];
    final activeIndex = _status == ApplicationStatus.submitted ? 0 : 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Column(
            children: List.generate(stages.length, (index) {
              final active = index <= activeIndex;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.primary : AppColors.background,
                          border: Border.all(
                            color:
                                active
                                    ? AppColors.primary
                                    : AppColors.neutral.withValues(alpha: 0.4),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stages[index],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.black87 : AppColors.neutral,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (index < stages.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 7,
                        top: 4,
                        bottom: 8,
                      ),
                      child: Container(
                        width: 2,
                        height: 24,
                        color:
                            active
                                ? AppColors.primary
                                : AppColors.neutral.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(BuildContext context, String label, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.neutral),
        ],
      ),
    );
  }

  Widget _buildMotivationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Motivation Letter',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'Motivasi belum tersedia pada respons daftar pelamar dari server.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context, MitraProvider state) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Tolak'),
          content: const Text('Apakah Anda yakin ingin menolak pendaftar ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _setStatus(context, state, ApplicationStatus.rejected);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Tolak', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setStatus(
    BuildContext context,
    MitraProvider state,
    ApplicationStatus status,
  ) async {
    final token = NexusScope.of(context).authToken;
    if (token == null) return;
    try {
      await state.updateApplicantStatus(token, widget.applicant.id, status);
      if (!mounted) return;
      setState(() => _status = status);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status berhasil disinkronkan.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
