<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pendaftaran;
use App\Models\Lowongan;

class PendaftaranController extends Controller
{
    // Menampilkan daftar pendaftaran (untuk fitur Monitoring)
    public function index()
    {
        return response()->json(Pendaftaran::all(), 200);
    }

    // Proses mendaftar magang (termasuk Sistem Validasi Kuota)
    public function store(Request $request)
    {
        $request->validate([
            'id_mahasiswa' => 'required',
            'id_lowongan' => 'required',
            'berkas_cv' => 'nullable|string', 
        ]);

        $lowongan = Lowongan::find($request->id_lowongan);

        if (!$lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        if ($lowongan->kuota <= 0) {
            return response()->json(['message' => 'Mohon maaf, kuota magang ini sudah penuh.'], 400);
        }

        $sudahDaftar = Pendaftaran::where('id_mahasiswa', $request->id_mahasiswa)
        ->where('id_lowongan', $request->id_lowongan)
        ->exists();
        
        if ($sudahDaftar) {
            return response()->json(['message' => 'Anda sudah mendaftar pada lowongan ini sebelumnya.'], 400);
        }

        $pendaftaran = Pendaftaran::create([
            'id_mahasiswa' => $request->id_mahasiswa,
            'id_lowongan' => $request->id_lowongan,
            'berkas_cv' => $request->berkas_cv,
            'status' => 'pending' // Status awal selalu pending
        ]);

        $lowongan->decrement('kuota');

        return response()->json([
            'message' => 'Pendaftaran berhasil dikirim!',
            'data' => $pendaftaran
        ], 201);
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:diterima,ditolak,selesai'
        ]);

        $pendaftaran = Pendaftaran::find($id);

        if (!$pendaftaran) {
            return response()->json(['message' => 'Data pendaftaran tidak ditemukan'], 404);
        }

        if ($request->status == 'ditolak' && $pendaftaran->status != 'ditolak') {
            $lowongan = Lowongan::find($pendaftaran->id_lowongan);
            if ($lowongan) {
                $lowongan->increment('kuota');
            }
        }

        $pendaftaran->status = $request->status;
        $pendaftaran->save();

        return response()->json([
            'message' => 'Status pendaftaran berhasil diubah menjadi ' . $request->status,
            'data' => $pendaftaran
        ], 200);
    }
}