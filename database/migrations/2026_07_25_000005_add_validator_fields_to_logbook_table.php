<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('logbook', function (Blueprint $table) {
            $table->string('id_dosen_feedback')->nullable()->after('feedback_dosen');
            $table->timestamp('validated_at')->nullable()->after('id_dosen_feedback');
            $table->index('id_dosen_feedback');
        });
    }

    public function down(): void
    {
        Schema::table('logbook', function (Blueprint $table) {
            $table->dropIndex(['id_dosen_feedback']);
            $table->dropColumn(['id_dosen_feedback', 'validated_at']);
        });
    }
};
