<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Lowongan extends Model
{
    use HasFactory;

    // 1. Kasih tau Laravel nama tabel aslinya
    protected $table = 'lowongan';

    // 2. Kasih tau Laravel nama primary key aslinya
    protected $primaryKey = 'id_lowongan';

    // 3. Izin akses untuk fungsi ::create() di Controller (Mencegah Error Mass Assignment)
    protected $fillable = [
        'id_mitra',
        'judul_posisi',
        'kuota',
        'batas_waktu',
        'status_approval'
    ];
}