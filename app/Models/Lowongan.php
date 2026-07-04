<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Lowongan extends Model
{
    use HasFactory;

    protected $table = 'lowongan';

    protected $primaryKey = 'id_lowongan';

    protected $fillable = [
        'id_mitra',
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
        'status_approval'
    ];
}