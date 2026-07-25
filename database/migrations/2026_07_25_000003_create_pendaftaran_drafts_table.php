<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pendaftaran_drafts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedBigInteger('id_lowongan');
            $table->string('nama_lengkap')->nullable();
            $table->string('no_telp', 20)->nullable();
            $table->unsignedTinyInteger('semester')->nullable();
            $table->text('motivasi')->nullable();
            $table->string('portfolio_link', 2048)->nullable();
            $table->timestamps();

            $table->foreign('id_lowongan')
                ->references('id_lowongan')
                ->on('lowongan')
                ->cascadeOnDelete();
            $table->unique(['user_id', 'id_lowongan']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pendaftaran_drafts');
    }
};
