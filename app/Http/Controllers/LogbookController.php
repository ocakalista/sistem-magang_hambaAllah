<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Logbook;
use App\Models\Pendaftaran;

class LogbookController extends Controller
{
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

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status_validasi' => 'required|in:disetujui,revisi'
        ]);

        $logbook = Logbook::find($id);

        if (!$logbook) {
            return response()->json(['message' => 'Data logbook tidak ditemukan'], 404);
        }

        $logbook->status_validasi = $request->status_validasi;
        $logbook->save();

        return response()->json([
            'message' => 'Status logbook berhasil diubah menjadi ' . $request->status_validasi,
            'data'    => $logbook
        ], 200);
    }
}