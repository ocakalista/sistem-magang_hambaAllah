<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Lowongan;

class LowonganController extends Controller
{
    public function index()
    {
        // Mengembalikan semua daftar lowongan
        return response()->json(Lowongan::all(), 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_mitra' => 'required',
            'judul_posisi' => 'required|string',
            'kuota' => 'required|integer',
            'batas_waktu' => 'required|date',
            'status_approval' => 'nullable|string',
        ]);
        
        $lowongan = Lowongan::create($validated);
        
        return response()->json([
            'message' => 'Lowongan berhasil ditambahkan', 
            'data' => $lowongan
        ], 201);
    }

    public function show($id)
    {
        $lowongan = Lowongan::find($id);
        
        if (!$lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }
        
        return response()->json($lowongan, 200);
    }
}