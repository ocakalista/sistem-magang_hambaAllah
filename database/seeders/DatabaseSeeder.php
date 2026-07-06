<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        $now = Carbon::now();

        DB::table('users')->insert([
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
            ]
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
                'status_approval' => 'disetujui'
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
                'status_approval' => 'disetujui'
            ]
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
                'feedback_dosen' => 'Perencanaan yang bagus. Lanjutkan.'
            ],
            [
                'id_pendaftaran' => 1,
                'minggu_ke' => '2',
                'tanggal' => clone $now->subDays(1),
                'deskripsi_kegiatan' => 'Instalasi mikrokontroler dan pengujian pengiriman data.',
                'status_validasi' => 'pending', 
                'feedback_dosen' => null
            ]
        ]);
    }
}