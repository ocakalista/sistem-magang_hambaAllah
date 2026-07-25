<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PendaftaranResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id_pendaftaran' => $this->id_pendaftaran,
            'id_mahasiswa' => $this->id_mahasiswa,
            'id_lowongan' => $this->id_lowongan,
            'status' => $this->status,
            'tanggal_daftar' => $this->created_at?->toISOString(),
            'accepted_at' => $this->accepted_at?->toISOString(),
            'rejected_at' => $this->rejected_at?->toISOString(),
            'withdrawn_at' => $this->withdrawn_at?->toISOString(),
            'completed_at' => $this->completed_at?->toISOString(),
            'rejection_reason' => $this->rejection_reason,
            'total_weeks' => config('internship.total_weeks'),
            'motivasi' => $this->motivasi,
            'berkas_cv' => $this->berkas_cv,
            'portofolio' => $this->portofolio,
            'portfolio_link' => $this->portfolio_link,
            'dosen_pembimbing' => $this->whenLoaded('bimbingan', function () {
                $dosen = $this->bimbingan?->dosen;

                return $dosen ? [
                    'id_dosen' => $dosen->nidn,
                    'nama_lengkap' => $dosen->user?->name ?? $dosen->nama,
                    'nidn' => $dosen->nidn,
                ] : null;
            }),
            'lowongan' => $this->whenLoaded('lowongan', fn () => [
                'id_lowongan' => $this->lowongan?->id_lowongan,
                'judul_posisi' => $this->lowongan?->judul_posisi,
                'nama_perusahaan' => $this->lowongan?->mitra?->nama_perusahaan,
                'lokasi' => $this->lowongan?->lokasi,
                'kategori' => $this->lowongan?->kategori,
            ]),
            'logbooks' => $this->whenLoaded('logbook'),
        ];
    }
}
