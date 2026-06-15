<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PendaftaranController extends Controller
{
    public function index()
    {
        return response()->json(['status' => 'sukses', 'data' => \App\Models\Pendaftaran::all()]);
    }
}
