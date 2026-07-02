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
        'kuota',
        'batas_waktu',
        'status_approval'
    ];
}