<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Models\Logbook;
use App\Models\Pendaftaran;

class LogbookController extends Controller
{
    // 1. FITUR BARU: Menampilkan riwayat logbook (Khusus Mahasiswa yang sedang login)
    public function index()
    {
        // Ambil NIM mahasiswa dari token loginnya
        $nim = Auth::user()->email_or_nim;

        // Cari catatan logbook yang terhubung dengan pendaftarannya
        $logbook = DB::table('logbook')
            ->join('pendaftaran', 'logbook.id_pendaftaran', '=', 'pendaftaran.id_pendaftaran')
            ->where('pendaftaran.id_mahasiswa', $nim)
            ->select('logbook.*')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil riwayat logbook',
            'data' => $logbook
        ], 200);
    }

    // 2. FITUR ASLI ABANG: Menyimpan logbook baru
    public function store(Request $request)
    {
        $request->validate([
            'id_pendaftaran' => 'required|exists:pendaftaran,id_pendaftaran',
            'minggu_ke'      => 'required|integer',
            'tanggal'        => 'required|date',
            'deskripsi_kegiatan' => 'required|string' 
        ]);

        $pendaftaran = Pendaftaran::find($request->id_pendaftaran);
        if ($pendaftaran->status != 'diterima') {
            return response()->json([
                'message' => 'Gagal! Mahasiswa ini belum berstatus diterima.'
            ], 403);
        }

        $logbook = new Logbook();
        $logbook->id_pendaftaran = $request->id_pendaftaran;
        $logbook->minggu_ke      = $request->minggu_ke;
        $logbook->tanggal        = $request->tanggal;
        $logbook->deskripsi_kegiatan = $request->deskripsi_kegiatan; 
        $logbook->status_validasi = 'pending'; 
        $logbook->save();

        return response()->json([
            'message' => 'Logbook minggu ke-' . $request->minggu_ke . ' berhasil dikirim!',
            'data'    => $logbook
        ], 201);
    }

    // 3. FITUR DOSEN: Mengubah status logbook & memberikan feedback (US-21)
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status_validasi' => 'required|in:disetujui,revisi',
            'feedback_dosen'  => 'nullable|string'
        ]);

        $logbook = Logbook::find($id);

        if (!$logbook) {
            return response()->json(['message' => 'Data logbook tidak ditemukan'], 404);
        }

        $logbook->status_validasi = $request->status_validasi;
        if ($request->has('feedback_dosen')) {
            $logbook->feedback_dosen = $request->feedback_dosen;
        }
        $logbook->save();

        return response()->json([
            'message' => 'Status logbook berhasil diubah menjadi ' . $request->status_validasi,
            'data'    => $logbook
        ], 200);
    }

    // 4. FITUR BARU: Dosen & Mitra melihat isi logbook mahasiswa tertentu
    public function getLogbookByPendaftaran($id_pendaftaran)
    {
        // Kita cari semua logbook milik pendaftaran ini, diurutkan dari minggu pertama
        $logbook = DB::table('logbook')
            ->where('id_pendaftaran', $id_pendaftaran)
            ->orderBy('minggu_ke', 'asc') 
            ->get();

        // Kalau mahasiswanya malas dan belum isi sama sekali
        if ($logbook->isEmpty()) {
            return response()->json([
                'message' => 'Mahasiswa ini belum mengisi logbook sama sekali.',
                'data' => []
            ], 200);
        }

        // Kalau ada datanya, kirim ke HP Dosen/Mitra
        return response()->json([
            'message' => 'Berhasil mengambil data logbook',
            'data' => $logbook
        ], 200);
    }
}