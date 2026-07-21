<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mahasiswa extends Model
{
    use HasFactory;

    protected $table = 'mahasiswa';
    protected $primaryKey = 'id_mahasiswa';
    protected $keyType = 'string';
    public $incrementing = false;
    protected $fillable = ['id_mahasiswa', 'id_user', 'nama', 'jurusan'];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    public function pendaftaran()
    {
        return $this->hasMany(Pendaftaran::class, 'id_mahasiswa', 'id_mahasiswa');
    }

    public function bimbingan()
    {
        return $this->hasMany(Bimbingan::class, 'id_pendaftaran');
    }
}
