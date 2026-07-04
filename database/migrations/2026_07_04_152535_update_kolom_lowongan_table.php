<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('lowongan', function (Blueprint $table) {
            // Pasang satpam: Kalau belum ada kolomnya, baru kita buatkan
            if (!Schema::hasColumn('lowongan', 'deskripsi')) {
                $table->text('deskripsi')->nullable()->after('judul_posisi');
            }
            if (!Schema::hasColumn('lowongan', 'persyaratan')) {
                $table->text('persyaratan')->nullable()->after('deskripsi');
            }
            if (!Schema::hasColumn('lowongan', 'kategori')) {
                $table->string('kategori')->nullable()->after('persyaratan');
            }
            if (!Schema::hasColumn('lowongan', 'lokasi')) {
                $table->string('lokasi')->nullable()->after('kategori');
            }
            if (!Schema::hasColumn('lowongan', 'tipe_kerja')) {
                $table->string('tipe_kerja')->nullable()->after('lokasi');
            }
            if (!Schema::hasColumn('lowongan', 'tipe_kontrak')) {
                $table->string('tipe_kontrak')->nullable()->after('tipe_kerja');
            }
            if (!Schema::hasColumn('lowongan', 'benefit')) {
                $table->text('benefit')->nullable()->after('tipe_kontrak');
            }
        });
    }

    public function down(): void
    {
        Schema::table('lowongan', function (Blueprint $table) {
            $kolom = ['deskripsi', 'persyaratan', 'kategori', 'lokasi', 'tipe_kerja', 'tipe_kontrak', 'benefit'];
            foreach ($kolom as $k) {
                if (Schema::hasColumn('lowongan', $k)) {
                    $table->dropColumn($k);
                }
            }
        });
    }
};