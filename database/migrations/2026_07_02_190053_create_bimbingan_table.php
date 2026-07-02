<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('bimbingan', function (Blueprint $table) {
            $table->id('id_bimbingan');
            $table->unsignedBigInteger('id_pendaftaran');
            $table->string('nidn'); // Mengikuti tipe data NIDN di tabel dosen
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bimbingan');
    }
};
