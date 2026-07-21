<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Lowongan;
use Illuminate\Support\Facades\DB;

class LowonganController extends Controller
{
    public function index()
    {
        $today = date('Y-m-d');
        $lowongan = DB::table('lowongan')
            ->where('kuota', '>', 0)
            ->whereIn('status_approval', ['disetujui', 'Approved'])
            ->where('batas_waktu', '>=', $today)
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil katalog lowongan',
            'data' => $lowongan
        ], 200);
    }

    public function store(Request $request)
    {
        // Satpam mengecek semua data yang dikirim Flutter
        $validated = $request->validate([
            'id_mitra' => 'nullable',
            'judul_posisi' => 'required|string',
            'deskripsi' => 'nullable|string',
            'persyaratan' => 'nullable|string',
            'kategori' => 'nullable|string',
            'lokasi' => 'nullable|string',
            'tipe_kerja' => 'nullable|string',
            'tipe_kontrak' => 'nullable|string',
            'benefit' => 'nullable|string',
            'kuota' => 'required|integer|min:1',
            'batas_waktu' => 'required|date',
            'status_approval' => 'nullable|string',
        ]);

        // Otomatis cari id_mitra dari user mitra yang sedang login
        $mitra = DB::table('mitra')->where('id_user', Auth::id())->first();
        $validated['id_mitra'] = $mitra ? $mitra->id_mitra : ($request->id_mitra ?? 1);

        // Default status approval untuk lowongan baru dari mitra adalah 'pending'
        if (empty($validated['status_approval'])) {
            $validated['status_approval'] = 'pending';
        }
        
        // Simpan semua datanya ke laci database
        $lowongan = Lowongan::create($validated);
        
        // Kasih tahu Flutter kalau sudah sukses
        return response()->json([
            'message' => 'Lowongan berhasil diajukan (status: pending)', 
            'data' => $lowongan
        ], 201);
    }

    public function mitraLowongan(Request $request)
    {
        $mitra = DB::table('mitra')->where('id_user', Auth::id())->first();
        $idMitra = $mitra ? $mitra->id_mitra : 1;

        $lowongan = DB::table('lowongan')
            ->where('id_mitra', $idMitra)
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil lowongan milik mitra',
            'data' => $lowongan
        ], 200);
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