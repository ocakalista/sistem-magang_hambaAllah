<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('pendaftaran', 'laporan_akhir')) {
            Schema::table('pendaftaran', function (Blueprint $table) {
                $table->string('laporan_akhir')->nullable()->after('status');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('pendaftaran', 'laporan_akhir')) {
            Schema::table('pendaftaran', function (Blueprint $table) {
                $table->dropColumn('laporan_akhir');
            });
        }
    }
};