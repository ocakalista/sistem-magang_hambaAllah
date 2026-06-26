<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Logbook;
use App\Models\Pendaftaran;

class LogbookController extends Controller
{
    // 1. Mahasiswa mengisi logbook mingguan
    public function store(Request $request)
    {
        $request->validate([
            'id_pendaftaran' => 'required|exists:pendaftarans,id',
            'minggu_ke'      => 'required|integer',
            'tanggal'        => 'required|date',
            'kegiatan'       => 'required|string'
        ]);

        // Pastikan mahasiswa status pendaftarannya sudah "diterima" sebelum bisa ngisi logbook
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
        $logbook->kegiatan       = $request->kegiatan;
        $logbook->status         = 'menunggu'; // Status default saat baru dikirim
        $logbook->save();

        return response()->json([
            'message' => 'Logbook minggu ke-' . $request->minggu_ke . ' berhasil dikirim!',
            'data'    => $logbook
        ], 201);
    }

    // 2. Mitra/Dosen memvalidasi logbook (disetujui/revisi)
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:disetujui,revisi'
        ]);

        $logbook = Logbook::find($id);

        if (!$logbook) {
            return response()->json(['message' => 'Data logbook tidak ditemukan'], 404);
        }

        $logbook->status = $request->status;
        $logbook->save();

        return response()->json([
            'message' => 'Status logbook berhasil diubah menjadi ' . $request->status,
            'data'    => $logbook
        ], 200);
    }
}