<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Dosen extends Model
{
    use HasFactory;

    protected $table = 'dosen';
    protected $primaryKey = 'nidn';
    protected $keyType = 'string';
    public $incrementing = false;
    protected $fillable = ['nidn', 'id_user', 'nama'];

    public function user()
    {
        return $this->belongsTo(User::class, 'id_user');
    }

    public function bimbingan()
    {
        return $this->hasMany(Bimbingan::class, 'nidn', 'nidn');
    }
}
