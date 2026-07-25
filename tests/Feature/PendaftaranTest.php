<?php

namespace Tests\Feature;

use App\Models\Lowongan;
use App\Models\Mitra;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PendaftaranTest extends TestCase
{
    use RefreshDatabase;

    public function test_mahasiswa_can_submit_an_application_with_files(): void
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
            'lokasi' => 'Remote',
            'tipe_kerja' => 'Remote',
            'tipe_kontrak' => 'Internship',
            'kuota' => 2,
            'batas_waktu' => now()->addWeek()->toDateString(),
            'status_approval' => 'approved',
        ]);

        Sanctum::actingAs($mahasiswa);

        $response = $this->post('/api/pendaftaran', [
            'id_lowongan' => $lowongan->id_lowongan,
            'nama_lengkap' => 'Bintang Pratama',
            'no_telp' => '081236972458',
            'semester' => 6,
            'motivasi' => 'Saya ingin mengikuti program magang ini.',
            'berkas_cv' => UploadedFile::fake()->create('cv.pdf', 100, 'application/pdf'),
            'berkas_portofolio' => UploadedFile::fake()->create('portofolio.pdf', 100, 'application/pdf'),
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Lamaran terkirim!');

        $this->assertDatabaseHas('mahasiswa', [
            'id_mahasiswa' => '22.11.0027',
            'id_user' => $mahasiswa->id,
        ]);

        $this->assertDatabaseHas('pendaftaran', [
            'id_mahasiswa' => '22.11.0027',
            'id_lowongan' => $lowongan->id_lowongan,
            'status' => 'pending',
        ]);

        $this->assertDatabaseHas('lowongan', [
            'id_lowongan' => $lowongan->id_lowongan,
            'kuota' => 1,
        ]);

        $this->assertDatabaseCount('notifications', 1);
    }
}
