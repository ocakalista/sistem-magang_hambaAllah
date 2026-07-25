<?php

namespace Tests\Feature;

use App\Models\Bimbingan;
use App\Models\Dosen;
use App\Models\Logbook;
use App\Models\Lowongan;
use App\Models\Mahasiswa;
use App\Models\Mitra;
use App\Models\Pendaftaran;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class InternshipFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_can_apply_multiple_times_but_not_with_active_internship(): void
    {
        Storage::fake('public');
        $data = $this->scenario();
        Sanctum::actingAs($data['student']);

        $this->apply($data['firstVacancy'])->assertCreated();
        $this->apply($data['secondVacancy'])->assertCreated();
        $this->assertDatabaseCount('pendaftaran', 2);

        Pendaftaran::query()->first()->update([
            'status' => 'accepted',
            'accepted_at' => now(),
        ]);

        $third = $this->vacancy($data['firstMitra'], 'QA Engineer');
        $this->apply($third)
            ->assertUnprocessable()
            ->assertJsonPath('code', 'ACTIVE_INTERNSHIP_EXISTS');
    }

    public function test_acceptance_withdraws_other_open_applications_and_blocks_second_partner(): void
    {
        $data = $this->scenario();
        $first = $this->application($data['student'], $data['firstVacancy']);
        $second = $this->application($data['student'], $data['secondVacancy'], 'under_review');

        Sanctum::actingAs($data['firstPartner']);
        $this->putJson('/api/pendaftaran/'.$first->id_pendaftaran.'/status', [
            'status' => 'accepted',
        ])->assertOk()->assertJsonPath('data.status', 'accepted');

        $this->assertNotNull($first->fresh()->accepted_at);
        $this->assertSame('withdrawn', $second->fresh()->status);
        $this->assertNotNull($second->fresh()->withdrawn_at);

        Sanctum::actingAs($data['secondPartner']);
        $second->update(['status' => 'pending', 'withdrawn_at' => null]);
        $this->putJson('/api/pendaftaran/'.$second->id_pendaftaran.'/status', [
            'status' => 'accepted',
        ])->assertStatus(409)->assertJsonPath('code', 'ACTIVE_INTERNSHIP_EXISTS');

        $this->putJson('/api/pendaftaran/'.$first->id_pendaftaran.'/status', [
            'status' => 'rejected',
            'rejection_reason' => 'Tidak sesuai.',
        ])->assertForbidden();
    }

    public function test_history_and_active_endpoint_return_consistent_resources(): void
    {
        $data = $this->scenario();
        $accepted = $this->application($data['student'], $data['firstVacancy'], 'accepted');
        $accepted->update(['accepted_at' => now()]);
        $this->application($data['student'], $data['secondVacancy'], 'rejected')
            ->update(['rejected_at' => now(), 'rejection_reason' => 'Posisi penuh.']);

        Sanctum::actingAs($data['student']);
        $this->getJson('/api/pendaftaran/riwayat')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonStructure(['data' => [[
                'id_pendaftaran',
                'status',
                'tanggal_daftar',
                'accepted_at',
                'rejected_at',
                'withdrawn_at',
                'completed_at',
                'rejection_reason',
                'total_weeks',
                'lowongan' => [
                    'id_lowongan',
                    'judul_posisi',
                    'nama_perusahaan',
                    'lokasi',
                    'kategori',
                ],
            ]]]);

        $this->getJson('/api/pendaftaran/aktif')
            ->assertOk()
            ->assertJsonPath('data.id_pendaftaran', $accepted->id_pendaftaran)
            ->assertJsonPath('data.status', 'accepted')
            ->assertJsonStructure(['data' => ['logbooks']]);
    }

    public function test_only_supervisor_or_admin_can_complete_and_student_can_apply_again(): void
    {
        Storage::fake('public');
        $data = $this->scenario();
        $application = $this->application($data['student'], $data['firstVacancy'], 'accepted');
        $application->update(['accepted_at' => now()]);
        Bimbingan::create([
            'id_pendaftaran' => $application->id_pendaftaran,
            'nidn' => $data['supervisorProfile']->nidn,
        ]);
        Logbook::create([
            'id_pendaftaran' => $application->id_pendaftaran,
            'minggu_ke' => 1,
            'tanggal' => now()->toDateString(),
            'deskripsi_kegiatan' => 'Menyelesaikan target magang.',
            'status_validasi' => 'disetujui',
        ]);

        Sanctum::actingAs($data['otherLecturer']);
        $this->putJson('/api/pendaftaran/'.$application->id_pendaftaran.'/complete')
            ->assertForbidden();

        Sanctum::actingAs($data['student']);
        $this->putJson('/api/pendaftaran/'.$application->id_pendaftaran.'/complete')
            ->assertForbidden();

        Sanctum::actingAs($data['supervisor']);
        $this->putJson('/api/pendaftaran/'.$application->id_pendaftaran.'/complete')
            ->assertOk()
            ->assertJsonPath('data.status', 'completed');

        $this->assertNotNull($application->fresh()->completed_at);

        Sanctum::actingAs($data['student']);
        $this->apply($data['secondVacancy'])->assertCreated();
    }

    private function scenario(): array
    {
        $student = $this->user('Bintang Pratama', '23.11.5818', 'mahasiswa');
        $firstPartner = $this->user('PT Pertama', 'mitra1@test.dev', 'mitra');
        $secondPartner = $this->user('PT Kedua', 'mitra2@test.dev', 'mitra');
        $supervisor = $this->user('Dosen Pembimbing', 'dosen1@test.dev', 'dosen');
        $otherLecturer = $this->user('Dosen Lain', 'dosen2@test.dev', 'dosen');

        Mahasiswa::create([
            'id_mahasiswa' => $student->email_or_nim,
            'id_user' => $student->id,
            'nama' => $student->name,
            'jurusan' => 'Informatika',
        ]);
        $firstMitra = Mitra::create([
            'id_user' => $firstPartner->id,
            'nama_perusahaan' => 'PT Pertama',
        ]);
        $secondMitra = Mitra::create([
            'id_user' => $secondPartner->id,
            'nama_perusahaan' => 'PT Kedua',
        ]);
        $supervisorProfile = Dosen::create([
            'nidn' => '001',
            'id_user' => $supervisor->id,
            'nama' => $supervisor->name,
        ]);
        Dosen::create([
            'nidn' => '002',
            'id_user' => $otherLecturer->id,
            'nama' => $otherLecturer->name,
        ]);
        $firstVacancy = $this->vacancy($firstMitra, 'Flutter Developer');
        $secondVacancy = $this->vacancy($secondMitra, 'Backend Developer');

        return compact(
            'student',
            'firstPartner',
            'secondPartner',
            'supervisor',
            'otherLecturer',
            'firstMitra',
            'secondMitra',
            'supervisorProfile',
            'firstVacancy',
            'secondVacancy',
        );
    }

    private function apply(Lowongan $vacancy)
    {
        return $this->postJson('/api/pendaftaran', [
            'id_lowongan' => $vacancy->id_lowongan,
            'nama_lengkap' => 'Bintang Pratama',
            'no_telp' => '08123456789',
            'semester' => 6,
            'motivasi' => 'Ingin belajar.',
            'berkas_cv' => UploadedFile::fake()->create('cv.pdf', 100, 'application/pdf'),
        ]);
    }

    private function application(
        User $student,
        Lowongan $vacancy,
        string $status = 'pending',
    ): Pendaftaran {
        return Pendaftaran::create([
            'id_mahasiswa' => $student->email_or_nim,
            'id_lowongan' => $vacancy->id_lowongan,
            'status' => $status,
        ]);
    }

    private function vacancy(Mitra $mitra, string $title): Lowongan
    {
        return Lowongan::create([
            'id_mitra' => $mitra->id_mitra,
            'judul_posisi' => $title,
            'deskripsi' => 'Deskripsi.',
            'persyaratan' => 'Persyaratan.',
            'kategori' => 'Programming',
            'lokasi' => 'Yogyakarta',
            'tipe_kerja' => 'Hybrid',
            'tipe_kontrak' => 'Full-time',
            'kuota' => 5,
            'batas_waktu' => now()->addMonth()->toDateString(),
            'status_approval' => 'approved',
        ]);
    }

    private function user(string $name, string $identifier, string $role): User
    {
        return User::create([
            'name' => $name,
            'email_or_nim' => $identifier,
            'password' => 'password',
            'role' => $role,
        ]);
    }
}
