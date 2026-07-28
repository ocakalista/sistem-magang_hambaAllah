import 'dart:convert';

import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/application_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';
import 'application_status_screen.dart';
import '../../services/api_service.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key, required this.internship});

  final Internship internship;

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();

  int _currentStep = 0;
  bool _isSubmitting = false;

  // INJEKSI: Variabel diubah menjadi List<int> (bytes) khusus untuk Web
  List<int>? _cvBytes;
  String? _cvFileName;
  double _cvUploadProgress = 0;

  List<int>? _portfolioBytes;
  String? _portfolioSelection;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
    _fullNameController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _semesterController.addListener(() => setState(() {}));
    _portfolioController.addListener(() => setState(() {}));
    _motivationController.addListener(() => setState(() {}));
  }

  String get _draftKey => 'application_draft_${widget.internship.id}';

  Future<void> _saveDraft() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _draftKey,
      jsonEncode({
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'semester': _semesterController.text,
        'portfolioLink': _portfolioController.text,
        'motivation': _motivationController.text,
      }),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Draft tersimpan. Buka lowongan ini lagi untuk melanjutkan; file perlu dipilih ulang.',
        ),
      ),
    );
  }

  Future<void> _restoreDraft() async {
    final raw = (await SharedPreferences.getInstance()).getString(_draftKey);
    if (raw == null) return;
    final draft = jsonDecode(raw) as Map<String, dynamic>;
    _fullNameController.text = draft['fullName']?.toString() ?? '';
    _phoneController.text = draft['phone']?.toString() ?? '';
    _semesterController.text = draft['semester']?.toString() ?? '';
    _portfolioController.text = draft['portfolioLink']?.toString() ?? '';
    _motivationController.text = draft['motivation']?.toString() ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _semesterController.dispose();
    _portfolioController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  bool get _uploadsReady {
    final hasCv = _cvBytes != null;
    final hasPortfolio =
        _portfolioBytes != null || _portfolioController.text.trim().isNotEmpty;
    final hasMotivation = _motivationController.text.trim().length >= 10;

    return hasCv && hasPortfolio && hasMotivation;
  }

  bool get _canSubmit {
    final detailsValid =
        _fullNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _semesterController.text.trim().isNotEmpty;
    return detailsValid && _uploadsReady;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Nexus',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Magang',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.internship.position} di ${widget.internship.company}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StepIndicator(currentStep: _currentStep),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (value) => setState(() => _currentStep = value),
              children: [
                _buildDetailsStep(),
                _buildUploadsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveDraft,
                child: const Text('Simpan Draft'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        _currentStep == 2 && _canSubmit
                            ? const [AppColors.primary, AppColors.secondary]
                            : [
                              AppColors.primary.withValues(alpha: 0.5),
                              AppColors.secondary.withValues(alpha: 0.5),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ElevatedButton.icon(
                  onPressed:
                      _isSubmitting
                          ? null
                          : (_currentStep == 2 && _canSubmit
                              ? () => _submitApplication(context)
                              : (_currentStep < 2
                                  ? () {
                                    if (_currentStep == 0 &&
                                        !(_detailsFormKey.currentState
                                                ?.validate() ??
                                            false)) {
                                      return;
                                    }
                                    if (_currentStep == 1 && !_uploadsReady) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            _cvBytes == null
                                                ? 'File CV belum di-upload!'
                                                : _portfolioBytes == null &&
                                                    _portfolioController.text
                                                        .trim()
                                                        .isEmpty
                                                ? 'Isi URL portofolio atau upload filenya!'
                                                : 'Motivasi minimal 10 karakter!',
                                          ),
                                          backgroundColor:
                                              Colors.orange.shade800,
                                        ),
                                      );
                                      return;
                                    }
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                  : null)),
                  icon:
                      _isSubmitting
                          ? const SizedBox.shrink()
                          : Icon(
                            _currentStep == 2
                                ? Icons.send_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                  label:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            _currentStep == 2 ? 'Kirim Lamaran' : 'Lanjut',
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _detailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardTitle('Data Diri'),
            const SizedBox(height: 14),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: tr('Nama Lengkap')),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Nama lengkap wajib diisi'
                          : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: tr('Nomor Telepon'),
                hintText: tr('+62...'),
              ),
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Nomor telepon wajib diisi'
                          : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _semesterController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: tr('Semester'),
                hintText: tr('Contoh: 6'),
              ),
              validator: (value) {
                final semester = int.tryParse(value?.trim() ?? '');
                if (semester == null) {
                  return tr('Semester harus berupa angka');
                }
                if (semester < 1 || semester > 14) {
                  return tr('Semester harus antara 1 dan 14');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Application Snapshot',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SnapshotRow(
                    label: 'Posisi',
                    value: widget.internship.position,
                  ),
                  _SnapshotRow(
                    label: 'Perusahaan',
                    value: widget.internship.company,
                  ),
                  _SnapshotRow(
                    label: 'Lokasi',
                    value: widget.internship.location,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Berkas'),
          const SizedBox(height: 14),
          _UploadCard(
            title: 'Upload CV / Resume',
            subtitle: 'PDF/DOCX/JPG, Max 5MB',
            icon: Icons.description_outlined,
            actionLabel: _cvFileName == null ? 'Upload' : 'Ganti',
            onAction: _pickCvFile,
            fileName: _cvFileName,
            progress: _cvUploadProgress,
          ),
          const SizedBox(height: 14),
          _PortfolioDropZone(
            selection: _portfolioSelection,
            controller: _portfolioController,
            onTap: _pickPortfolio,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Motivasi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_motivationController.text.length} / 1000',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _motivationController,
                  maxLines: 7,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: tr(
                      'Tuliskan alasan Anda mendaftar (min. 10 karakter)',
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

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Tinjau Lamaran'),
          const SizedBox(height: 14),
          _ReviewCard(
            title: 'Data Diri',
            onEdit:
                () => _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                ),
            children: [
              _SnapshotRow(label: 'Nama', value: _fullNameController.text),
              _SnapshotRow(label: 'Telepon', value: _phoneController.text),
              _SnapshotRow(label: 'Semester', value: _semesterController.text),
            ],
          ),
          const SizedBox(height: 14),
          _ReviewCard(
            title: 'Berkas',
            onEdit:
                () => _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                ),
            children: [
              _SnapshotRow(
                label: 'CV',
                value: _cvFileName ?? 'Belum di-upload',
              ),
              _SnapshotRow(
                label: 'Portofolio',
                value: _portfolioSelection ?? _portfolioController.text,
              ),
              _SnapshotRow(
                label: 'Motivasi',
                value: '${_motivationController.text.length} karakter ditulis',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // FUNGSI INJEKSI: Menggunakan `withData: true` agar file dibaca sebagai bytes memori di Web
  Future<void> _pickCvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true, // WAJIB ADA agar bisa dibaca di Flutter Web
      );

      if (result != null) {
        final platformFile = result.files.single;

        if (platformFile.bytes != null) {
          setState(() {
            _cvBytes = platformFile.bytes;
            _cvFileName = platformFile.name;
            _cvUploadProgress = 1.0;
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membaca isi file. Coba file lain.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat membuka file manager: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _pickPortfolio() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.link_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Gunakan URL Portofolio'),
                subtitle: const Text('Ketik URL secara manual di kolom'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _portfolioBytes = null;
                    _portfolioSelection = 'Link Portfolio';
                  });
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Upload File Portofolio'),
                subtitle: const Text('Pilih file dari memori HP/PC'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx'],
                          withData:
                              true, // WAJIB ADA agar bisa dibaca di Flutter Web
                        );

                    if (result != null) {
                      final platformFile = result.files.single;
                      if (platformFile.bytes != null) {
                        setState(() {
                          _portfolioBytes = platformFile.bytes;
                          _portfolioSelection = platformFile.name;
                          _portfolioController.clear();
                        });
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal membaca isi file portofolio.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal buka file manager: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitApplication(BuildContext context) async {
    if (_cvBytes == null) return;

    final state = NexusScope.of(context);
    if (state.hasAcceptedApplication) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kamu masih memiliki magang aktif. Lamaran baru tidak dapat dikirim.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final token = state.authToken;

    // Mengirim ke API Laravel
    final result = await ApiService.applyInternship(
      token: token ?? '',
      lowonganId: widget.internship.id,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      semester: _semesterController.text.trim(),
      motivation: _motivationController.text.trim(),
      cvBytes: _cvBytes!,
      cvFileName: _cvFileName!,
      portfolioBytes: _portfolioBytes,
      portfolioFileName: _portfolioSelection,
      portfolioLink: _portfolioController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (result['success'] == true) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_draftKey);
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Lamaran berhasil dikirim!')),
      );

      try {
        await state.loadStudentApplications();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(
              'Lamaran tersimpan, tetapi sinkronisasi ulang gagal: $e',
            ),
          ),
        );
      }

      final application = state.currentApplication;
      if (application == null || !mounted) return;

      Navigator.pushReplacement(
        this.context,
        MaterialPageRoute(
          builder: (_) => ApplicationStatusScreen(application: application),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(result['message']), // Tampilkan error asli
          backgroundColor: Colors.red,
          duration: const Duration(
            seconds: 6,
          ), // Durasinya diperlama agar mudah dibaca
        ),
      );
    }
  }

  Widget _cardTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = ['Data Diri', 'Berkas', 'Tinjau'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final lineStep = index ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color:
                  lineStep < currentStep
                      ? AppColors.primary
                      : const Color(0xFFE3DFEB),
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        return Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color:
                    isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isCompleted || isCurrent
                          ? AppColors.primary
                          : const Color(0xFFD9D4E4),
                ),
              ),
              child: Center(
                child:
                    isCompleted
                        ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                        : Text(
                          '${stepIndex + 1}',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: isCurrent ? Colors.white : AppColors.neutral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIndex],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color:
                    isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.neutral,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.neutral,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    required this.fileName,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;
  final String? fileName;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onAction,
                icon: const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (fileName != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                fileName!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: const Color(0xFFE7E1F4),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onAction, child: Text(actionLabel)),
          ),
        ],
      ),
    );
  }
}

class _PortfolioDropZone extends StatelessWidget {
  const _PortfolioDropZone({
    required this.selection,
    required this.controller,
    required this.onTap,
  });

  final String? selection;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Portofolio',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Link atau Dokumen',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selection ?? 'Ketuk untuk melampirkan portofolio',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selection == null
                        ? 'Pilih file atau gunakan URL'
                        : 'Portofolio berhasil dilampirkan',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (selection == 'Link Portfolio') ...[
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: tr('Ketikkan URL Portofolio'),
                hintText: tr('Contoh: behance.net/profil-anda'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.children,
    required this.onEdit,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(onPressed: onEdit, child: const Text('Edit')),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}
