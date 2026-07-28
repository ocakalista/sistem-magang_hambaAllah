import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pemrog_hambaallah/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    const indonesian = AppLocalizations(Locale('id'));
    const english = AppLocalizations(Locale('en'));

    test('translates common navigation and settings copy', () {
      expect(english.translate('Beranda'), 'Home');
      expect(
        english.translate('Pengaturan Notifikasi'),
        'Notification Settings',
      );
      expect(indonesian.translate('Profile'), 'Profil');
      expect(indonesian.translate('Alerts'), 'Notifikasi');
    });

    test('translates copy for every role', () {
      expect(english.translate('Riwayat Lamaran'), 'Application History');
      expect(english.translate('Kelola Lowongan'), 'Manage Internships');
      expect(english.translate('Mahasiswa Bimbingan'), 'Supervised Students');
      expect(english.translate('Kelola Pengguna'), 'Manage Users');
    });

    test('keeps backend data and names unchanged', () {
      expect(
        english.translate('PT Teknologi Nusantara'),
        'PT Teknologi Nusantara',
      );
      expect(
        indonesian.translate('PT Teknologi Nusantara'),
        'PT Teknologi Nusantara',
      );
    });

    test('translates dynamic templates', () {
      expect(english.translate('Minggu 4'), 'Week 4');
      expect(indonesian.translate('3 Weeks Remaining'), '3 Minggu Tersisa');
    });
  });
}
