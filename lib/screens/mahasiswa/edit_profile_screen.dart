import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';

class EditMahasiswaProfileScreen extends StatefulWidget {
  const EditMahasiswaProfileScreen({super.key});

  @override
  State<EditMahasiswaProfileScreen> createState() =>
      _EditMahasiswaProfileScreenState();
}

class _EditMahasiswaProfileScreenState
    extends State<EditMahasiswaProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _semesterController;
  late final TextEditingController _phoneController;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user =
        NexusScope.of(context).currentUser ?? const <String, dynamic>{};
    _nameController = TextEditingController(
      text: _profileValue(user, const ['name', 'nama_lengkap', 'nama']),
    );
    _semesterController = TextEditingController(
      text: _profileValue(user, const ['semester']),
    );
    _phoneController = TextEditingController(
      text: _profileValue(user, const ['phone', 'no_telp', 'telepon']),
    );
    _initialized = true;
  }

  String _profileValue(Map<String, dynamic> user, List<String> keys) {
    final profiles = [
      user,
      if (user['data'] is Map) (user['data'] as Map).cast<String, dynamic>(),
      if (user['mahasiswa'] is Map)
        (user['mahasiswa'] as Map).cast<String, dynamic>(),
      if (user['profile'] is Map)
        (user['profile'] as Map).cast<String, dynamic>(),
    ];
    for (final profile in profiles) {
      for (final key in keys) {
        final value = profile[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _semesterController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ProfileField(
              controller: _nameController,
              label: 'Nama lengkap',
              icon: Icons.person_outline_rounded,
              validator:
                  (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Nama lengkap wajib diisi.'
                          : null,
            ),
            const SizedBox(height: 14),
            _ProfileField(
              controller: _semesterController,
              label: 'Semester',
              icon: Icons.school_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                final semester = int.tryParse(value?.trim() ?? '');
                if (semester == null || semester < 1 || semester > 14) {
                  return tr('Semester harus berupa angka 1–14.');
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _ProfileField(
              controller: _phoneController,
              label: 'Nomor telepon',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (!RegExp(r'^[0-9+]{8,15}$').hasMatch(phone)) {
                  return tr('Masukkan nomor telepon yang valid.');
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon:
                  _isSaving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await NexusScope.of(context).updateStudentProfile(
        name: _nameController.text.trim(),
        semester: int.parse(_semesterController.text.trim()),
        phone: _phoneController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(labelText: tr(label), prefixIcon: Icon(icon)),
    );
  }
}
