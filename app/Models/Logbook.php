<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Logbook extends Model
{
    use HasFactory;

    protected $table = 'logbook';

    protected $primaryKey = 'id_logbook';

    protected $fillable = [
        'id_pendaftaran',
        'minggu_ke',
        'tanggal',
        'deskripsi_kegiatan',
        'berkas_lampiran',
        'status_validasi',
        'feedback_dosen',
    ];

    protected $casts = [
        'minggu_ke' => 'integer',
        'tanggal' => 'date',
    ];

    public function pendaftaran()
    {
        return $this->belongsTo(Pendaftaran::class, 'id_pendaftaran', 'id_pendaftaran');
    }
}
