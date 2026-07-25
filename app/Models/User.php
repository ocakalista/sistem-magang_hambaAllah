<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email_or_nim',
        'password',
        'phone',
        'semester',
        'role',
        'konsentrasi',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'role' => 'string',
    ];

    // Alias untuk Flutter admin profile yang meminta field `username`
    // (DB tidak punya kolom `username`, jadi kembalikan email_or_nim)
    public function getUsernameAttribute(): ?string
    {
        return $this->email_or_nim;
    }

    public function mitra()
    {
        return $this->hasOne(Mitra::class, 'id_user');
    }

    public function mahasiswa()
    {
        return $this->hasOne(Mahasiswa::class, 'id_user');
    }

    public function dosen()
    {
        return $this->hasOne(Dosen::class, 'id_user');
    }

    public function savedLowongan()
    {
        return $this->hasMany(SavedLowongan::class);
    }

    public function pendaftaranDrafts()
    {
        return $this->hasMany(PendaftaranDraft::class);
    }
}
