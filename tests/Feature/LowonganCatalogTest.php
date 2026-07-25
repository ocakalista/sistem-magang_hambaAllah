<?php

namespace Tests\Feature;

use App\Models\Lowongan;
use App\Models\Mitra;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LowonganCatalogTest extends TestCase
{
    use RefreshDatabase;

    public function test_catalog_includes_company_and_supports_all_filters(): void
    {
        $this->createLowongan('Flutter Developer', 'Programming', 'Yogyakarta', 'Hybrid', 'Nexus Tech');
        $this->createLowongan('Network Engineer', 'Networking', 'Jakarta', 'On-site', 'Other Corp');

        $this->getJson('/api/lowongan?search=Nexus&kategori=Programming&lokasi=Yogyakarta&tipe_kerja=Hybrid')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.nama_perusahaan', 'Nexus Tech')
            ->assertJsonPath('data.0.judul_posisi', 'Flutter Developer');
    }

    public function test_catalog_pagination_keeps_data_as_list_and_adds_meta_and_links(): void
    {
        $this->createLowongan('Flutter Developer', 'Programming', 'Yogyakarta', 'Hybrid', 'Nexus Tech');
        $this->createLowongan('Backend Developer', 'Programming', 'Bandung', 'Remote', 'Nexus Tech');

        $this->getJson('/api/lowongan?page=1&per_page=1')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('meta.current_page', 1)
            ->assertJsonPath('meta.per_page', 1)
            ->assertJsonPath('meta.total', 2)
            ->assertJsonStructure(['links' => ['next', 'previous']]);
    }

    public function test_detail_uses_consistent_envelope_and_company_name(): void
    {
        $lowongan = $this->createLowongan(
            'Flutter Developer',
            'Programming',
            'Yogyakarta',
            'Hybrid',
            'Nexus Tech',
        );

        $this->getJson('/api/lowongan/'.$lowongan->id_lowongan)
            ->assertOk()
            ->assertJsonPath('nama_perusahaan', 'Nexus Tech')
            ->assertJsonPath('id_lowongan', $lowongan->id_lowongan);
    }

    private function createLowongan(
        string $title,
        string $category,
        string $location,
        string $workType,
        string $company,
    ): Lowongan {
        $user = User::create([
            'name' => $company,
            'email_or_nim' => uniqid('mitra_', true),
            'password' => 'password',
            'role' => 'mitra',
        ]);
        $mitra = Mitra::create([
            'id_user' => $user->id,
            'nama_perusahaan' => $company,
        ]);

        return Lowongan::create([
            'id_mitra' => $mitra->id_mitra,
            'judul_posisi' => $title,
            'deskripsi' => 'Deskripsi',
            'persyaratan' => 'Persyaratan',
            'kategori' => $category,
            'lokasi' => $location,
            'tipe_kerja' => $workType,
            'tipe_kontrak' => 'Full-time',
            'kuota' => 3,
            'batas_waktu' => now()->addMonth()->toDateString(),
            'status_approval' => 'approved',
        ]);
    }
}
