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
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminMonitoringTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_lowongan_returns_all_statuses_filters_and_full_fields(): void
    {
        $data = $this->scenario();
        $pending = $this->vacancy($data['mitra'], 'Pending Vacancy', 'pending');
        $approved = $this->vacancy($data['mitra'], 'Approved Vacancy', 'approved');
        $rejected = $this->vacancy($data['mitra'], 'Rejected Vacancy', 'rejected');

        Sanctum::actingAs($data['admin']);

        $this->getJson('/api/admin/lowongan')
            ->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonPath('data.0.id_lowongan', $pending->id_lowongan)
            ->assertJsonStructure(['data' => [[
                'id_lowongan',
                'id_mitra',
                'nama_perusahaan',
                'judul_posisi',
                'deskripsi',
                'persyaratan',
                'kategori',
                'lokasi',
                'tipe_kerja',
                'tipe_kontrak',
                'benefit',
                'kuota',
                'batas_waktu',
                'status_approval',
                'created_at',
                'updated_at',
            ]]]);

        foreach ([
            'pending' => $pending,
            'approved' => $approved,
            'rejected' => $rejected,
        ] as $status => $vacancy) {
            $this->getJson('/api/admin/lowongan?status='.$status)
                ->assertOk()
                ->assertJsonCount(1, 'data')
                ->assertJsonPath('data.0.id_lowongan', $vacancy->id_lowongan)
                ->assertJsonPath('data.0.status_approval', $status);
        }
    }

    public function test_admin_sees_all_enrollments_and_non_admin_is_forbidden(): void
    {
        $data = $this->scenario();
        $application = $this->application($data, 'diterima');
        Logbook::create([
            'id_pendaftaran' => $application->id_pendaftaran,
            'minggu_ke' => 1,
            'tanggal' => now()->toDateString(),
            'deskripsi_kegiatan' => 'Integrasi API.',
            'status_validasi' => 'disetujui',
        ]);
        Bimbingan::create([
            'id_pendaftaran' => $application->id_pendaftaran,
            'nidn' => $data['dosen']->nidn,
        ]);

        Sanctum::actingAs($data['admin']);
        $this->getJson('/api/admin/enrollments?status=diterima&search=Bintang')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id_pendaftaran', $application->id_pendaftaran)
            ->assertJsonPath('data.0.nama_mahasiswa', 'Bintang Pratama')
            ->assertJsonPath('data.0.dosen_pembimbing', 'Dr. Rina Saraswati')
            ->assertJsonPath('data.0.jumlah_logbook', 1)
            ->assertJsonPath('data.0.progress', 8)
            ->assertJsonStructure(['meta' => [
                'current_page',
                'last_page',
                'per_page',
                'total',
            ]]);

        Sanctum::actingAs($data['studentUser']);
        $this->getJson('/api/admin/enrollments')->assertForbidden();
    }

    public function test_admin_user_details_are_role_specific_and_hide_secrets(): void
    {
        $data = $this->scenario();
        $application = $this->application($data, 'diterima');
        Bimbingan::create([
            'id_pendaftaran' => $application->id_pendaftaran,
            'nidn' => $data['dosen']->nidn,
        ]);
        Logbook::create([
            'id_pendaftaran' => $application->id_pendaftaran,
            'minggu_ke' => 1,
            'tanggal' => now()->toDateString(),
            'deskripsi_kegiatan' => 'Integrasi API.',
            'status_validasi' => 'disetujui',
        ]);

        Sanctum::actingAs($data['admin']);

        $studentResponse = $this->getJson('/api/admin/users/'.$data['studentUser']->id)
            ->assertOk()
            ->assertJsonPath('data.profile.nim', '23.11.5818')
            ->assertJsonPath('data.applications.0.id_pendaftaran', $application->id_pendaftaran)
            ->assertJsonPath('data.applications.0.jumlah_logbook', 1)
            ->assertJsonPath('data.supervisor.nidn', '001')
            ->assertJsonPath('data.supervisor.nama_dosen', 'Dr. Rina Saraswati')
            ->assertJsonPath('data.supervisor.jumlah_logbook', 1);

        $this->getJson('/api/admin/users/'.$data['lecturerUser']->id)
            ->assertOk()
            ->assertJsonPath('data.profile.nidn', '001')
            ->assertJsonPath('data.supervised_students.0.id_pendaftaran', $application->id_pendaftaran)
            ->assertJsonPath('data.supervised_students.0.nim', '23.11.5818')
            ->assertJsonPath('data.supervised_students.0.progress', 8);

        $this->getJson('/api/admin/users/'.$data['partnerUser']->id)
            ->assertOk()
            ->assertJsonPath('data.profile.id_mitra', $data['mitra']->id_mitra)
            ->assertJsonPath('data.vacancies.0.jumlah_pendaftar', 1)
            ->assertJsonPath('data.applicants.0.id_pendaftaran', $application->id_pendaftaran)
            ->assertJsonPath('data.applicants.0.nim', '23.11.5818')
            ->assertJsonPath('data.applicants.0.tanggal_daftar', fn ($value) => is_string($value));

        $payload = $studentResponse->getContent();
        $this->assertStringNotContainsString('"password"', $payload);
        $this->assertStringNotContainsString('remember_token', $payload);
        $this->assertStringNotContainsString('personal_access_tokens', $payload);
    }

    public function test_admin_users_list_has_clear_email_alias_and_no_secret_fields(): void
    {
        $data = $this->scenario();
        Sanctum::actingAs($data['admin']);

        $response = $this->getJson('/api/admin/users')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $data['studentUser']->id,
                'email' => '23.11.5818',
                'email_or_nim' => '23.11.5818',
                'username' => null,
                'role' => 'mahasiswa',
            ]);

        $this->assertStringNotContainsString('"password"', $response->getContent());
        $this->assertStringNotContainsString('remember_token', $response->getContent());
    }

    public function test_non_admin_cannot_access_admin_users_and_missing_user_is_json_404(): void
    {
        $data = $this->scenario();

        Sanctum::actingAs($data['studentUser']);
        $this->getJson('/api/admin/users')->assertForbidden();
        $this->getJson('/api/admin/users/'.$data['admin']->id)->assertForbidden();

        Sanctum::actingAs($data['admin']);
        $this->getJson('/api/admin/users/999999')
            ->assertNotFound()
            ->assertExactJson(['message' => 'Pengguna tidak ditemukan.']);
    }

    public function test_approve_and_reject_are_idempotent_and_only_transition_pending(): void
    {
        $data = $this->scenario();
        $pending = $this->vacancy($data['mitra'], 'Pending Vacancy', 'pending');
        $rejected = $this->vacancy($data['mitra'], 'Rejected Vacancy', 'rejected');
        Sanctum::actingAs($data['admin']);

        $this->postJson('/api/admin/lowongan/'.$pending->id_lowongan.'/approve')->assertOk();
        $this->postJson('/api/admin/lowongan/'.$pending->id_lowongan.'/approve')->assertOk();
        $this->postJson('/api/admin/lowongan/'.$pending->id_lowongan.'/reject')->assertStatus(409);
        $this->postJson('/api/admin/lowongan/'.$rejected->id_lowongan.'/reject')->assertOk();

        $this->assertSame(3, $pending->fresh()->kuota);
        $this->assertSame('approved', $pending->fresh()->status_approval);
    }

    private function scenario(): array
    {
        $admin = $this->user('Admin Nexus', 'admin@nexus.test', 'admin');
        $studentUser = $this->user('Bintang Pratama', '23.11.5818', 'mahasiswa');
        $lecturerUser = $this->user('Dr. Rina Saraswati', 'rina@nexus.test', 'dosen');
        $partnerUser = $this->user('PT Tokopedia Tech', 'mitra@nexus.test', 'mitra');

        $studentUser->update(['phone' => '08123456789', 'semester' => 6]);
        $mahasiswa = Mahasiswa::create([
            'id_mahasiswa' => '23.11.5818',
            'id_user' => $studentUser->id,
            'nama' => 'Bintang Pratama',
            'jurusan' => 'Informatika',
        ]);
        $dosen = Dosen::create([
            'nidn' => '001',
            'id_user' => $lecturerUser->id,
            'nama' => 'Dr. Rina Saraswati',
        ]);
        $mitra = Mitra::create([
            'id_user' => $partnerUser->id,
            'nama_perusahaan' => 'PT Tokopedia Tech',
        ]);

        return compact(
            'admin',
            'studentUser',
            'lecturerUser',
            'partnerUser',
            'mahasiswa',
            'dosen',
            'mitra',
        );
    }

    private function application(array $data, string $status): Pendaftaran
    {
        $vacancy = $this->vacancy($data['mitra'], 'Flutter Mobile Developer', 'approved');

        return Pendaftaran::create([
            'id_mahasiswa' => $data['mahasiswa']->id_mahasiswa,
            'id_lowongan' => $vacancy->id_lowongan,
            'status' => $status,
        ]);
    }

    private function vacancy(Mitra $mitra, string $title, string $status): Lowongan
    {
        return Lowongan::create([
            'id_mitra' => $mitra->id_mitra,
            'judul_posisi' => $title,
            'deskripsi' => 'Deskripsi lengkap.',
            'persyaratan' => 'Menguasai Flutter.',
            'kategori' => 'Programming',
            'lokasi' => 'Yogyakarta',
            'tipe_kerja' => 'Hybrid',
            'tipe_kontrak' => 'Full-time',
            'benefit' => 'Uang saku.',
            'kuota' => 3,
            'batas_waktu' => now()->addMonth()->toDateString(),
            'status_approval' => $status,
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
