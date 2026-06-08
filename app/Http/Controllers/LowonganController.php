<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Lowongan; // Memanggil model Lowongan

class LowonganController extends Controller
{
    public function index()
    {
        $data = Lowongan::all();

        return response()->json([
            'status' => 'sukses',
            'pesan' => 'Berhasil mengambil data lowongan',
            'data' => $data
        ]);
    }
}