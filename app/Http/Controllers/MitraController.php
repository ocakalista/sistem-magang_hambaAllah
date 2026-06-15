<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class MitraController extends Controller
{
    public function index()
    {
        return response()->json(['status' => 'sukses', 'data' => \App\Models\Mitra::all()]);
    }
}
