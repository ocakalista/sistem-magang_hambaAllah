<?php

namespace Tests\Feature;

use App\Models\Lowongan;
use App\Models\Mitra;
use App\Models\Pendaftaran;
use App\Models\PendaftaranDraft;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PendaftaranTest extends TestCase
{
    use RefreshDatabase;

    public function test_mahasiswa_without_profile_can_submit_an_application_with_files(): void
    {
        [$mahasiswa, $lowongan] = $this->scenario();
        PendaftaranDraft::create([
            'user_id' => $mahasiswa->id,
            'id_lowongan' => $lowongan->id_lowongan,
            'motivasi' => 'Draft lama',
        ]);

        $this->post('/api/pendaftaran', $this->validPayload($lowongan))
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Lamaran terkirim!');

        $this->assertDatabaseHas('mahasiswa', [
            'id_mahasiswa' => $mahasiswa->email_or_nim,
            'id_user' => $mahasiswa->id,
        ]);
        $this->assertDatabaseHas('pendaftaran', [
            'id_mahasiswa' => $mahasiswa->email_or_nim,
            'id_lowongan' => $lowongan->id_lowongan,
            'status' => 'pending',
        ]);
        $this->assertDatabaseHas('lowongan', [
            'id_lowongan' => $lowongan->id_lowongan,
            'kuota' => 1,
        ]);
        $this->assertDatabaseCount('notifications', 1);
        $this->assertDatabaseCount('pendaftaran_drafts', 0);
    }

    public function test_semester_must_be_between_one_and_fourteen(): void
    {
        [, $lowongan] = $this->scenario();

        $payload = $this->validPayload($lowongan);
        $payload['semester'] = 15;

        $this->post('/api/pendaftaran', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors('semester');
    }

    public function test_cv_must_be_an_allowed_document(): void
    {
        [, $lowongan] = $this->scenario();

        $payload = $this->validPayload($lowongan);
        $payload['berkas_cv'] = UploadedFile::fake()->create('virus.exe', 100);

        $this->post('/api/pendaftaran', $payload)
            ->assertUnprocessable()
            ->assertJsonValidationErrors('berkas_cv');
    }

    public function test_duplicate_application_is_rejected_without_decreasing_quota(): void
    {
        [$mahasiswa, $lowongan] = $this->scenario();
        Pendaftaran::create([
            'id_mahasiswa' => $mahasiswa->email_or_nim,
            'id_lowongan' => $lowongan->id_lowongan,
            'status' => 'pending',
        ]);

        $this->post('/api/pendaftaran', $this->validPayload($lowongan))
            ->assertStatus(409)
            ->assertJsonPath('success', false);

        $this->assertSame(2, $lowongan->fresh()->kuota);
    }

    public function test_application_is_rejected_when_quota_is_empty(): void
    {
        [, $lowongan] = $this->scenario(quota: 0);

        $this->post('/api/pendaftaran', $this->validPayload($lowongan))
            ->assertStatus(409)
            ->assertJsonPath('success', false);

        $this->assertDatabaseCount('pendaftaran', 0);
    }

    public function test_database_failure_rolls_back_profile_and_quota_changes(): void
    {
        [$mahasiswa, $lowongan] = $this->scenario();
        Schema::drop('pendaftaran');

        $this->post('/api/pendaftaran', $this->validPayload($lowongan))
            ->assertStatus(500)
            ->assertJsonPath('success', false);

        $this->assertSame(2, $lowongan->fresh()->kuota);
        $this->assertNull($mahasiswa->fresh()->phone);
    }

    public function test_upload_failure_rolls_back_profile_and_quota_changes(): void
    {
        [$mahasiswa, $lowongan] = $this->scenario();
        $invalidRoot = tempnam(sys_get_temp_dir(), 'nexus-storage-file');
        config(['filesystems.disks.public.root' => $invalidRoot]);
        Storage::forgetDisk('public');

        try {
            $this->post('/api/pendaftaran', $this->validPayload($lowongan))
                ->assertStatus(500)
                ->assertJsonPath('success', false);
        } finally {
            @unlink($invalidRoot);
        }

        $this->assertSame(2, $lowongan->fresh()->kuota);
        $this->assertNull($mahasiswa->fresh()->phone);
        $this->assertDatabaseCount('pendaftaran', 0);
    }

    public function test_notification_failure_does_not_fail_a_valid_application(): void
    {
        [, $lowongan] = $this->scenario();
        Schema::drop('notifications');

        $this->post('/api/pendaftaran', $this->validPayload($lowongan))
            ->assertCreated()
            ->assertJsonPath('success', true);

        $this->assertDatabaseCount('pendaftaran', 1);
        $this->assertSame(1, $lowongan->fresh()->kuota);
    }

    private function scenario(int $quota = 2): array
    {
        Storage::fake('public');

        $mahasiswa = User::create([
            'name' => 'Bintang Pratama',
            'email_or_nim' => '22.11.0027',
            'password' => 'password',
            'role' => 'mahasiswa',
            'konsentrasi' => 'pemrograman',
        ]);
        $mitraUser = User::create([
            'name' => 'Mitra Test',
            'email_or_nim' => 'mitra@test.local',
            'password' => 'password',
            'role' => 'mitra',
        ]);
        $mitra = Mitra::create([
            'id_user' => $mitraUser->id,
            'nama_perusahaan' => 'PT Mitra Test',
        ]);
        $lowongan = Lowongan::create([
            'id_mitra' => $mitra->id_mitra,
            'judul_posisi' => 'Backend Developer',
            'deskripsi' => 'Deskripsi',
            'persyaratan' => 'Persyaratan',
            'kategori' => 'Programming',
            'lokasi' => 'Yogyakarta',
            'tipe_kerja' => 'Remote',
            'tipe_kontrak' => 'Internship',
            'kuota' => $quota,
            'batas_waktu' => now()->addWeek()->toDateString(),
            'status_approval' => 'approved',
        ]);

        Sanctum::actingAs($mahasiswa);

        return [$mahasiswa, $lowongan];
    }

    private function validPayload(Lowongan $lowongan): array
    {
        return [
            'id_lowongan' => $lowongan->id_lowongan,
            'nama_lengkap' => 'Bintang Pratama',
            'no_telp' => '081236972458',
            'semester' => 6,
            'motivasi' => 'Saya ingin mengikuti program magang ini.',
            'berkas_cv' => UploadedFile::fake()->create('cv.pdf', 100, 'application/pdf'),
            'berkas_portofolio' => UploadedFile::fake()->create('portofolio.pdf', 100, 'application/pdf'),
        ];
    }
}
