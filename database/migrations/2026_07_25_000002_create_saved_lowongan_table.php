<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('saved_lowongan', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedBigInteger('id_lowongan');
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
        Schema::dropIfExists('saved_lowongan');
    }
};
