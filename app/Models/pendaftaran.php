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
        'motivasi',
        'berkas_cv',
        'portofolio',
        'status',
        'laporan_akhir',
    ];
}