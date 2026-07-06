<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('lowongan', function (Blueprint $table) {
            $table->text('deskripsi')->nullable()->after('judul_posisi');
        });
    }

    public function down()
    {
        Schema::table('lowongan', function (Blueprint $table) {
            $table->dropColumn('deskripsi');
        });
    }
};