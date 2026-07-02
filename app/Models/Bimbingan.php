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
        'nidn'
    ];
}