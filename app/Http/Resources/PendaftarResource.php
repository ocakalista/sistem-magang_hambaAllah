<?php

namespace App\Http\Resources;

use App\Support\PublicFileUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PendaftarResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $user = $this->mahasiswa?->user;
        $portfolioUrl = PublicFileUrl::from($this->portofolio);

        return [
            'id_pendaftaran' => $this->id_pendaftaran,
            'id_lowongan' => $this->id_lowongan,
            'nama_mahasiswa' => $this->mahasiswa?->nama,
            'nim' => $this->id_mahasiswa,
            'jurusan' => $this->mahasiswa?->jurusan,
            'semester' => $user?->semester !== null ? (int) $user->semester : null,
            'email' => $user?->email_or_nim,
            'no_telp' => $user?->phone !== null ? (string) $user->phone : null,
            'status' => (string) $this->status,
            'tanggal_daftar' => $this->created_at?->toISOString(),
            'motivasi' => $this->motivasi,
            'url_cv' => PublicFileUrl::from($this->berkas_cv),
            'url_portofolio' => $portfolioUrl,
            'portofolio_link' => $this->portfolio_link,
            'portfolio' => [
                'file_url' => $portfolioUrl,
                'link' => $this->portfolio_link,
            ],
        ];
    }
}
