<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Cek dulu: Kalau kolom 'role' BELUM ada, baru eksekusi pembuatan kolom
        if (!Schema::hasColumn('users', 'role')) {
            Schema::table('users', function (Blueprint $table) {
                $table->enum('role', ['admin', 'mahasiswa', 'mitra', 'dosen'])->default('mahasiswa')->after('password');
            });
        }
    }

    public function down()
    {
        // Cek dulu: Kalau kolom 'role' ADA, baru eksekusi penghapusan kolom
        if (Schema::hasColumn('users', 'role')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('role');
            });
        }
    }
};