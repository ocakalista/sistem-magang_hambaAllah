<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pendaftaran', function (Blueprint $table) {
            $table->string('portfolio_link')->nullable()->after('portofolio');
        });
        Schema::table('logbook', function (Blueprint $table) {
            $table->text('deskripsi_kegiatan')->nullable()->change();
            $table->string('berkas_lampiran')->nullable()->after('deskripsi_kegiatan');
        });

        DB::table('lowongan')->where('status_approval', 'disetujui')->update(['status_approval' => 'approved']);
        DB::table('lowongan')->where('status_approval', 'ditolak')->update(['status_approval' => 'rejected']);
    }

    public function down(): void
    {
        Schema::table('logbook', function (Blueprint $table) {
            $table->dropColumn('berkas_lampiran');
            $table->text('deskripsi_kegiatan')->nullable(false)->change();
        });
        Schema::table('pendaftaran', fn (Blueprint $table) => $table->dropColumn('portfolio_link'));
    }
};
