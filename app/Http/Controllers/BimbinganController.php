<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Bimbingan;
use App\Models\Pendaftaran;

class BimbinganController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'id_pendaftaran' => 'required|exists:pendaftaran,id_pendaftaran',
            'nidn'           => 'required|exists:dosen,nidn'
        ]);

        $pendaftaran = Pendaftaran::find($request->id_pendaftaran);
        if ($pendaftaran->status !== 'diterima') {
            return response()->json([
                'message' => 'Gagal! Mahasiswa belum berstatus diterima magang.'
            ], 403);
        }

        $cekBimbingan = Bimbingan::where('id_pendaftaran', $request->id_pendaftaran)->first();
        if ($cekBimbingan) {
            return response()->json([
                'message' => 'Gagal! Mahasiswa ini sudah memiliki dosen pembimbing.'
            ], 400);
        }

        $bimbingan = new Bimbingan();
        $bimbingan->id_pendaftaran = $request->id_pendaftaran;
        $bimbingan->nidn           = $request->nidn;
        $bimbingan->save();

        return response()->json([
            'message' => 'Dosen pembimbing berhasil ditetapkan untuk mahasiswa ini!',
            'data'    => $bimbingan
        ], 201);
    }
}