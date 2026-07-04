<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use App\Models\Bimbingan;
use App\Models\Pendaftaran;

class BimbinganController extends Controller
{
    // 1. FITUR ASLI: Admin mem-plot/menetapkan dosen pembimbing
    public function store(Request $request)
    {
        $request->validate([
            'id_pendaftaran' => 'required|exists:pendaftaran,id_pendaftaran',
            'nidn'           => 'required|exists:dosen,nidn'
        ]);

        $pendaftaran = Pendaftaran::find($request->id_pendaftaran);
        if ($pendaftaran->status !== 'diterima') {
            return response()->json(['message' => 'Gagal! Mahasiswa belum berstatus diterima magang.'], 403);
        }

        $cekBimbingan = Bimbingan::where('id_pendaftaran', $request->id_pendaftaran)->first();
        if ($cekBimbingan) {
            return response()->json(['message' => 'Gagal! Mahasiswa ini sudah memiliki dosen pembimbing.'], 400);
        }

        $bimbingan = new Bimbingan();
        $bimbingan->id_pendaftaran = $request->id_pendaftaran;
        $bimbingan->nidn           = $request->nidn;
        $bimbingan->save();

        return response()->json([
            'message' => 'Dosen pembimbing berhasil ditetapkan!',
            'data'    => $bimbingan
        ], 201);
    }

    // 2. FITUR BARU: Dosen melihat daftar mahasiswa bimbingannya
    public function getBimbinganDosen()
    {
        // Cari ID user dosen yang sedang login
        $dosen = DB::table('dosen')->where('id_user', Auth::id())->first();
        
        if (!$dosen) {
            return response()->json(['message' => 'Data profil dosen tidak ditemukan di database.'], 404);
        }

        // Tarik data mahasiswa yang dibimbing oleh dosen ini
        $bimbingan = DB::table('bimbingan')
            ->join('pendaftaran', 'bimbingan.id_pendaftaran', '=', 'pendaftaran.id_pendaftaran')
            ->join('mahasiswa', 'pendaftaran.id_mahasiswa', '=', 'mahasiswa.id_mahasiswa')
            ->join('lowongan', 'pendaftaran.id_lowongan', '=', 'lowongan.id_lowongan')
            ->join('mitra', 'lowongan.id_mitra', '=', 'mitra.id_mitra')
            ->where('bimbingan.nidn', $dosen->nidn)
            ->select(
                'bimbingan.id_bimbingan',
                'pendaftaran.id_pendaftaran',
                'mahasiswa.nama as nama_mahasiswa',
                'mahasiswa.id_mahasiswa as nim',
                'lowongan.judul_posisi',
                'mitra.nama_perusahaan as nama_mitra'
            )
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil daftar mahasiswa bimbingan',
            'data' => $bimbingan
        ], 200);
    }
}