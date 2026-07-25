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
            $table->string('status', 30)->default('pending')->change();
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('rejected_at')->nullable();
            $table->timestamp('withdrawn_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->text('rejection_reason')->nullable();
        });

        DB::table('pendaftaran')->where('status', 'diterima')->update([
            'status' => 'accepted',
            'accepted_at' => DB::raw('COALESCE(accepted_at, updated_at)'),
        ]);
        DB::table('pendaftaran')->where('status', 'ditolak')->update([
            'status' => 'rejected',
            'rejected_at' => DB::raw('COALESCE(rejected_at, updated_at)'),
        ]);
        DB::table('pendaftaran')->where('status', 'selesai')->update([
            'status' => 'completed',
            'completed_at' => DB::raw('COALESCE(completed_at, updated_at)'),
        ]);
    }

    public function down(): void
    {
        DB::table('pendaftaran')->where('status', 'accepted')->update(['status' => 'diterima']);
        DB::table('pendaftaran')->where('status', 'rejected')->update(['status' => 'ditolak']);
        DB::table('pendaftaran')->where('status', 'completed')->update(['status' => 'selesai']);
        DB::table('pendaftaran')->whereIn('status', ['under_review', 'interview', 'withdrawn'])
            ->update(['status' => 'pending']);

        Schema::table('pendaftaran', function (Blueprint $table) {
            $table->dropColumn([
                'accepted_at',
                'rejected_at',
                'withdrawn_at',
                'completed_at',
                'rejection_reason',
            ]);
        });
    }
};
