import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

import '../../models/admin_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';
import 'lowongan_detail_screen.dart';
import 'admin_bottom_nav.dart';

class LowonganScreen extends StatelessWidget {
  const LowonganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    final allRequests = state.pendingLowongan;
    final pendingRequests =
        allRequests
            .where((item) => item.status == LowonganApprovalStatus.pending)
            .toList();
    final approvedRequests =
        allRequests
            .where((item) => item.status == LowonganApprovalStatus.approved)
            .toList();
    final rejectedRequests =
        allRequests
            .where((item) => item.status == LowonganApprovalStatus.rejected)
            .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Lowongan'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.neutral,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(context, pendingRequests, state),
            _buildList(context, approvedRequests, state),
            _buildList(context, rejectedRequests, state),
          ],
        ),
        bottomNavigationBar: AdminBottomNav(
          selectedIndex: 1,
          onDestinationSelected:
              (index) => navigateAdminTab(
                context,
                currentIndex: 1,
                destinationIndex: index,
              ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<PendingLowongan> requests,
    NexusAppState state,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada lowongan di kategori ini.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(context, request, state);
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    PendingLowongan request,
    NexusAppState state,
  ) {
    final isPending = request.status == LowonganApprovalStatus.pending;
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminLowonganDetailScreen(lowongan: request),
            ),
          ),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.companyName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(request.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    request.status.name.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _statusColor(request.status),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.companyCategory,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
            ),
            const SizedBox(height: 12),
            Text(
              request.requestDescription,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await state.approveLowongan(request.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lowongan disetujui.'),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Approve gagal: $e')),
                          );
                        }
                      },
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final reason = await _showRejectDialog(context);
                        if (!navigator.mounted) return;
                        if (reason != null && reason.isNotEmpty) {
                          try {
                            await state.rejectLowongan(request.id, reason);
                            if (!context.mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Lowongan ditolak.'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text('Reject gagal: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(LowonganApprovalStatus status) {
    switch (status) {
      case LowonganApprovalStatus.pending:
        return AppColors.primary;
      case LowonganApprovalStatus.approved:
        return Colors.green;
      case LowonganApprovalStatus.rejected:
        return Colors.red;
    }
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tolak Lowongan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan alasan penolakan:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(labelText: tr('Alasan')),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
  }
}
