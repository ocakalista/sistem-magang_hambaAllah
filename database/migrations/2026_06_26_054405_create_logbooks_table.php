<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('logbook', function (Blueprint $table) {
            $table->id('id_logbook');
            $table->unsignedBigInteger('id_pendaftaran');
            $table->integer('minggu_ke');
            $table->date('tanggal');
            $table->text('deskripsi_kegiatan');
            $table->enum('status_validasi', ['pending', 'disetujui', 'revisi'])->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('logbook');
    }
};