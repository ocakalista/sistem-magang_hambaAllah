<?php

namespace Tests\Feature;

use App\Models\Lowongan;
use App\Models\Mahasiswa;
use App\Models\Mitra;
use App\Models\Pendaftaran;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MitraApplicantTest extends TestCase
{
    use RefreshDatabase;

    public function test_partner_can_only_view_complete_applicants_for_own_vacancy(): void
    {
        $data = $this->scenario();
        config([
            'app.url' => 'https://sistem-maganghambaallah-production-5b92.up.railway.app',
            'filesystems.disks.public.url' => 'https://sistem-maganghambaallah-production-5b92.up.railway.app/storage',
        ]);

        Sanctum::actingAs($data['partner']);
        $this->getJson('/api/lowongan/'.$data['ownLowongan']->id_lowongan.'/pelamar')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id_pendaftaran', $data['application']->id_pendaftaran)
            ->assertJsonPath('data.0.id_lowongan', $data['ownLowongan']->id_lowongan)
            ->assertJsonPath('data.0.nama_mahasiswa', 'Haikal Utami')
            ->assertJsonPath('data.0.nim', '23.11.5818')
            ->assertJsonPath('data.0.jurusan', 'Informatika')
            ->assertJsonPath('data.0.email', '23.11.5818')
            ->assertJsonPath('data.0.no_telp', '08123456789')
            ->assertJsonPath('data.0.semester', 6)
            ->assertJsonPath('data.0.motivasi', 'Saya tertarik mengikuti program ini.')
            ->assertJsonPath(
                'data.0.url_cv',
                'https://sistem-maganghambaallah-production-5b92.up.railway.app/storage/berkas_cv/cv.pdf',
            )
            ->assertJsonPath(
                'data.0.url_portofolio',
                'https://sistem-maganghambaallah-production-5b92.up.railway.app/storage/berkas_portofolio/portfolio.pdf',
            )
            ->assertJsonPath('data.0.portofolio_link', 'https://portfolio.example.com');

        $this->assertStringStartsWith(
            'https://',
            $this->getJson('/api/lowongan/'.$data['ownLowongan']->id_lowongan.'/pelamar')
                ->json('data.0.url_cv'),
        );

        $this->getJson('/api/lowongan/'.$data['otherLowongan']->id_lowongan.'/pelamar')
            ->assertForbidden();
    }

    public function test_other_partner_cannot_update_application_status(): void
    {
        $data = $this->scenario();
        Sanctum::actingAs($data['otherPartner']);

        $this->putJson('/api/pendaftaran/'.$data['application']->id_pendaftaran.'/status', [
            'status' => 'diterima',
        ])->assertForbidden();

        $this->assertSame('pending', $data['application']->fresh()->status);
    }

    public function test_owned_vacancy_without_applicants_returns_an_empty_array(): void
    {
        $data = $this->scenario();
        $emptyVacancy = $this->lowongan(
            Mitra::where('id_user', $data['partner']->id)->firstOrFail()
        );
        Sanctum::actingAs($data['partner']);

        $this->getJson('/api/lowongan/'.$emptyVacancy->id_lowongan.'/pelamar')
            ->assertOk()
            ->assertJsonPath('data', []);
    }

    public function test_document_urls_normalize_legacy_storage_prefixes_and_null_portfolio(): void
    {
        $data = $this->scenario();
        config([
            'app.url' => 'https://sistem-maganghambaallah-production-5b92.up.railway.app',
            'filesystems.disks.public.url' => 'https://sistem-maganghambaallah-production-5b92.up.railway.app/storage',
        ]);
        $data['application']->update([
            'berkas_cv' => 'storage\\storage\\pendaftaran\\cv\\cv.pdf',
            'portofolio' => null,
        ]);
        Sanctum::actingAs($data['partner']);

        $this->getJson('/api/lowongan/'.$data['ownLowongan']->id_lowongan.'/pelamar')
            ->assertOk()
            ->assertJsonPath(
                'data.0.url_cv',
                'https://sistem-maganghambaallah-production-5b92.up.railway.app/storage/pendaftaran/cv/cv.pdf',
            )
            ->assertJsonPath('data.0.url_portofolio', null)
            ->assertJsonPath('data.0.no_telp', '08123456789')
            ->assertJsonPath('data.0.semester', 6);
    }

    public function test_accepting_rejected_applicant_is_idempotent_for_quota_and_notification(): void
    {
        $data = $this->scenario();
        $data['application']->update(['status' => 'rejected']);
        $data['ownLowongan']->update(['kuota' => 3]);
        Sanctum::actingAs($data['partner']);

        $this->putJson('/api/pendaftaran/'.$data['application']->id_pendaftaran.'/status', [
            'status' => 'accepted',
        ])->assertOk()->assertJsonPath('data.status', 'accepted');

        $this->assertSame(2, $data['ownLowongan']->fresh()->kuota);
        $this->assertSame(1, $data['student']->notifications()->count());

        $this->putJson('/api/pendaftaran/'.$data['application']->id_pendaftaran.'/status', [
            'status' => 'accepted',
        ])->assertOk()->assertJsonPath('message', 'Status pendaftaran tidak berubah.');

        $this->assertSame(2, $data['ownLowongan']->fresh()->kuota);
        $this->assertSame(1, $data['student']->notifications()->count());

        $notification = $data['student']->notifications()->first();
        $this->assertSame('Lamaran diterima', $notification->data['title']);
        $this->assertSame($data['application']->id_pendaftaran, $notification->data['metadata']['id_pendaftaran']);
        $this->assertSame('update', $notification->data['metadata']['category']);
        $this->assertFalse($notification->data['metadata']['requires_action']);
    }

    private function scenario(): array
    {
        Storage::fake('public');

        $partner = $this->user('PT Nexus', 'mitra@nexus.test', 'mitra');
        $otherPartner = $this->user('PT Lain', 'mitra@lain.test', 'mitra');
        $student = $this->user('Haikal Utami', '23.11.5818', 'mahasiswa', [
            'phone' => '08123456789',
            'semester' => '6',
        ]);

        $mitra = Mitra::create(['id_user' => $partner->id, 'nama_perusahaan' => 'PT Nexus']);
        $otherMitra = Mitra::create(['id_user' => $otherPartner->id, 'nama_perusahaan' => 'PT Lain']);
        Mahasiswa::create([
            'id_mahasiswa' => $student->email_or_nim,
            'id_user' => $student->id,
            'nama' => $student->name,
            'jurusan' => 'Informatika',
        ]);

        $ownLowongan = $this->lowongan($mitra);
        $otherLowongan = $this->lowongan($otherMitra);
        $application = Pendaftaran::create([
            'id_mahasiswa' => $student->email_or_nim,
            'id_lowongan' => $ownLowongan->id_lowongan,
            'berkas_cv' => 'berkas_cv/cv.pdf',
            'portofolio' => 'berkas_portofolio/portfolio.pdf',
            'portfolio_link' => 'https://portfolio.example.com',
            'motivasi' => 'Saya tertarik mengikuti program ini.',
            'status' => 'pending',
        ]);

        return compact(
            'partner',
            'otherPartner',
            'student',
            'ownLowongan',
            'otherLowongan',
            'application',
        );
    }

    private function user(string $name, string $identifier, string $role, array $extra = []): User
    {
        return User::create([
            'name' => $name,
            'email_or_nim' => $identifier,
            'password' => 'password',
            'role' => $role,
            ...$extra,
        ]);
    }

    private function lowongan(Mitra $mitra): Lowongan
    {
        return Lowongan::create([
            'id_mitra' => $mitra->id_mitra,
            'judul_posisi' => 'Flutter Developer',
            'kuota' => 2,
            'batas_waktu' => now()->addMonth()->toDateString(),
            'status_approval' => 'approved',
        ]);
    }
}
