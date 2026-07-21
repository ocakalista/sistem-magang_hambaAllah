<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bimbingan', function (Blueprint $table) {
            if (!Schema::hasColumn('bimbingan', 'status_verifikasi')) {
                $table->string('status_verifikasi')->default('disetujui')->after('nidn');
            }
            if (!Schema::hasColumn('bimbingan', 'catatan_verifikasi')) {
                $table->text('catatan_verifikasi')->nullable()->after('status_verifikasi');
            }
        });
    }

    public function down(): void
    {
        Schema::table('bimbingan', function (Blueprint $table) {
            if (Schema::hasColumn('bimbingan', 'catatan_verifikasi')) {
                $table->dropColumn('catatan_verifikasi');
            }
            if (Schema::hasColumn('bimbingan', 'status_verifikasi')) {
                $table->dropColumn('status_verifikasi');
            }
        });
    }
};
