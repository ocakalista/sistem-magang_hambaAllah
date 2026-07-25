<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (
            Schema::hasColumn('mahasiswa', 'nim')
            && ! Schema::hasColumn('mahasiswa', 'id_mahasiswa')
        ) {
            Schema::table('mahasiswa', function (Blueprint $table) {
                $table->renameColumn('nim', 'id_mahasiswa');
            });
        }
    }

    public function down(): void
    {
        if (
            Schema::hasColumn('mahasiswa', 'id_mahasiswa')
            && ! Schema::hasColumn('mahasiswa', 'nim')
        ) {
            Schema::table('mahasiswa', function (Blueprint $table) {
                $table->renameColumn('id_mahasiswa', 'nim');
            });
        }
    }
};
