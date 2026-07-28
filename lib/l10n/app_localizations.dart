import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('id'), Locale('en')];
  static String currentLanguageCode = 'id';

  static void use(Locale locale) {
    currentLanguageCode = locale.languageCode == 'en' ? 'en' : 'id';
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('id'));
  }

  bool get isEnglish => locale.languageCode == 'en';

  String translate(String source) {
    final exact = (isEnglish ? _english : _indonesian)[source];
    if (exact != null) return exact;
    return _translateTemplates(source);
  }

  String _translateTemplates(String source) {
    var value = source;
    final replacements = isEnglish ? _englishPhrases : _indonesianPhrases;
    for (final entry in replacements.entries) {
      value = value.replaceAll(entry.key, entry.value);
    }
    return value;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, String> _english = {
    'Bahasa': 'Language',
    'Bahasa Indonesia': 'Indonesian',
    'Bahasa Inggris': 'English',
    'Pilih bahasa aplikasi': 'Choose application language',
    'Pengaturan': 'Settings',
    'Pengaturan Notifikasi': 'Notification Settings',
    'Preferensi Notifikasi': 'Notification Preferences',
    'Pilih informasi yang ingin ditampilkan sebagai notifikasi.':
        'Choose which information should appear as notifications.',
    'Logbook disetujui': 'Logbook approved',
    'Pemberitahuan aktivitas persetujuan logbook.':
        'Notifications for logbook approvals.',
    'Permintaan revisi': 'Revision requests',
    'Pemberitahuan logbook yang memerlukan revisi.':
        'Notifications for logbooks that need revision.',
    'Aktivitas mahasiswa': 'Student activity',
    'Logbook baru dari mahasiswa bimbingan.':
        'New logbooks from supervised students.',
    'Pembaruan sistem': 'System updates',
    'Informasi umum dan pembaruan platform.':
        'General information and platform updates.',
    'Preferensi ini tersimpan pada perangkat ini.':
        'These preferences are saved on this device.',
    'Profil': 'Profile',
    'Beranda': 'Home',
    'Lowongan': 'Internships',
    'Lamaran': 'Applications',
    'Logbook': 'Logbook',
    'Mahasiswa': 'Students',
    'Pengguna': 'Users',
    'Keluar': 'Log out',
    'Batal': 'Cancel',
    'Simpan': 'Save',
    'Hapus': 'Delete',
    'Edit': 'Edit',
    'Tutup': 'Close',
    'Kembali': 'Back',
    'Lanjut': 'Continue',
    'Kirim': 'Submit',
    'Cari': 'Search',
    'Muat Ulang': 'Reload',
    'Coba Lagi': 'Try Again',
    'Lihat Semua': 'View All',
    'Lihat Detail': 'View Details',
    'Detail': 'Details',
    'Riwayat': 'History',
    'Lihat Riwayat': 'View History',
    'Notifikasi': 'Notifications',
    'Notifikasi Baru': 'New Notifications',
    'Tandai semua telah dibaca': 'Mark all as read',
    'Belum ada notifikasi': 'No notifications yet',
    'Tidak ada data': 'No data',
    'Data tidak ditemukan': 'Data not found',
    'Terjadi kesalahan': 'Something went wrong',
    'Server tidak merespons. Silakan coba lagi.':
        'The server is not responding. Please try again.',
    'Selamat Datang Kembali': 'Welcome Back',
    'Masuk untuk melanjutkan perjalanan kariermu.':
        'Sign in to continue your career journey.',
    'Email atau NIM': 'Email or Student ID',
    'Kata sandi': 'Password',
    'MASUK KE NEXUS →': 'SIGN IN TO NEXUS →',
    'Enkripsi Aman': 'Secure Encryption',
    'Tersertifikasi Amikom': 'Amikom Certified',
    'Email wajib diisi': 'Email is required',
    'Kata sandi wajib diisi': 'Password is required',
    'Login gagal': 'Sign in failed',
    'Selamat datang': 'Welcome',
    'Temukan kesempatan terbaik untuk masa depanmu.':
        'Find the best opportunity for your future.',
    'Cari lowongan...': 'Search internships...',
    'Lowongan Terbaru': 'Latest Internships',
    'Lowongan Tersimpan': 'Saved Internships',
    'Semua Lowongan': 'All Internships',
    'Belum ada lowongan tersedia': 'No internships available yet',
    'Belum ada lowongan tersimpan': 'No saved internships yet',
    'Deskripsi Pekerjaan': 'Job Description',
    'Persyaratan': 'Requirements',
    'Benefit': 'Benefits',
    'Daftar Sekarang': 'Apply Now',
    'Salin info lowongan': 'Copy internship information',
    'Informasi lowongan disalin': 'Internship information copied',
    'Daftar Magang': 'Internship Application',
    'Data Diri': 'Personal Details',
    'Nama Lengkap': 'Full Name',
    'Nama lengkap wajib diisi': 'Full name is required',
    'Nomor Telepon': 'Phone Number',
    'Nomor telepon wajib diisi': 'Phone number is required',
    'Semester': 'Semester',
    'Contoh: 6': 'Example: 6',
    'Berkas': 'Documents',
    'Upload CV': 'Upload CV',
    'Upload Portofolio': 'Upload Portfolio',
    'Link atau Dokumen': 'Link or Document',
    'Ketuk untuk melampirkan portofolio': 'Tap to attach your portfolio',
    'Ganti': 'Replace',
    'Belum di-upload': 'Not uploaded',
    'Motivasi': 'Motivation',
    'Surat Motivasi': 'Motivation Letter',
    'Tinjau Lamaran': 'Review Application',
    'Posisi': 'Position',
    'Perusahaan': 'Company',
    'Lokasi': 'Location',
    'Kirim Lamaran': 'Submit Application',
    'Simpan Draft': 'Save Draft',
    'Lamaran berhasil dikirim': 'Application submitted successfully',
    'Belum ada lamaran.': 'No applications yet.',
    'Perkembangan Lamaran': 'Application Progress',
    'Riwayat Aktivitas': 'Activity History',
    'Lamaran Dikirim': 'Application Submitted',
    'Sedang Ditinjau': 'Under Review',
    'Sesi Wawancara': 'Interview Session',
    'Keputusan Akhir': 'Final Decision',
    'CATATAN LAMARAN': 'APPLICATION NOTES',
    'Informasi dari mitra akan tampil di sini':
        'Information from the partner will appear here',
    'Riwayat Lamaran': 'Application History',
    'Belum ada riwayat lamaran': 'No application history yet',
    'Belum ada magang aktif.': 'No active internship yet.',
    'Linimasa Mingguan': 'Weekly Timeline',
    'Progres Magang': 'Internship Progress',
    'Minggu Ini': 'This Week',
    'Selesai': 'Completed',
    'Menunggu': 'Pending',
    'Disetujui': 'Approved',
    'Revisi': 'Revision',
    'Belum Dikerjakan': 'Not Started',
    'Detail Logbook': 'Logbook Details',
    'Aktivitas': 'Activity',
    'Hasil Pekerjaan': 'Work Results',
    'Kendala': 'Challenges',
    'Rencana Selanjutnya': 'Next Plan',
    'Kirim Logbook': 'Submit Logbook',
    'Logbook berhasil dikirim': 'Logbook submitted successfully',
    'Edit Profil': 'Edit Profile',
    'Program Studi': 'Study Program',
    'Simpan Perubahan': 'Save Changes',
    'Profil berhasil diperbarui': 'Profile updated successfully',
    'Dashboard Admin': 'Admin Dashboard',
    'Total Pengguna': 'Total Users',
    'Magang Aktif': 'Active Internships',
    'Persetujuan Lowongan': 'Internship Approvals',
    'Menunggu Persetujuan': 'Awaiting Approval',
    'Setujui': 'Approve',
    'Tolak': 'Reject',
    'Alasan Penolakan': 'Rejection Reason',
    'Masukkan alasan penolakan': 'Enter rejection reason',
    'Kelola Pengguna': 'Manage Users',
    'Tambah Pengguna': 'Add User',
    'Detail Pengguna': 'User Details',
    'Peran': 'Role',
    'Status': 'Status',
    'Aktif': 'Active',
    'Tidak Aktif': 'Inactive',
    'Pendaftaran Mahasiswa': 'Student Enrollments',
    'Dashboard Dosen': 'Lecturer Dashboard',
    'Mahasiswa Bimbingan': 'Supervised Students',
    'Perlu Persetujuan': 'Needs Approval',
    'Magang Selesai': 'Completed Internships',
    'Magang Berjalan': 'Ongoing Internships',
    'Laporan Terbaru': 'Recent Reports',
    'Belum ada mahasiswa bimbingan': 'No supervised students yet',
    'Profil Mahasiswa': 'Student Profile',
    'Laporan Mingguan': 'Weekly Report',
    'Isi Laporan': 'Report Content',
    'Umpan Balik': 'Feedback',
    'Berikan umpan balik': 'Provide feedback',
    'Setujui Laporan': 'Approve Report',
    'Minta Revisi': 'Request Revision',
    'Laporan berhasil disetujui': 'Report approved successfully',
    'Permintaan revisi berhasil dikirim': 'Revision request sent successfully',
    'Dashboard Mitra': 'Partner Dashboard',
    'Kelola Lowongan': 'Manage Internships',
    'Draft Lowongan': 'Internship Drafts',
    'Pelamar': 'Applicants',
    'Total Lowongan': 'Total Internships',
    'Total Pelamar': 'Total Applicants',
    'Lowongan Aktif': 'Active Internships',
    'Belum ada lowongan': 'No internships yet',
    'Belum ada pelamar': 'No applicants yet',
    'Detail Lowongan': 'Internship Details',
    'Judul Lowongan': 'Internship Title',
    'Kategori': 'Category',
    'Tipe Pekerjaan': 'Work Type',
    'Tipe Kontrak': 'Contract Type',
    'Jarak Jauh': 'Remote',
    'Di Lokasi': 'On-site',
    'Hibrida': 'Hybrid',
    'Penuh Waktu': 'Full-time',
    'Paruh Waktu': 'Part-time',
    'Berbasis Proyek': 'Project-based',
    'Teknik': 'Engineering',
    'Bisnis': 'Business',
    'Pemasaran': 'Marketing',
    'Lainnya': 'Other',
    'Uang Saku Kompetitif': 'Competitive Allowance',
    'Program Mentoring': 'Mentoring Program',
    'Peluang Kerja Penuh Waktu': 'Full-time Opportunity',
    'Sertifikat': 'Certificate',
    'Publikasikan Lowongan': 'Publish Internship',
    'Simpan sebagai Draft': 'Save as Draft',
    'Lowongan berhasil dibuat': 'Internship created successfully',
    'Detail Pelamar': 'Applicant Details',
    'Terima': 'Accept',
    'Diterima': 'Accepted',
    'Ditolak': 'Rejected',
    'Pendidikan': 'Education',
    'Pengalaman': 'Experience',
    'Keahlian': 'Skills',
    'Portofolio': 'Portfolio',
    'Akun & preferensi': 'Account & preferences',
    'Ajukan Lowongan': 'Submit Internship',
    'Bangun langkah awal karier bersama ekosistem magang Universitas Amikom Yogyakarta.':
        'Take your first career step with the Universitas Amikom Yogyakarta internship ecosystem.',
    'Belum ada data enrollment.': 'No enrollment data yet.',
    'Belum ada draft lowongan.': 'No internship drafts yet.',
    'Belum ada feedback dari dosen pembimbing.':
        'No feedback from the supervising lecturer yet.',
    'Belum ada lamaran magang.': 'No internship applications yet.',
    'Belum ada lowongan magang tersedia.':
        'No internship openings available yet.',
    'Belum ada mahasiswa bimbingan.': 'No supervised students yet.',
    'Belum ada mahasiswa yang melamar.': 'No students have applied yet.',
    'Belum ada mahasiswa yang mendaftar.': 'No students have registered yet.',
    'Belum ada pendaftar terbaru.': 'No recent applicants.',
    'Belum ada pengguna di kategori ini.': 'No users in this category.',
    'Belum ada weekly report.': 'No weekly reports yet.',
    'Belum dikirim': 'Not submitted',
    'Belum tersedia.': 'Not available yet.',
    'Biasanya ditinjau dalam 1-2 hari.': 'Usually reviewed within 1–2 days.',
    'Buka PDF Logbook': 'Open Logbook PDF',
    'Cari Lowongan Magang': 'Search Internships',
    'Cari mahasiswa atau posisi...': 'Search students or positions...',
    'Cari mahasiswa, posisi, atau perusahaan...':
        'Search students, positions, or companies...',
    'Cari mahasiswa...': 'Search students...',
    'Cari nama atau NIDN dosen...': 'Search lecturer name or lecturer ID...',
    'Cari nama atau NIM mahasiswa...': 'Search student name or student ID...',
    'Cari nama perusahaan mitra...': 'Search partner company name...',
    'Cari posisi, perusahaan, atau lokasi...':
        'Search positions, companies, or locations...',
    'CV tersedia di server': 'CV available on the server',
    'CV tidak tersedia': 'CV unavailable',
    'Daftar Pendaftar': 'Applicant List',
    'Data akun': 'Account data',
    'Data Diri Mahasiswa': 'Student Personal Data',
    'Data pendaftar belum ditemukan. Muat ulang Home.':
        'Applicant data was not found. Reload Home.',
    'Deskripsi belum diisi.': 'Description has not been added.',
    'Deskripsi belum tersedia.': 'Description unavailable.',
    'Deskripsi kegiatan': 'Activity description',
    'Deskripsi minimal 20 karakter':
        'Description must be at least 20 characters',
    'Deskripsi Posisi': 'Position Description',
    'Deskripsi wajib diisi': 'Description is required',
    'Detail Magang': 'Internship Details',
    'Detail Pendaftar': 'Applicant Details',
    'Dibuat pada': 'Created on',
    'Disetujui dosen': 'Approved by lecturer',
    'Dokumen laporan mingguan': 'Weekly report document',
    'Dokumen tidak dapat dibuka.': 'The document could not be opened.',
    'Dosen Pembimbing': 'Supervising Lecturer',
    'Dosen pembimbing belum ditentukan.':
        'A supervising lecturer has not been assigned.',
    'Draft disimpan. Buka ikon draft di kanan atas.':
        'Draft saved. Open the draft icon at the top right.',
    'Draft tanpa judul': 'Untitled draft',
    'Draft tersimpan. Buka lowongan ini lagi untuk melanjutkan; file perlu dipilih ulang.':
        'Draft saved. Open this internship again to continue; files must be selected again.',
    'Email / NIDN': 'Email / Lecturer ID',
    'Email / NIM': 'Email / Student ID',
    'Feedback Dosen Pembimbing': 'Supervising Lecturer Feedback',
    'File CV belum di-upload!': 'The CV has not been uploaded!',
    'File Laporan': 'Report File',
    'Filter kategori': 'Filter category',
    'Fitur ini belum tersedia di backend.':
        'This feature is not yet available on the backend.',
    'Format PDF, maksimal 5 MB.': 'PDF format, maximum 5 MB.',
    'Gagal membaca isi file portofolio.': 'Failed to read the portfolio file.',
    'Gagal membaca isi file. Coba file lain.':
        'Failed to read the file. Try another file.',
    'Gagal memuat lowongan': 'Failed to load internships',
    'Gagal memuat profil admin': 'Failed to load admin profile',
    'Gagal terhubung ke server Railway.':
        'Failed to connect to the Railway server.',
    'Geser untuk melihat lainnya': 'Swipe to see more',
    'Hapus pencarian': 'Clear search',
    'Harap isi email/NIM dan password':
        'Please enter your email/student ID and password',
    'Hasil akhir dan informasi lanjutan akan ditampilkan di sini.':
        'The final result and further information will appear here.',
    'Informasi Dasar': 'Basic Information',
    'Insight Mingguan': 'Weekly Insight',
    'Isi Logbook': 'Fill Logbook',
    'Isi Logbook Mingguan': 'Fill Weekly Logbook',
    'Isi minggu, tanggal, dan deskripsi kegiatan':
        'Enter the week, date, and activity description',
    'Isi URL portofolio atau upload filenya!':
        'Enter a portfolio URL or upload the file!',
    'Ikuti arahan mitra': 'Follow the partner’s instructions',
    'Info lowongan disalin.': 'Internship information copied.',
    'Judul Posisi': 'Position Title',
    'Judul posisi wajib diisi': 'Position title is required',
    'Kamu dapat mendaftar ke lowongan lain yang tersedia.':
        'You can apply to other available internships.',
    'Kamu masih memiliki magang aktif. Lamaran baru tidak dapat dikirim.':
        'You still have an active internship. A new application cannot be submitted.',
    'Kamu masih memiliki magang aktif. Selesaikan magang tersebut sebelum mendaftar lagi.':
        'You still have an active internship. Complete it before applying again.',
    'KAPASITAS KUOTA': 'CAPACITY',
    'Kegiatan Mingguan': 'Weekly Activity',
    'Kelola semua aplikasi magangmu dalam satu tempat agar proses seleksi lebih terarah dan mudah dipantau.':
        'Manage all your internship applications in one place for a clearer and easier selection process.',
    'Keputusan akhir biasanya muncul setelah proses wawancara.':
        'The final decision usually appears after the interview process.',
    'Ketik URL secara manual di kolom': 'Enter the URL manually',
    'Ketikkan URL Portofolio': 'Enter Portfolio URL',
    'Konfirmasi Tolak': 'Confirm Rejection',
    'Kuota Peserta': 'Participant Quota',
    'Lamaran berhasil dikirim!': 'Application submitted successfully!',
    'Lamaran dikirim': 'Application submitted',
    'Lamaran diterima': 'Application accepted',
    'Lamaran ditolak': 'Application rejected',
    'Lamaran magangmu sudah berhasil diterima.':
        'Your internship application has been accepted.',
    'Lamaran masuk': 'Incoming applications',
    'Lamaranmu belum terpilih pada periode ini. Kamu masih bisa mencoba lowongan lain.':
        'Your application was not selected for this period. You can still try other internships.',
    'Lengkapi semua data yang wajib diisi.':
        'Complete all required information.',
    'Lihat draft': 'View draft',
    'Lihat portofolio': 'View portfolio',
    'Logbook berhasil dikirim.': 'Logbook submitted successfully.',
    'Logbook tidak ditemukan pada daftar mahasiswa bimbingan.':
        'The logbook was not found in the supervised student list.',
    'Login Berhasil!': 'Sign in successful!',
    'Lokasi wajib diisi': 'Location is required',
    'Kategori wajib dipilih': 'Category is required',
    'Alasan': 'Reason',
    'Lowongan berhasil diajukan!': 'Internship submitted successfully!',
    'Lowongan disetujui.': 'Internship approved.',
    'Lowongan ditolak.': 'Internship rejected.',
    'Lowongan Mitra': 'Partner Internships',
    'Lowongan tidak ditemukan.': 'Internship not found.',
    'Lowongan yang Dilamar': 'Applied Internship',
    'Magang Penuh Waktu': 'Full-time Internship',
    'Magang Sedang Aktif': 'Active Internship',
    'Mahasiswa belum memiliki riwayat lamaran.':
        'The student has no application history yet.',
    'Masuk untuk mengelola proses magang Universitas Amikom':
        'Sign in to manage the Universitas Amikom internship process',
    'Masukkan alasan penolakan:': 'Enter the rejection reason:',
    'Masukkan nomor telepon yang valid.': 'Enter a valid phone number.',
    'Menunggu pembaruan': 'Awaiting update',
    'Menunggu persetujuan admin.': 'Awaiting admin approval.',
    'Menunggu persetujuan dosen': 'Awaiting lecturer approval',
    'Menunggu review': 'Awaiting review',
    'Minggu ke': 'Week',
    'Minggu, deskripsi, dan PDF wajib diisi.':
        'Week, description, and PDF are required.',
    'Mitra belum memiliki lowongan.': 'The partner has no internships yet.',
    'Motivasi belum tersedia pada respons daftar pelamar dari server.':
        'Motivation is unavailable in the applicant-list response from the server.',
    'Motivasi minimal 10 karakter!':
        'Motivation must be at least 10 characters!',
    'Nama dosen belum tersedia': 'Lecturer name unavailable',
    'Nama lengkap wajib diisi.': 'Full name is required.',
    'Nama Perusahaan': 'Company Name',
    'NIM / ID Mahasiswa': 'Student ID',
    'Nomor telepon': 'Phone number',
    'Notifikasi belum memiliki ID logbook.':
        'The notification does not have a logbook ID.',
    'Pantau perkembangan lamaranmu secara berkala. Jika ada pesan atau catatan dari mitra, informasi tersebut akan muncul pada bagian ini.':
        'Check your application progress regularly. Messages or notes from the partner will appear here.',
    'Pantau perkembangan mahasiswa bimbinganmu hari ini.':
        'Monitor your supervised students’ progress today.',
    'Pantau Progress Lamaran': 'Track Application Progress',
    'PDF logbook tidak dapat dibuka.': 'The logbook PDF could not be opened.',
    'PDF tidak tersedia': 'PDF unavailable',
    'Pendaftar Baru': 'New Applicants',
    'Pendaftar Lowongan': 'Internship Applicants',
    'Pendaftar Terbaru': 'Recent Applicants',
    'Pengguna tidak ditemukan.': 'User not found.',
    'Periode Mulai': 'Start Date',
    'Periode Selesai': 'End Date',
    'Perlu Perhatian': 'Needs Attention',
    'Perlu revisi': 'Needs revision',
    'Pilih file atau gunakan URL': 'Choose a file or use a URL',
    'Pilih file dari memori HP/PC': 'Choose a file from your phone/computer',
    'Pilih PDF Logbook': 'Choose Logbook PDF',
    'Pilih tanggal': 'Choose date',
    'Portofolio berhasil dilampirkan': 'Portfolio attached successfully',
    'Portofolio tidak tersedia': 'Portfolio unavailable',
    'Posisi belum tersedia': 'Position unavailable',
    'Profil admin': 'Admin profile',
    'Profil berhasil diperbarui.': 'Profile updated successfully.',
    'Profil Dosen ini akan dikembangkan lebih lanjut untuk menampilkan data bimbingan dan jumlah mahasiswa.':
        'This lecturer profile will be expanded to show supervision data and student counts.',
    'Profil ini akan dikembangkan lebih lanjut untuk Mahasiswa.':
        'This profile will be expanded further for students.',
    'Program belum tersedia': 'Program unavailable',
    'Progress Magang': 'Internship Progress',
    'Progress Real-Time': 'Real-Time Progress',
    'Proses tinjauan biasanya memerlukan 3-4 hari.':
        'The review process usually takes 3–4 days.',
    'Riwayat Weekly Logbook': 'Weekly Logbook History',
    'Riwayat Weekly Report': 'Weekly Report History',
    'Semester harus antara 1 dan 14': 'Semester must be between 1 and 14',
    'Semester harus berupa angka': 'Semester must be a number',
    'Semester harus berupa angka 1–14.': 'Semester must be a number from 1–14.',
    'Semua kategori': 'All categories',
    'Semua Pendaftar': 'All Applicants',
    'Sesi admin tidak tersedia.': 'Admin session unavailable.',
    'Sesi login tidak tersedia.': 'Login session unavailable.',
    'Sesuai Jadwal': 'On Track',
    'Siap Terhubung ke Industri': 'Ready to Connect with Industry',
    'Siapkan dokumen pendukung dan pastikan kontakmu aktif selama proses seleksi.':
        'Prepare supporting documents and keep your contact information active during selection.',
    'Silakan ajukan lowongan baru dari dashboard atau tunggu persetujuan admin.':
        'Submit a new internship from the dashboard or wait for admin approval.',
    'Status berhasil disinkronkan.': 'Status synchronized successfully.',
    'Status ini berasal dari data backend terbaru.':
        'This status comes from the latest backend data.',
    'Status lowongan': 'Internship status',
    'Tambah Lowongan': 'Add Internship',
    'Tambahkan benefit': 'Add benefit',
    'Tambahkan persyaratan': 'Add requirement',
    'Tambahkan setidaknya satu persyaratan.': 'Add at least one requirement.',
    'Tanggal daftar': 'Application date',
    'Temukan peluang magang terbaik dari perusahaan ternama yang sesuai dengan minat dan bakatmu.':
        'Find the best internship opportunities from leading companies that match your interests and talents.',
    'Terakhir diperbarui': 'Last updated',
    'Terhubung AMIKOM': 'Connected to AMIKOM',
    'Tidak ada informasi benefit tambahan.':
        'No additional benefit information.',
    'Tidak ada lowongan di kategori ini.': 'No internships in this category.',
    'Tidak ada notifikasi baru': 'No new notifications',
    'Tidak ada pendaftar.': 'No applicants.',
    'Tidak ada persyaratan khusus yang dicantumkan.':
        'No specific requirements were listed.',
    'Tim mitra akan menghubungi kamu jika perlu sesi wawancara.':
        'The partner team will contact you if an interview is needed.',
    'Tim sedang memeriksa CV, portofolio, dan kecocokanmu dengan posisi ini.':
        'The team is reviewing your CV, portfolio, and fit for this position.',
    'TINDAK LANJUT': 'NEXT STEPS',
    'Tinjau Lowongan': 'Review Internship',
    'Tipe kerja': 'Work type',
    'Token admin tidak tersedia. Silakan login ulang.':
        'Admin token unavailable. Please sign in again.',
    'Token tidak tersedia. Silakan login ulang.':
        'Token unavailable. Please sign in again.',
    'Tolak Lowongan': 'Reject Internship',
    'Tuliskan alasan Anda mendaftar (min. 10 karakter)':
        'Write why you are applying (min. 10 characters)',
    'Ukuran PDF maksimal 5 MB.': 'Maximum PDF size is 5 MB.',
    'Undangan wawancara biasanya dikirim dalam satu minggu.':
        'Interview invitations are usually sent within one week.',
    'Upload CV / Resume': 'Upload CV / Resume',
    'Upload File Portofolio': 'Upload Portfolio File',
    'Upload Laporan Mingguan': 'Upload Weekly Report',
  };

  static final Map<String, String> _indonesian = {
    for (final entry in _english.entries) entry.value: entry.key,
    'Invalid report data': 'Data laporan tidak valid',
    'Profile': 'Profil',
    'Home': 'Beranda',
    'Internships': 'Lowongan',
    'Applications': 'Lamaran',
    'Users': 'Pengguna',
    'Logout': 'Keluar',
    'Cancel': 'Batal',
    'Save': 'Simpan',
    'Delete': 'Hapus',
    'Edit': 'Edit',
    'Close': 'Tutup',
    'Back': 'Kembali',
    'Continue': 'Lanjut',
    'Submit': 'Kirim',
    'Search': 'Cari',
    'Reload': 'Muat Ulang',
    'Try Again': 'Coba Lagi',
    'View Details': 'Lihat Detail',
    'Details': 'Detail',
    'History': 'Riwayat',
    'Notifications': 'Notifikasi',
    'Alerts': 'Notifikasi',
    'Students': 'Mahasiswa',
    'Active Internships': 'Magang Aktif',
    'ADMIN CONTROL CENTER': 'PUSAT KONTROL ADMIN',
    'Admin ID': 'ID Admin',
    'Application Snapshot': 'Ringkasan Lamaran',
    'Application Timeline': 'Linimasa Lamaran',
    'Approve Report': 'Setujui Laporan',
    'Approve Weekly Report': 'Setujui Laporan Mingguan',
    'Are you sure you want to reject this listing request?':
        'Apakah Anda yakin ingin menolak pengajuan lowongan ini?',
    'Earlier Today': 'Sebelumnya Hari Ini',
    'Enter rejection reason...': 'Masukkan alasan penolakan...',
    'Good work this week': 'Kerja bagus minggu ini',
    'HIGH PRIORITY': 'PRIORITAS TINGGI',
    'Internship Distribution': 'Distribusi Magang',
    'Internship Offer': 'Tawaran Magang',
    'INTERNSHIP PORTAL': 'PORTAL MAGANG',
    'Internship Progress': 'Progres Magang',
    'Just now': 'Baru saja',
    'Lecturer Feedback': 'Umpan Balik Dosen',
    'Logbook Approved': 'Logbook Disetujui',
    'Mark all as read': 'Tandai semua telah dibaca',
    'My Internship': 'Magang Saya',
    'Needs Attention': 'Perlu Perhatian',
    'New Notifications': 'Notifikasi Baru',
    'No pending approvals': 'Tidak ada persetujuan tertunda',
    'No pending requests': 'Tidak ada pengajuan tertunda',
    'No reports yet': 'Belum ada laporan',
    'No students enrolled yet': 'Belum ada mahasiswa terdaftar',
    'On Track': 'Sesuai Jadwal',
    'Ongoing applications': 'Lamaran berjalan',
    'Pending Approvals': 'Persetujuan Tertunda',
    'Pending Lowongan': 'Lowongan Tertunda',
    'Platform Overview': 'Ringkasan Platform',
    'Please add feedback before approving':
        'Tambahkan umpan balik sebelum menyetujui',
    'Please provide a rejection reason': 'Masukkan alasan penolakan',
    'Powered by Amikom': 'Didukung oleh Amikom',
    'Ready to jumpstart your career today?': 'Siap memulai kariermu hari ini?',
    'Reason for rejection': 'Alasan penolakan',
    'Recent Activity': 'Aktivitas Terbaru',
    'Recent Weekly Reports': 'Laporan Mingguan Terbaru',
    'Recommended for You': 'Rekomendasi Untukmu',
    'Registration Status': 'Status Pendaftaran',
    'Reject Listing Request': 'Tolak Pengajuan Lowongan',
    'Reject Weekly Report': 'Tolak Laporan Mingguan',
    'Report approved successfully': 'Laporan berhasil disetujui',
    'Report rejected': 'Laporan ditolak',
    'Search internships...': 'Cari lowongan...',
    'See all': 'Lihat semua',
    'Student Enrollment': 'Pendaftaran Mahasiswa',
    'Total Approval Needed': 'Total Persetujuan Diperlukan',
    'Total Users': 'Total Pengguna',
    'View All': 'Lihat Semua',
    'Weekly Report': 'Laporan Mingguan',
    'Write your feedback...': 'Tulis umpan balik...',
    'Behind': 'Tertinggal',
    'APPROVED': 'DISETUJUI',
    'REVISION': 'REVISI',
    'ONGOING': 'BERJALAN',
    'WAITING': 'MENUNGGU',
  };

  static const Map<String, String> _englishPhrases = {
    'Minggu ': 'Week ',
    ' minggu': ' weeks',
    ' bulan': ' months',
    ' hari lalu': ' days ago',
    ' jam lalu': ' hours ago',
    ' menit lalu': ' minutes ago',
    'di ': 'at ',
    'karakter ditulis': 'characters written',
    'Pelamar ': 'Applicant ',
    ' Selesai': ' Completed',
    ' Minggu Tersisa': ' Weeks Remaining',
    ' mahasiswa magang aktif.': ' active internship students.',
    ' dari kemarin': ' from yesterday',
    ' BARU': ' NEW',
    'Mei': 'May',
  };

  static const Map<String, String> _indonesianPhrases = {
    'Week ': 'Minggu ',
    ' weeks': ' minggu',
    ' months': ' bulan',
    ' days ago': ' hari lalu',
    ' hours ago': ' jam lalu',
    ' minutes ago': ' menit lalu',
    'Invalid report data': 'Data laporan tidak valid',
    'Please revise: ': 'Mohon revisi: ',
    'Applicant ': 'Pelamar ',
    ' Completed': ' Selesai',
    ' Weeks Remaining': ' Minggu Tersisa',
    ' active internship students.': ' mahasiswa magang aktif.',
    ' from yesterday': ' dari kemarin',
    ' NEW': ' BARU',
    'May': 'Mei',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale).._activate());

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension on AppLocalizations {
  void _activate() => AppLocalizations.use(locale);
}

String tr(String source) {
  return AppLocalizations(
    Locale(AppLocalizations.currentLanguageCode),
  ).translate(source);
}
