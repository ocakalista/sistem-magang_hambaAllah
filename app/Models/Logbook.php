<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Logbook extends Model
{
    protected $table      = 'logbook';
    protected $primaryKey = 'id_logbook';
    protected $guarded = [];
}
