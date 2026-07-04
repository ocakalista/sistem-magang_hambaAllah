<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Lowongan;
use Illuminate\Support\Facades\DB;

class LowonganController extends Controller
{
    public function index()
    {
        $lowongan = DB::table('lowongan')->where('kuota', '>', 0)->get();

        if ($lowongan->isEmpty()) {
            return response()->json([
                'message' => 'Belum ada lowongan magang yang tersedia saat ini.',
                'data' => []
            ], 200);
        }

        return response()->json([
            'message' => 'Berhasil mengambil katalog lowongan',
            'data' => $lowongan
        ], 200);
    }

    public function store(Request $request)
    {
        // Satpam mengecek semua data yang dikirim Flutter
        $validated = $request->validate([
            'id_mitra' => 'required',
            'judul_posisi' => 'required|string',
            'deskripsi' => 'nullable|string',
            'persyaratan' => 'nullable|string',
            'kategori' => 'nullable|string',
            'lokasi' => 'nullable|string',
            'tipe_kerja' => 'nullable|string',
            'tipe_kontrak' => 'nullable|string',
            'benefit' => 'nullable|string',
            'kuota' => 'required|integer',
            'batas_waktu' => 'required|date',
            'status_approval' => 'nullable|string',
        ]);
        
        // Simpan semua datanya ke laci database
        $lowongan = Lowongan::create($validated);
        
        // Kasih tahu Flutter kalau sudah sukses
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