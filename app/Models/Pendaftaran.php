<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pendaftaran extends Model
{
    use HasFactory;

    protected $table = 'pendaftaran';

    protected $primaryKey = 'id_pendaftaran';

    protected $fillable = [
        'id_mahasiswa',
        'id_lowongan',
        'berkas_cv',
        'portofolio',
        'portfolio_link',
        'motivasi',
        'status',
        'laporan_akhir',
    ];

    public function mahasiswa()
    {
        // mahasiswa.id_mahasiswa adalah NIM (string) dan pendaftaran.id_mahasiswa
        // berisi NIM yang sama, jadi join on kolom yang sama
        return $this->belongsTo(Mahasiswa::class, 'id_mahasiswa', 'id_mahasiswa');
    }

    public function lowongan()
    {
        return $this->belongsTo(Lowongan::class, 'id_lowongan', 'id_lowongan');
    }

    public function logbook()
    {
        return $this->hasMany(Logbook::class, 'id_pendaftaran', 'id_pendaftaran');
    }

    public function bimbingan()
    {
        return $this->hasOne(Bimbingan::class, 'id_pendaftaran', 'id_pendaftaran');
    }
}
