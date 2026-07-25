<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PendaftaranDraft extends Model
{
    protected $fillable = [
        'user_id',
        'id_lowongan',
        'nama_lengkap',
        'no_telp',
        'semester',
        'motivasi',
        'portfolio_link',
    ];

    protected $casts = [
        'semester' => 'integer',
    ];

    public function lowongan()
    {
        return $this->belongsTo(Lowongan::class, 'id_lowongan', 'id_lowongan');
    }
}
