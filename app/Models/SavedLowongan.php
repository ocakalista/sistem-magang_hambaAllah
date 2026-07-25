<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SavedLowongan extends Model
{
    protected $table = 'saved_lowongan';

    protected $fillable = ['user_id', 'id_lowongan'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function lowongan()
    {
        return $this->belongsTo(Lowongan::class, 'id_lowongan', 'id_lowongan');
    }
}
