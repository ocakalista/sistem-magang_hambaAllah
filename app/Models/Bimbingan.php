<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Bimbingan extends Model
{
    use HasFactory;

    protected $table = 'bimbingan';
    protected $primaryKey = 'id_bimbingan';
    protected $fillable = [
        'id_pendaftaran',
        'nidn',
<<<<<<< HEAD
        'status_verifikasi',
        'catatan_verifikasi'
=======
>>>>>>> f6b3645b01dc7980f13ef018c69ed208e5e79b85
    ];

    public function pendaftaran()
    {
        return $this->belongsTo(Pendaftaran::class, 'id_pendaftaran');
    }

    public function dosen()
    {
        return $this->belongsTo(Dosen::class, 'nidn', 'nidn');
    }
}
