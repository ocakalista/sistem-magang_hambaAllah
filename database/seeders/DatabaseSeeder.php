<?php

namespace Database\Seeders;

use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Clear old data safely
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        DB::table('logbook')->truncate();
        DB::table('bimbingan')->truncate();
        DB::table('pendaftaran')->truncate();
        DB::table('lowongan')->truncate();
        DB::table('mitra')->truncate();
        DB::table('dosen')->truncate();
        DB::table('mahasiswa')->truncate();
        DB::table('users')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        $now = Carbon::now();
        $password = Hash::make('password123');

        // 1. SEED ADMIN
        DB::table('users')->insert([
<<<<<<< HEAD
            'name' => 'Admin Utama Amikom',
            'email_or_nim' => 'admin',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'created_at' => $now,
            'updated_at' => $now,
        ]);

        // 2. SEED DOSEN (15 Dosen)
        $dosenList = [
            'Dr. Rina Saraswati, M.Kom.', 'Bambang Sudarsono, S.T., M.Eng.',
            'Ahmad Fauzi, M.T.', 'Dr. Indah Lestari, M.Sc.',
            'Wawan Setiawan, M.Kom.', 'Dewi Anggraini, S.Kom., M.T.',
            'Eko Prasetyo, M.Eng.', 'Siti Rahmawati, M.Kom.',
            'Hendra Wijaya, M.Sc.', 'Fitriani Hidayah, M.T.',
            'Rudi Hermawan, M.Kom.', 'Nurul Aini, S.T., M.Eng.',
            'Agus Supriyanto, M.T.', 'Maya Safitri, M.Kom.', 'Deni Kurniawan, M.Sc.'
        ];

        $dosenNidns = [];
        foreach ($dosenList as $idx => $namaDosen) {
            $nidn = '0501' . str_pad($idx + 1, 6, '0', STR_PAD_LEFT);
            $userId = DB::table('users')->insertGetId([
                'name' => $namaDosen,
                'email_or_nim' => $nidn,
                'password' => $password,
                'role' => 'dosen',
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            DB::table('dosen')->insert([
                'nidn' => $nidn,
                'id_user' => $userId,
                'nama' => $namaDosen,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            $dosenNidns[] = $nidn;
        }

        // 3. SEED MITRA (15 Perusahaan Mitra)
        $mitraList = [
            ['nama' => 'PT Tokopedia Tech', 'bidang' => 'E-Commerce & Software House'],
            ['nama' => 'PT Telkom Indonesia', 'bidang' => 'Telekomunikasi & Digital'],
            ['nama' => 'PT Shopee International Indonesia', 'bidang' => 'E-Commerce Platform'],
            ['nama' => 'PT GoTo Gojek Tokopedia', 'bidang' => 'SuperApp & On-Demand Services'],
            ['nama' => 'PT Bank Central Asia Tbk (BCA Digital)', 'bidang' => 'Banking & Financial Technology'],
            ['nama' => 'PT Bukalapak.com', 'bidang' => 'Tech Enterprise'],
            ['nama' => 'PT Traveloka Indonesia', 'bidang' => 'Travel & Lifestyle Tech'],
            ['nama' => 'PT Amikom Tech Digital Solutions', 'bidang' => 'Software & Media House'],
            ['nama' => 'PT Ruang Raya Indonesia (Ruangguru)', 'bidang' => 'EdTech Services'],
            ['nama' => 'PT Paragon Technology & Innovation', 'bidang' => 'Manufacturing & Digital Systems'],
            ['nama' => 'PT Net Mediatama Digital', 'bidang' => 'Media & Broadcasting'],
            ['nama' => 'PT Pertamina Digital Hub', 'bidang' => 'Energy & Big Data Enterprise'],
            ['nama' => 'PT Blibli Digital', 'bidang' => 'E-Commerce Solutions'],
            ['nama' => 'PT Bank Mandiri (Persero) Tbk', 'bidang' => 'Banking Technology'],
            ['nama' => 'PT RRQ Esports Enterprise', 'bidang' => 'Esports & Digital Media']
        ];

        $mitraIds = [];
        foreach ($mitraList as $idx => $m) {
            $email = 'mitra' . ($idx + 1) . '@mitra.id';
            $userId = DB::table('users')->insertGetId([
                'name' => $m['nama'],
                'email_or_nim' => $email,
                'password' => $password,
                'role' => 'mitra',
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            $idMitra = DB::table('mitra')->insertGetId([
                'id_user' => $userId,
                'nama_perusahaan' => $m['nama'],
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            $mitraIds[] = $idMitra;
        }

        // 4. SEED MAHASISWA (50 Mahasiswa)
        $namaDepan = ['Bintang', 'Andi', 'Rizky', 'Bagus', 'Dika', 'Siti', 'Annisa', 'Nanda', 'Fajar', 'Tegar', 'Dian', 'Fani', 'Genta', 'Haikal', 'Irfan', 'Joko', 'Kevin', 'Lestari', 'Mahendra', 'Nadia', 'Oki', 'Putri', 'Qori', 'Rian', 'Surya'];
        $namaBelakang = ['Pratama', 'Wibowo', 'Kurniawan', 'Santoso', 'Saputra', 'Lestari', 'Nugroho', 'Hidayat', 'Ramadhan', 'Wijaya', 'Permana', 'Firmansyah', 'Kusuma', 'Utami', 'Setiawan'];
        $jurusans = ['Informatika', 'Sistem Informasi', 'Teknologi Informasi', 'Rekayasa Perangkat Lunak', 'Ilmu Komunikasi'];

        $mahasiswaNims = [];
        for ($i = 1; $i <= 50; $i++) {
            $nim = '22.11.' . str_pad($i, 4, '0', STR_PAD_LEFT);
            $fn = $namaDepan[($i - 1) % count($namaDepan)];
            $ln = $namaBelakang[($i - 1) % count($namaBelakang)];
            $namaMhs = "$fn $ln";
            $jurusan = $jurusans[($i - 1) % count($jurusans)];

            $userId = DB::table('users')->insertGetId([
                'name' => $namaMhs,
                'email_or_nim' => $nim,
                'password' => $password,
                'role' => 'mahasiswa',
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            DB::table('mahasiswa')->insert([
                'id_mahasiswa' => $nim,
                'id_user' => $userId,
                'nama' => $namaMhs,
                'jurusan' => $jurusan,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            $mahasiswaNims[] = $nim;
        }

        // 5. SEED LOWONGAN (50 Lowongan)
        $posisis = [
            ['posisi' => 'Flutter Mobile Developer', 'kategori' => 'Programming', 'lokasi' => 'Yogyakarta (Hybrid)'],
            ['posisi' => 'Backend Laravel Engineer', 'kategori' => 'Programming', 'lokasi' => 'Jakarta (On-site)'],
            ['posisi' => 'Frontend React.js Developer', 'kategori' => 'Programming', 'lokasi' => 'Bandung (Remote)'],
            ['posisi' => 'UI/UX Mobile Designer', 'kategori' => 'Design & Multimedia', 'lokasi' => 'Yogyakarta (On-site)'],
            ['posisi' => 'Data Analyst Trainee', 'kategori' => 'Data Science', 'lokasi' => 'Jakarta (Hybrid)'],
            ['posisi' => 'Cloud & DevOps Engineer', 'kategori' => 'Networking', 'lokasi' => 'Jakarta (Remote)'],
            ['posisi' => 'Cyber Security Analyst Assistant', 'kategori' => 'Networking', 'lokasi' => 'Surakarta (On-site)'],
            ['posisi' => 'QA Automation Engineer', 'kategori' => 'Programming', 'lokasi' => 'Semarang (Hybrid)'],
            ['posisi' => 'AI & Machine Learning Intern', 'kategori' => 'Data Science', 'lokasi' => 'Yogyakarta (Remote)'],
            ['posisi' => 'Fullstack Web Developer', 'kategori' => 'Programming', 'lokasi' => 'Surabaya (On-site)']
        ];

        $lowonganIds = [];
        for ($i = 1; $i <= 50; $i++) {
            $template = $posisis[($i - 1) % count($posisis)];
            $idMitra = $mitraIds[($i - 1) % count($mitraIds)];
            $statusApproval = ($i % 10 == 0) ? 'pending' : (($i % 15 == 0) ? 'ditolak' : 'disetujui');

            $idLowongan = DB::table('lowongan')->insertGetId([
                'id_mitra' => $idMitra,
                'judul_posisi' => $template['posisi'] . " - Batch $i",
                'kategori' => $template['kategori'],
                'lokasi' => $template['lokasi'],
                'deskripsi' => "Bergabunglah dalam proyek pengembangan sistem skala besar di " . $template['posisi'] . ". Mengembangkan aplikasi performa tinggi untuk kebutuhan jutaan pengguna.",
                'persyaratan' => "1. Mahasiswa aktif semester 5 atau 7\n2. Memiliki dasar logika pemrograman/desain yang kuat\n3. Mampu bekerja secara tim maupun mandiri",
                'tipe_kerja' => ($i % 3 == 0) ? 'Remote' : (($i % 3 == 1) ? 'On-site' : 'Hybrid'),
                'tipe_kontrak' => 'Full-time',
                'benefit' => "Sertifikat Resmi Magang\nUang Saku Bulanan\nMentoring Spesialis Industri\nKesempatan Karir Tetap",
                'kuota' => rand(2, 8),
                'batas_waktu' => Carbon::now()->addDays(rand(10, 60))->toDateString(),
                'status_approval' => $statusApproval,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            if ($statusApproval === 'disetujui') {
                $lowonganIds[] = $idLowongan;
            }
        }

        // 6. SEED PENDAFTARAN (50 Data Pendaftaran)
        $pendaftaranIds = [];
        $pendaftaranAcceptedIds = [];
        $usedPairs = [];

        for ($i = 0; $i < 50; $i++) {
            $nim = $mahasiswaNims[$i % count($mahasiswaNims)];
            $idLowongan = $lowonganIds[$i % count($lowonganIds)];
            
            $pairKey = "$nim-$idLowongan";
            if (isset($usedPairs[$pairKey])) continue;
            $usedPairs[$pairKey] = true;

            $statusPendaftaran = ($i % 3 == 0) ? 'diterima' : (($i % 4 == 0) ? 'ditolak' : 'pending');

            $idPendaftaran = DB::table('pendaftaran')->insertGetId([
                'id_mahasiswa' => $nim,
                'id_lowongan' => $idLowongan,
                'berkas_cv' => "cv_mahasiswa_$nim.pdf",
                'motivasi' => "Saya sangat antusias untuk mengaplikasikan ilmu yang saya dapatkan selama perkuliahan pada posisi magang ini.",
                'status' => $statusPendaftaran,
                'created_at' => Carbon::now()->subDays(rand(5, 30)),
                'updated_at' => $now,
            ]);

            $pendaftaranIds[] = $idPendaftaran;
            if ($statusPendaftaran === 'diterima') {
                $pendaftaranAcceptedIds[] = [
                    'id_pendaftaran' => $idPendaftaran,
                    'nim' => $nim,
                ];
            }
        }

        // 7. SEED BIMBINGAN (Untuk Pendaftaran Diterima)
        $bimbinganIds = [];
        foreach ($pendaftaranAcceptedIds as $idx => $acc) {
            $nidn = $dosenNidns[$idx % count($dosenNidns)];
            $statusVerifikasi = ($idx % 5 == 0) ? 'pending' : 'disetujui';

            $idBimbingan = DB::table('bimbingan')->insertGetId([
                'id_pendaftaran' => $acc['id_pendaftaran'],
                'nidn' => $nidn,
                'status_verifikasi' => $statusVerifikasi,
                'catatan_verifikasi' => ($statusVerifikasi === 'disetujui') ? 'Mahasiswa memenuhi syarat bimbingan magang.' : null,
                'created_at' => $now,
                'updated_at' => $now,
            ]);

            $bimbinganIds[] = [
                'id_bimbingan' => $idBimbingan,
                'id_pendaftaran' => $acc['id_pendaftaran'],
            ];
        }

        // 8. SEED LOGBOOK (50+ Data Logbook Mingguan)
        $desks = [
            'Melakukan onboarding tim, mempelajari repositori proyek, serta koordinasi tugas minggu pertama.',
            'Merancang struktur database, membuat diagram ERD, dan menyiapkan environment Laravel/Flutter.',
            'Mengimplementasikan fitur autentikasi user (Login/Register) dan mengintegrasikan Laravel Sanctum.',
            'Membuat tampilan antarmuka (UI) dashboard utama sesuai mockup Figma dan menghubungkannya dengan REST API.',
            'Membuat pengujian integrasi (API Integration Testing), membenahi bugs pada upload file, dan dokumentasi.',
        ];

        $logbookCount = 0;
        foreach ($pendaftaranAcceptedIds as $acc) {
            for ($week = 1; $week <= rand(2, 4); $week++) {
                $statusVal = ($week == 1) ? 'disetujui' : (($week == 2) ? 'revisi' : 'pending');
                $feedback = ($statusVal === 'disetujui') ? 'Laporan sangat lengkap. Tingkatkan terus kualitas kodenya.' : (($statusVal === 'revisi') ? 'Tolong jelaskan lebih spesifik mengenai modul pengujian.' : null);

                DB::table('logbook')->insert([
                    'id_pendaftaran' => $acc['id_pendaftaran'],
                    'minggu_ke' => $week,
                    'tanggal' => Carbon::now()->subWeeks(4 - $week)->toDateString(),
                    'deskripsi_kegiatan' => $desks[($week - 1) % count($desks)],
                    'status_validasi' => $statusVal,
                    'feedback_dosen' => $feedback,
                    'created_at' => Carbon::now()->subWeeks(4 - $week),
                    'updated_at' => $now,
                ]);

                $logbookCount++;
                if ($logbookCount >= 50) break 2;
            }
        }
=======
            [
                'name' => 'Asrul Gamink',
                'email_or_nim' => '22.11.1234',
                'password' => Hash::make('password123'),
                'role' => 'mahasiswa',
            ],
            [
                'name' => 'RRQ',
                'email_or_nim' => 'mitra.RRQ',
                'password' => Hash::make('password123'),
                'role' => 'mitra',
            ],
            [
                'name' => 'Dr. Rina Saraswati, M.Kom.',
                'email_or_nim' => 'dosen123',
                'password' => Hash::make('password123'),
                'role' => 'dosen',
            ],
            [
                'name' => 'Admin Amikom',
                'email_or_nim' => 'admin',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
            ],
        ]);

        DB::table('lowongan')->insert([
            [
                'id_mitra' => 2,
                'judul_posisi' => 'Backend Developer',
                'kategori' => 'Programming',
                'lokasi' => 'Remote',
                'deskripsi' => 'Membangun arsitektur backend untuk manajemen turnamen divisi esports komunitas RRQ.',
                'persyaratan' => "1. Mahasiswa Informatika konsentrasi Programming\n2. Memahami Laravel atau Node.js",
                'benefit' => "Sertifikat\nMentoring\nUang Saku",
                'kuota' => '3',
                'batas_waktu' => clone $now->addDays(30),
                'status_approval' => 'approved',
            ],
            [
                'id_mitra' => 2,
                'judul_posisi' => 'IoT Engineer Smart Greenhouse',
                'kategori' => 'Networking',
                'lokasi' => 'Sleman, DIY',
                'deskripsi' => 'Merancang sistem automasi smart greenhouse berbasis sensor industri.',
                'persyaratan' => "1. Paham mikrokontroler\n2. Mengerti jaringan sensor",
                'benefit' => "Akses alat industri\nKonversi SKS PPK Ormawa",
                'kuota' => '5',
                'batas_waktu' => clone $now->addDays(15),
                'status_approval' => 'approved',
            ],
        ]);

        DB::table('pendaftaran')->insert([
            'id_mahasiswa' => '22.11.1234',
            'id_lowongan' => 2,
            'motivasi' => 'Saya sangat tertarik dengan IoT dan Smart Farming untuk pertanian.',
            'berkas_cv' => 'berkas_cv_bintang.pdf',
            'status' => 'diterima',
        ]);

        DB::table('logbook')->insert([
            [
                'id_pendaftaran' => 1,
                'minggu_ke' => '1',
                'tanggal' => clone $now->subDays(7),
                'deskripsi_kegiatan' => 'Melakukan perancangan arsitektur IoT dan memesan sensor suhu.',
                'status_validasi' => 'disetujui',
                'feedback_dosen' => 'Perencanaan yang bagus. Lanjutkan.',
            ],
            [
                'id_pendaftaran' => 1,
                'minggu_ke' => '2',
                'tanggal' => clone $now->subDays(1),
                'deskripsi_kegiatan' => 'Instalasi mikrokontroler dan pengujian pengiriman data.',
                'status_validasi' => 'pending',
                'feedback_dosen' => null,
            ],
        ]);
>>>>>>> f6b3645b01dc7980f13ef018c69ed208e5e79b85
    }
}
