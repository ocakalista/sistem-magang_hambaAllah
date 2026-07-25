<?php

namespace App\Http\Resources;

use App\Support\PublicFileUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LogbookResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $lecturer = $this->validatorDosen
            ?? $this->pendaftaran?->bimbingan?->dosen;
        $fileUrl = PublicFileUrl::from($this->berkas_lampiran);

        return [
            'id_logbook' => $this->id_logbook,
            'id_pendaftaran' => $this->id_pendaftaran,
            'minggu_ke' => (int) $this->minggu_ke,
            'tanggal' => $this->tanggal?->toDateString(),
            'deskripsi_kegiatan' => $this->deskripsi_kegiatan,
            'berkas_logbook' => $this->berkas_lampiran,
            'url_berkas_logbook' => $fileUrl,
            'berkas_lampiran_url' => $fileUrl,
            'tipe_konten' => $this->deskripsi_kegiatan && $this->berkas_lampiran
                ? 'teks_dan_file'
                : ($this->berkas_lampiran ? 'file' : 'teks'),
            'status_validasi' => $this->status_validasi,
            'feedback_dosen' => $this->feedback_dosen,
            'id_dosen_feedback' => $this->id_dosen_feedback,
            'nama_dosen' => $lecturer?->user?->name ?? $lecturer?->nama,
            'validated_at' => $this->validated_at?->toISOString(),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}
