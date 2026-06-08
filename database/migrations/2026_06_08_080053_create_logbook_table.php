<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('logbook', function (Blueprint $table) {
            $table->id('id_logbook');
            $table->unsignedBigInteger('id_pendaftaran');
            $table->text('isi_laporan');
            $table->date('tanggal_submit');
            $table->text('evaluasi_dosen')->nullable(); // nullable berarti dosen belum tentu langsung menilai
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('logbook');
    }
};
