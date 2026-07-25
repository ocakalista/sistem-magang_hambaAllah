<?php

namespace Tests\Feature;

use App\Models\Lowongan;
use App\Models\Mitra;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class SavedLowonganAndDraftTest extends TestCase
{
    use RefreshDatabase;

    public function test_bookmark_endpoints_are_idempotent_and_isolated_per_user(): void
    {
        [$user, $other, $lowongan] = $this->scenario();
        Sanctum::actingAs($user);

        $this->postJson('/api/saved-lowongan/'.$lowongan->id_lowongan)->assertCreated();
        $this->postJson('/api/saved-lowongan/'.$lowongan->id_lowongan)->assertOk();
        $this->assertDatabaseCount('saved_lowongan', 1);

        Sanctum::actingAs($other);
        $this->getJson('/api/saved-lowongan')->assertOk()->assertJsonCount(0, 'data');
        $this->deleteJson('/api/saved-lowongan/'.$lowongan->id_lowongan)->assertOk();
        $this->assertDatabaseCount('saved_lowongan', 1);

        Sanctum::actingAs($user);
        $this->getJson('/api/saved-lowongan')
            ->assertOk()
            ->assertJsonPath('data.0.nama_perusahaan', 'PT Nexus');
        $this->deleteJson('/api/saved-lowongan/'.$lowongan->id_lowongan)->assertOk();
        $this->assertDatabaseCount('saved_lowongan', 0);
    }

    public function test_draft_endpoints_validate_update_and_isolate_ownership(): void
    {
        [$user, $other, $lowongan] = $this->scenario();
        Sanctum::actingAs($user);

        $this->putJson('/api/pendaftaran/draft/'.$lowongan->id_lowongan, [
            'nama_lengkap' => 'Bintang',
            'semester' => 6,
            'portfolio_link' => 'https://example.com/portfolio',
        ])->assertOk()->assertJsonPath('data.semester', 6);

        $this->putJson('/api/pendaftaran/draft/'.$lowongan->id_lowongan, [
            'semester' => 15,
        ])->assertUnprocessable()->assertJsonValidationErrors('semester');

        Sanctum::actingAs($other);
        $this->getJson('/api/pendaftaran/draft/'.$lowongan->id_lowongan)->assertNotFound();
        $this->deleteJson('/api/pendaftaran/draft/'.$lowongan->id_lowongan)->assertOk();
        $this->assertDatabaseCount('pendaftaran_drafts', 1);

        Sanctum::actingAs($user);
        $this->deleteJson('/api/pendaftaran/draft/'.$lowongan->id_lowongan)->assertOk();
        $this->assertDatabaseCount('pendaftaran_drafts', 0);
    }

    public function test_bookmarks_and_drafts_require_student_role(): void
    {
        [, $other, $lowongan] = $this->scenario();
        $other->update(['role' => 'mitra']);
        Sanctum::actingAs($other);

        $this->getJson('/api/saved-lowongan')->assertForbidden();
        $this->putJson('/api/pendaftaran/draft/'.$lowongan->id_lowongan, [])
            ->assertForbidden();
    }

    private function scenario(): array
    {
        $user = User::create([
            'name' => 'Mahasiswa',
            'email_or_nim' => '22.11.0001',
            'password' => 'password',
            'role' => 'mahasiswa',
        ]);
        $other = User::create([
            'name' => 'Mahasiswa Lain',
            'email_or_nim' => '22.11.0002',
            'password' => 'password',
            'role' => 'mahasiswa',
        ]);
        $mitraUser = User::create([
            'name' => 'PT Nexus',
            'email_or_nim' => 'mitra@nexus.test',
            'password' => 'password',
            'role' => 'mitra',
        ]);
        $mitra = Mitra::create([
            'id_user' => $mitraUser->id,
            'nama_perusahaan' => 'PT Nexus',
        ]);
        $lowongan = Lowongan::create([
            'id_mitra' => $mitra->id_mitra,
            'judul_posisi' => 'Flutter Developer',
            'kuota' => 3,
            'batas_waktu' => now()->addMonth()->toDateString(),
            'status_approval' => 'approved',
        ]);

        return [$user, $other, $lowongan];
    }
}
