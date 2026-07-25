import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_model.dart';
import '../../models/mitra_model.dart';
import '../../models/mitra_provider.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';
import '../../services/lowongan_draft_service.dart';
import 'lowongan_drafts_screen.dart';

class TambahLowonganScreen extends StatefulWidget {
  static const routeName = '/mitra/tambah-lowongan';

  const TambahLowonganScreen({super.key});

  @override
  State<TambahLowonganScreen> createState() => _TambahLowonganScreenState();
}

class _TambahLowonganScreenState extends State<TambahLowonganScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _namaPerusahaanController = TextEditingController();
  bool _companyInitialized = false;
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _requirementController = TextEditingController();
  final _benefitController = TextEditingController();

  String? _selectedKategori;
  String _selectedTipeKerja = 'Remote';
  String _selectedTipeKontrak = 'Full-time';
  DateTime? _periodeMulai;
  DateTime? _periodeSelesai;
  int _kuota = 1;
  final List<String> _requirements = [];
  final List<String> _benefits = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_companyInitialized) {
      _companyInitialized = true;
      _namaPerusahaanController.text =
          context.read<MitraProvider>().info.companyName;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _namaPerusahaanController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _requirementController.dispose();
    _benefitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<MitraProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Tambah Lowongan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Lihat draft',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LowonganDraftsScreen(),
                  ),
                ),
            icon: const Icon(Icons.drafts_outlined),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              _sectionTitle(context, 'Informasi Dasar'),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _judulController,
                label: 'Judul Posisi',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Judul posisi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _namaPerusahaanController,
                label: 'Nama Perusahaan',
                readOnly: true,
                fillColor: const Color(0xFFF4F2FF),
              ),
              const SizedBox(height: 14),
              _buildDropdown(context),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _lokasiController,
                label: 'Lokasi',
                prefixIcon: const Icon(Icons.location_on_outlined),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Lokasi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildChipSelector(
                title: 'Tipe Kerja',
                options: const ['Remote', 'On-site', 'Hybrid'],
                selected: _selectedTipeKerja,
                onSelected:
                    (value) => setState(() => _selectedTipeKerja = value),
              ),
              const SizedBox(height: 14),
              _buildChipSelector(
                title: 'Tipe Kontrak',
                options: const ['Full-time', 'Part-time', 'Project-based'],
                selected: _selectedTipeKontrak,
                onSelected:
                    (value) => setState(() => _selectedTipeKontrak = value),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Detail Magang'),
              const SizedBox(height: 14),
              _buildDateRangePickers(context),
              const SizedBox(height: 14),
              _buildKuotaStepper(),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _deskripsiController,
                label: 'Deskripsi Posisi',
                maxLines: 6,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Deskripsi wajib diisi';
                  }
                  if ((value?.trim().length ?? 0) < 20) {
                    return 'Deskripsi minimal 20 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_deskripsiController.text.length}/1000',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Persyaratan'),
              const SizedBox(height: 14),
              _buildDynamicListField(
                controller: _requirementController,
                label: 'Tambahkan persyaratan',
                onAdd: _addRequirement,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _requirements
                        .map(
                          (item) => Chip(
                            label: Text(item),
                            onDeleted:
                                () =>
                                    setState(() => _requirements.remove(item)),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),
              _sectionTitle(context, 'Benefit'),
              const SizedBox(height: 14),
              _buildDynamicListField(
                controller: _benefitController,
                label: 'Tambahkan benefit',
                onAdd: _addBenefit,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _benefits
                        .map(
                          (item) => Chip(
                            label: Text(item),
                            onDeleted:
                                () => setState(() => _benefits.remove(item)),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _SuggestionChip(label: 'Competitive Stipend'),
                  _SuggestionChip(label: 'Mentorship Program'),
                  _SuggestionChip(label: 'Full-time Offer'),
                  _SuggestionChip(label: 'Certificate'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: AppColors.white,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await LowonganDraftService.save({
                    'judul_posisi': _judulController.text.trim(),
                    'nama_perusahaan': _namaPerusahaanController.text.trim(),
                    'kategori': _selectedKategori,
                    'lokasi': _lokasiController.text.trim(),
                    'tipe_kerja': _selectedTipeKerja,
                    'tipe_kontrak': _selectedTipeKontrak,
                    'periode_mulai': _periodeMulai?.toIso8601String(),
                    'periode_selesai': _periodeSelesai?.toIso8601String(),
                    'kuota': _kuota,
                    'deskripsi': _deskripsiController.text.trim(),
                    'persyaratan': _requirements,
                    'benefit': _benefits,
                    'saved_at': DateTime.now().toIso8601String(),
                  });
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Draft disimpan. Buka ikon draft di kanan atas.',
                      ),
                    ),
                  );
                },
                child: const Text('Simpan Draft'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _submitForm(context, state),
                child: const Text('Ajukan Lowongan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    Icon? prefixIcon,
    bool readOnly = false,
    Color? fillColor,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: fillColor,
      ),
      onChanged: (_) {
        if (maxLines > 1) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedKategori,
      items: const [
        DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
        DropdownMenuItem(value: 'Design', child: Text('Design')),
        DropdownMenuItem(value: 'Business', child: Text('Business')),
        DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      decoration: const InputDecoration(labelText: 'Kategori'),
      onChanged: (value) {
        setState(() {
          _selectedKategori = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Kategori wajib dipilih';
        }
        return null;
      },
    );
  }

  Widget _buildChipSelector({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              options.map((option) {
                final active = option == selected;
                return ChoiceChip(
                  label: Text(option),
                  selected: active,
                  onSelected: (_) => onSelected(option),
                  selectedColor: AppColors.primary,
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: active ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: const Color(0xFFF4EFFB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangePickers(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            context,
            label: 'Periode Mulai',
            date: _periodeMulai,
            onTap: () => _pickDate(context, true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateField(
            context,
            label: 'Periode Selesai',
            date: _periodeSelesai,
            onTap: () => _pickDate(context, false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_rounded),
        ),
        child: Text(
          date != null ? _formatDate(date) : 'Pilih tanggal',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildKuotaStepper() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Kuota Peserta',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded),
                onPressed: _kuota > 1 ? () => setState(() => _kuota--) : null,
              ),
              Text(
                _kuota.toString(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => setState(() => _kuota++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicListField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(onPressed: onAdd, child: const Text('Tambah')),
      ],
    );
  }

  void _addRequirement() {
    final value = _requirementController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _requirements.add(value);
      _requirementController.clear();
    });
  }

  void _addBenefit() {
    final value = _benefitController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _benefits.add(value);
      _benefitController.clear();
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isStart
              ? (_periodeMulai ?? initialDate)
              : (_periodeSelesai ?? initialDate.add(const Duration(days: 30))),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _periodeMulai = picked;
      } else {
        _periodeSelesai = picked;
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _submitForm(BuildContext context, MitraProvider state) async {
    if (!_formKey.currentState!.validate() ||
        _periodeMulai == null ||
        _periodeSelesai == null) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data yang wajib diisi.')),
      );
      return;
    }

    if (_requirements.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Tambahkan setidaknya satu persyaratan.')),
      );
      return;
    }

    final lowongan = LowonganMitra(
      id: 'new-lowongan',
      position: _judulController.text.trim(),
      category: _selectedKategori ?? 'Other',
      location: _lokasiController.text.trim(),
      tags: [_selectedTipeKerja, _selectedTipeKontrak],
      period:
          '${_formatDate(_periodeMulai!)} - ${_formatDate(_periodeSelesai!)}',
      quota: _kuota,
      applicantCount: 0,
      description: _deskripsiController.text.trim(),
      requirements: List<String>.from(_requirements),
      benefits: List<String>.from(_benefits),
      approvalStatus: LowonganApprovalStatus.pending,
      deadline: _periodeSelesai!.add(const Duration(days: 7)),
    );

    final token = NexusScope.of(context).authToken;
    if (token == null) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Sesi login tidak tersedia.')),
      );
      return;
    }
    try {
      await state.tambahLowongan(token, {
        'judul_posisi': lowongan.position,
        'deskripsi': lowongan.description,
        'persyaratan': lowongan.requirements.join('\n'),
        'kategori': lowongan.category,
        'lokasi': lowongan.location,
        'tipe_kerja': _selectedTipeKerja,
        'tipe_kontrak': _selectedTipeKontrak,
        'benefit': lowongan.benefits.join('\n'),
        'kuota': lowongan.quota,
        'batas_waktu': _periodeSelesai!.toIso8601String().split('T').first,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!mounted) return;
    showDialog<void>(
      context: this.context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lowongan berhasil diajukan!'),
          content: const Text('Menunggu persetujuan admin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.bodyMedium,
      backgroundColor: AppColors.background,
      onPressed: () {},
    );
  }
}
