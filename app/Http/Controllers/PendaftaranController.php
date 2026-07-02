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
        'id_lowongan' => 'required|exists:lowongan,id_lowongan',
        'id_mahasiswa' => 'required|exists:mahasiswa,id_mahasiswa', 
        'berkas_cv' => 'required|file|mimes:pdf,doc,docx|max:2048'
    ]);

    $sudahDaftar = Pendaftaran::where('id_mahasiswa', $request->id_mahasiswa)
                              ->where('id_lowongan', $request->id_lowongan)
                              ->first();
    if ($sudahDaftar) {
        return response()->json(['message' => 'Gagal! Anda sudah mendaftar di lowongan ini.'], 400);
    }

    $lowongan = \App\Models\Lowongan::find($request->id_lowongan);
    if ($lowongan->kuota < 1) {
        return response()->json(['message' => 'Maaf, kuota lowongan ini sudah penuh.'], 400);
    }
    $lowongan->kuota -= 1;
    $lowongan->save();

    $pathCv = null;
    if ($request->hasFile('berkas_cv')) {
        $file = $request->file('berkas_cv');
        $namaFile = time() . '_' . preg_replace('/\s+/', '_', $file->getClientOriginalName());
        $pathCv = $file->storeAs('berkas_cv', $namaFile, 'public');
    }

    $pendaftaran = new \App\Models\Pendaftaran();
    $pendaftaran->id_mahasiswa = $request->id_mahasiswa;
    $pendaftaran->id_lowongan = $request->id_lowongan;
    $pendaftaran->berkas_cv = $pathCv; // Yang disimpan ke database hanya path-nya
    $pendaftaran->status = 'pending';
    $pendaftaran->save();

    return response()->json([
        'message' => 'Berhasil mendaftar! CV sukses diunggah dan kuota telah dipotong.',
        'data' => $pendaftaran,
        'file_url' => asset('storage/' . $pathCv) // Link URL langsung untuk melihat CV
    ], 201);
    }

    public function updateStatus(Request $request, string $id)
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

    public function getPelamar(string $id_lowongan)
    {
        $pelamar = \Illuminate\Support\Facades\DB::table('pendaftaran')
            ->join('mahasiswa', 'pendaftaran.id_mahasiswa', '=', 'mahasiswa.id_mahasiswa')
            ->select(
                'pendaftaran.id_pendaftaran',
                'pendaftaran.status',
                'pendaftaran.berkas_cv',
                'pendaftaran.created_at as tanggal_daftar',
                'mahasiswa.id_mahasiswa as nim',
                'mahasiswa.nama as nama_mahasiswa',
                'mahasiswa.jurusan'
            )
            ->where('pendaftaran.id_lowongan', $id_lowongan)
            ->get();

        if ($pelamar->isEmpty()) {
            return response()->json([
                'message' => 'Belum ada pelamar untuk lowongan ini.',
                'data' => []
            ], 200);
        }

        $pelamar->transform(function ($item) {
            $item->url_cv = asset('storage/' . $item->berkas_cv);
            return $item;
        });

        return response()->json([
            'message' => 'Berhasil mengambil daftar pelamar',
            'data' => $pelamar
        ], 200);
    }
}

