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

class LogbookWorkflowTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_submission_notifies_supervisor_with_approval_metadata_only(): void
    {
        Storage::fake('public');
        $data = $this->scenario();
        Sanctum::actingAs($data['student']);

        $response = $this->post('/api/logbook', [
            'id_pendaftaran' => $data['pendaftaran']->id_pendaftaran,
            'minggu_ke' => 1,
            'tanggal' => '2026-07-25',
            'deskripsi_kegiatan' => 'Mengerjakan integrasi API.',
            'berkas_logbook' => UploadedFile::fake()
                ->create('minggu-1.pdf', 100, 'application/pdf'),
        ])->assertCreated();

        $idLogbook = $response->json('data.id_logbook');
        $logbook = Logbook::findOrFail($idLogbook);
        Storage::disk('public')->assertExists($logbook->berkas_lampiran);
        $this->assertStringStartsWith('logbook/', $logbook->berkas_lampiran);
        $this->assertSame(0, $data['student']->notifications()->count());
        $this->assertSame(1, $data['supervisor']->notifications()->count());

        Sanctum::actingAs($data['supervisor']);
        $this->getJson('/api/notifications')
            ->assertOk()
            ->assertJsonPath('data.0.type', 'logbook_submitted')
            ->assertJsonPath('data.0.data.id_logbook', $idLogbook)
            ->assertJsonPath('data.0.data.category', 'approval')
            ->assertJsonPath('data.0.data.requires_action', true)
            ->assertJsonPath('data.0.data.priority', 'high');
    }

    public function test_logbook_requires_pdf_with_maximum_size(): void
    {
        Storage::fake('public');
        $data = $this->scenario();
        Sanctum::actingAs($data['student']);
        $payload = [
            'id_pendaftaran' => $data['pendaftaran']->id_pendaftaran,
            'minggu_ke' => 1,
            'tanggal' => '2026-07-25',
            'deskripsi_kegiatan' => 'Mengerjakan integrasi API.',
        ];

        $this->post('/api/logbook', $payload + [
            'berkas_logbook' => UploadedFile::fake()
                ->create('catatan.docx', 100, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'),
        ])->assertUnprocessable()->assertJsonValidationErrors('berkas_logbook');

        $this->post('/api/logbook', $payload + [
            'berkas_logbook' => UploadedFile::fake()
                ->create('terlalu-besar.pdf', 5121, 'application/pdf'),
        ])->assertUnprocessable()->assertJsonValidationErrors('berkas_logbook');
    }

    public function test_other_student_and_duplicate_week_are_rejected_and_get_returns_pdf_url(): void
    {
        Storage::fake('public');
        config([
            'app.url' => 'https://sistem-maganghambaallah-production-5b92.up.railway.app',
            'filesystems.disks.public.url' => 'https://sistem-maganghambaallah-production-5b92.up.railway.app/storage',
        ]);
        $data = $this->scenario();
        $payload = fn () => [
            'id_pendaftaran' => $data['pendaftaran']->id_pendaftaran,
            'minggu_ke' => 1,
            'tanggal' => '2026-07-25',
            'deskripsi_kegiatan' => 'Mengerjakan integrasi API.',
            'berkas_logbook' => UploadedFile::fake()
                ->create('minggu-1.pdf', 100, 'application/pdf'),
        ];

        Sanctum::actingAs($data['otherStudent']);
        $this->post('/api/logbook', $payload())->assertForbidden();

        Sanctum::actingAs($data['student']);
        $first = $this->post('/api/logbook', $payload())->assertCreated();
        $this->post('/api/logbook', $payload())
            ->assertUnprocessable()
            ->assertJsonPath('code', 'DUPLICATE_LOGBOOK_WEEK');

        $this->getJson('/api/logbook')
            ->assertOk()
            ->assertJsonPath('data.0.id_logbook', $first->json('data.id_logbook'))
            ->assertJsonPath('data.0.berkas_logbook', $first->json('data.berkas_logbook'))
            ->assertJsonPath(
                'data.0.url_berkas_logbook',
                'https://sistem-maganghambaallah-production-5b92.up.railway.app/storage/'
                    .$first->json('data.berkas_logbook'),
            );
    }

    public function test_only_assigned_supervisor_can_review_and_student_receives_update(): void
    {
        $data = $this->scenario();
        $logbook = $this->logbook($data['pendaftaran']);

        Sanctum::actingAs($data['otherLecturer']);
        $this->putJson('/api/logbook/'.$logbook->id_logbook.'/status', [
            'status_validasi' => 'disetujui',
        ])->assertForbidden();

        Sanctum::actingAs($data['supervisor']);
        $this->putJson('/api/logbook/'.$logbook->id_logbook.'/status', [
            'status_validasi' => 'revisi',
        ])->assertUnprocessable()->assertJsonValidationErrors('feedback_dosen');

        $this->putJson('/api/logbook/'.$logbook->id_logbook.'/status', [
            'status_validasi' => 'revisi',
            'feedback_dosen' => 'Tambahkan bukti hasil pengujian.',
            'id_dosen_feedback' => '002',
        ])->assertOk()->assertJsonPath('data.status_validasi', 'revisi');

        $this->assertSame('001', $logbook->fresh()->id_dosen_feedback);
        $this->assertNotNull($logbook->fresh()->validated_at);

        $notification = $data['student']->notifications()->first();
        $this->assertNotNull($notification);
        $this->assertSame('status_logbook', $notification->data['type']);
        $this->assertSame('update', $notification->data['metadata']['category']);
        $this->assertFalse($notification->data['metadata']['requires_action']);

        Sanctum::actingAs($data['student']);
        $this->getJson('/api/logbook')
            ->assertOk()
            ->assertJsonPath('data.0.feedback_dosen', 'Tambahkan bukti hasil pengujian.')
            ->assertJsonPath('data.0.id_dosen_feedback', '001')
            ->assertJsonPath('data.0.nama_dosen', $data['supervisor']->name);
    }

    public function test_student_can_resubmit_revised_logbook_and_supervisor_is_notified(): void
    {
        Storage::fake('public');
        $data = $this->scenario();
        $logbook = $this->logbook($data['pendaftaran'], 'revisi');

        Sanctum::actingAs($data['student']);
        $this->putJson('/api/logbook/'.$logbook->id_logbook, [
            'tanggal' => '2026-07-26',
            'deskripsi_kegiatan' => 'Laporan sudah dilengkapi hasil pengujian.',
        ])->assertOk()
            ->assertJsonPath('data.status_validasi', 'pending')
            ->assertJsonPath('data.feedback_dosen', null);

        $notification = $data['supervisor']->notifications()->first();
        $this->assertNotNull($notification);
        $this->assertSame('logbook_resubmitted', $notification->data['type']);
        $this->assertSame($logbook->id_logbook, $notification->data['metadata']['id_logbook']);
        $this->assertSame('approval', $notification->data['metadata']['category']);
    }

    public function test_other_student_cannot_resubmit_and_weekly_reports_include_required_fields(): void
    {
        $data = $this->scenario();
        $logbook = $this->logbook($data['pendaftaran'], 'revisi');

        Sanctum::actingAs($data['otherStudent']);
        $this->putJson('/api/logbook/'.$logbook->id_logbook, [
            'tanggal' => '2026-07-26',
            'deskripsi_kegiatan' => 'Mencoba mengubah logbook orang lain.',
        ])->assertForbidden();

        Sanctum::actingAs($data['supervisor']);
        $this->getJson('/api/dosen/bimbingan')
            ->assertOk()
            ->assertJsonPath('data.0.weeklyReports.0.id', $logbook->id_logbook)
            ->assertJsonPath('data.0.weeklyReports.0.minggu_ke', 1)
            ->assertJsonPath('data.0.weeklyReports.0.tanggal', '2026-07-25')
            ->assertJsonPath('data.0.weeklyReports.0.deskripsi', 'Aktivitas minggu pertama.')
            ->assertJsonPath('data.0.weeklyReports.0.status_validasi', 'revisi')
            ->assertJsonPath('data.0.weeklyReports.0.feedback_dosen', 'Perlu perbaikan.');
    }

    public function test_supervision_response_contains_real_profile_and_only_assigned_students(): void
    {
        $data = $this->scenario();
        $this->logbook($data['pendaftaran']);
        $data['student']->update(['phone' => '081234567890']);

        Mahasiswa::create([
            'id_mahasiswa' => $data['otherStudent']->email_or_nim,
            'id_user' => $data['otherStudent']->id,
            'nama' => $data['otherStudent']->name,
            'jurusan' => 'Sistem Informasi',
        ]);
        $otherApplication = Pendaftaran::create([
            'id_mahasiswa' => $data['otherStudent']->email_or_nim,
            'id_lowongan' => $data['pendaftaran']->id_lowongan,
            'status' => 'diterima',
        ]);
        Bimbingan::create([
            'id_pendaftaran' => $otherApplication->id_pendaftaran,
            'nidn' => '002',
            'status_verifikasi' => 'disetujui',
        ]);

        Sanctum::actingAs($data['supervisor']);
        $this->getJson('/api/dosen/bimbingan')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $data['student']->email_or_nim)
            ->assertJsonPath('data.0.name', $data['student']->name)
            ->assertJsonPath('data.0.email', $data['student']->email_or_nim)
            ->assertJsonPath('data.0.phone', '081234567890')
            ->assertJsonPath('data.0.study_program', 'Informatika')
            ->assertJsonStructure([
                'data' => [[
                    'id',
                    'name',
                    'email',
                    'phone',
                    'study_program',
                    'position',
                    'company',
                    'currentWeek',
                    'totalWeeks',
                    'progress',
                    'weeklyReports',
                ]],
            ]);

        Sanctum::actingAs($data['otherLecturer']);
        $this->getJson('/api/dosen/bimbingan')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', $data['otherStudent']->email_or_nim);
    }

    public function test_application_history_contains_real_supervisor_and_is_scoped_to_student(): void
    {
        $data = $this->scenario();

        Sanctum::actingAs($data['student']);
        $this->getJson('/api/pendaftaran/riwayat')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id_pendaftaran', $data['pendaftaran']->id_pendaftaran)
            ->assertJsonPath('data.0.dosen_pembimbing.id_dosen', '001')
            ->assertJsonPath('data.0.dosen_pembimbing.nidn', '001')
            ->assertJsonPath(
                'data.0.dosen_pembimbing.nama_lengkap',
                $data['supervisor']->name,
            );

        Sanctum::actingAs($data['otherStudent']);
        $this->getJson('/api/pendaftaran/riwayat')
            ->assertOk()
            ->assertJsonPath('data', []);
    }

    public function test_missing_supervisor_returns_null_without_server_error(): void
    {
        $data = $this->scenario();
        $withoutSupervisor = Pendaftaran::create([
            'id_mahasiswa' => $data['student']->email_or_nim,
            'id_lowongan' => $data['pendaftaran']->id_lowongan,
            'status' => 'accepted',
        ]);

        Sanctum::actingAs($data['student']);
        $response = $this->getJson('/api/pendaftaran/riwayat')->assertOk();
        $item = collect($response->json('data'))
            ->firstWhere('id_pendaftaran', $withoutSupervisor->id_pendaftaran);

        $this->assertNull($item['dosen_pembimbing']);
    }

    private function scenario(): array
    {
        $student = $this->user('Mahasiswa', '22.11.0001', 'mahasiswa');
        $otherStudent = $this->user('Mahasiswa Lain', '22.11.0002', 'mahasiswa');
        $supervisor = $this->user('Dosen Pembimbing', 'dosen001', 'dosen');
        $otherLecturer = $this->user('Dosen Lain', 'dosen002', 'dosen');
        $partner = $this->user('Mitra', 'mitra001', 'mitra');

        Mahasiswa::create([
            'id_mahasiswa' => $student->email_or_nim,
            'id_user' => $student->id,
            'nama' => $student->name,
            'jurusan' => 'Informatika',
        ]);
        Dosen::create(['nidn' => '001', 'id_user' => $supervisor->id, 'nama' => $supervisor->name]);
        Dosen::create(['nidn' => '002', 'id_user' => $otherLecturer->id, 'nama' => $otherLecturer->name]);
        $mitra = Mitra::create(['id_user' => $partner->id, 'nama_perusahaan' => 'PT Nexus']);
        $lowongan = Lowongan::create([
            'id_mitra' => $mitra->id_mitra,
            'judul_posisi' => 'Flutter Developer',
            'kuota' => 3,
            'batas_waktu' => now()->addMonth()->toDateString(),
            'status_approval' => 'approved',
        ]);
        $pendaftaran = Pendaftaran::create([
            'id_mahasiswa' => $student->email_or_nim,
            'id_lowongan' => $lowongan->id_lowongan,
            'status' => 'diterima',
        ]);
        Bimbingan::create([
            'id_pendaftaran' => $pendaftaran->id_pendaftaran,
            'nidn' => '001',
            'status_verifikasi' => 'disetujui',
        ]);

        return compact(
            'student',
            'otherStudent',
            'supervisor',
            'otherLecturer',
            'pendaftaran',
        );
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

    private function logbook(Pendaftaran $pendaftaran, string $status = 'pending'): Logbook
    {
        return Logbook::create([
            'id_pendaftaran' => $pendaftaran->id_pendaftaran,
            'minggu_ke' => 1,
            'tanggal' => '2026-07-25',
            'deskripsi_kegiatan' => 'Aktivitas minggu pertama.',
            'status_validasi' => $status,
            'feedback_dosen' => $status === 'revisi' ? 'Perlu perbaikan.' : null,
        ]);
    }
}
