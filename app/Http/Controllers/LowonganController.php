<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Lowongan;

class LowonganController extends Controller
{
    public function index()
    {
        $data = Lowongan::all();

        return response()->json([
            'status' => 'sukses',
            'pesan' => 'Berhasil mengambil data lowongan',
            'data' => \App\Models\Pendaftaran::all()
        ]);
    }
    public function store(Request $request)
    {
        $data = Lowongan::create($request->all());

        return response()->json([
            'status' => 'sukses',
            'pesan' => 'Berhasil menambahkan lowongan',
            'data' => $data
        ]);
    }

}