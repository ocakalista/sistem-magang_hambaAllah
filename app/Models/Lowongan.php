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
        'status_approval',
    ];

    protected $casts = [
        'batas_waktu' => 'date',
        'kuota' => 'integer',
    ];

    public function mitra()
    {
        return $this->belongsTo(Mitra::class, 'id_mitra', 'id_mitra');
    }

    public function pendaftaran()
    {
        return $this->hasMany(Pendaftaran::class, 'id_lowongan', 'id_lowongan');
    }

    public function savedBy()
    {
        return $this->hasMany(SavedLowongan::class, 'id_lowongan', 'id_lowongan');
    }

    public function scopeApproved($query)
    {
        return $query->where('status_approval', 'approved');
    }

    public function scopePending($query)
    {
        return $query->where('status_approval', 'pending');
    }
}
