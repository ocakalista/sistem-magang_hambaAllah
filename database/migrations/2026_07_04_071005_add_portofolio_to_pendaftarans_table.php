<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
   public function up()
    {
        // Kita pasang satpam pengecek di sini
        if (!Schema::hasColumn('pendaftaran', 'portofolio')) {
            Schema::table('pendaftaran', function (Blueprint $table) {
                $table->string('portofolio')->nullable()->after('berkas_cv');
            });
        }
    }

    public function down()
    {
        if (Schema::hasColumn('pendaftaran', 'portofolio')) {
            Schema::table('pendaftaran', function (Blueprint $table) {
                $table->dropColumn('portofolio');
            });
        }
    }
};
