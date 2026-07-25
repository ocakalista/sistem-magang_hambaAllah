<?php

namespace App\Http\Controllers;

use App\Models\Bimbingan;
use App\Models\Pendaftaran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class BimbinganController extends Controller
{
    // 1. FITUR ASLI: Admin mem-plot/menetapkan dosen pembimbing
    public function store(Request $request)
    {
        $request->validate([
            'id_pendaftaran' => 'required|exists:pendaftaran,id_pendaftaran',
            'nidn' => 'required|exists:dosen,nidn',
        ]);

        $pendaftaran = Pendaftaran::find($request->id_pendaftaran);
        if (! in_array($pendaftaran->status, ['accepted', 'diterima'], true)) {
            return response()->json(['message' => 'Gagal! Mahasiswa belum berstatus diterima magang.'], 403);
        }

        $cekBimbingan = Bimbingan::where('id_pendaftaran', $request->id_pendaftaran)->first();
        if ($cekBimbingan) {
            return response()->json(['message' => 'Gagal! Mahasiswa ini sudah memiliki dosen pembimbing.'], 400);
        }

        $bimbingan = new Bimbingan;
        $bimbingan->id_pendaftaran = $request->id_pendaftaran;
        $bimbingan->nidn = $request->nidn;
        $bimbingan->save();

        return response()->json([
            'message' => 'Dosen pembimbing berhasil ditetapkan!',
            'data' => $bimbingan,
        ], 201);
    }

    // 2. FITUR DOSEN: Melihat daftar mahasiswa bimbingannya (dengan pencarian US-19 & status US-20)
    public function getBimbinganDosen(Request $request)
    {
        // Cari ID user dosen yang sedang login
        $dosen = DB::table('dosen')->where('id_user', Auth::id())->first();

        if (! $dosen) {
            return response()->json(['message' => 'Data profil dosen tidak ditemukan di database.'], 404);
        }

        $search = $request->query('search');

        // Tarik data mahasiswa yang dibimbing oleh dosen ini
        $query = DB::table('bimbingan')
            ->join('pendaftaran', 'bimbingan.id_pendaftaran', '=', 'pendaftaran.id_pendaftaran')
            ->join('mahasiswa', 'pendaftaran.id_mahasiswa', '=', 'mahasiswa.id_mahasiswa')
            ->join('lowongan', 'pendaftaran.id_lowongan', '=', 'lowongan.id_lowongan')
            ->join('mitra', 'lowongan.id_mitra', '=', 'mitra.id_mitra')
            ->where('bimbingan.nidn', $dosen->nidn)
            ->select(
                'bimbingan.id_bimbingan',
                'bimbingan.status_verifikasi',
                'bimbingan.catatan_verifikasi',
                'pendaftaran.id_pendaftaran',
                'pendaftaran.status as status_magang',
                'mahasiswa.nama as nama_mahasiswa',
                'mahasiswa.id_mahasiswa as nim',
                'lowongan.judul_posisi',
                'lowongan.lokasi',
                'mitra.nama_perusahaan as nama_mitra'
            );

        $bimbingan = $query->get();

        $bimbingan->transform(function ($item) {
            $logbooks = DB::table('logbook')
                ->where('id_pendaftaran', $item->id_pendaftaran)
                ->orderBy('minggu_ke', 'asc')
                ->get();

            $item->weekly_reports = $logbooks->map(function ($lb) use ($item) {
                return [
                    'id' => (string) $lb->id_logbook,
                    'week_number' => (int) $lb->minggu_ke,
                    'title' => 'Laporan Minggu ke-'.$lb->minggu_ke,
                    'submitted_by' => $item->nama_mahasiswa,
                    'submitted_at' => $lb->created_at ?? $lb->tanggal,
                    'content' => $lb->deskripsi_kegiatan,
                    'is_approved' => $lb->status_validasi === 'disetujui',
                    'lecturer_feedback' => $lb->feedback_dosen,
                ];
            })->values();

            $totalWeeks = config('internship.total_weeks');
            $completedLogbooks = $logbooks->where('status_validasi', 'disetujui')->count();
            $item->current_week = $logbooks->max('minggu_ke') ?? 1;
            $item->total_weeks = $totalWeeks;
            $item->progress = round(min(1.0, $completedLogbooks / $totalWeeks), 2);

            return $item;
        });

        return response()->json([
            'message' => 'Berhasil mengambil daftar mahasiswa bimbingan',
            'data' => $bimbingan,
        ], 200);
    }

    // 3. FITUR DOSEN: Verifikasi / Persetujuan Mahasiswa Magang (US-24)
    public function verifikasiMahasiswa(Request $request, $id_bimbingan)
    {
        $request->validate([
            'status_verifikasi' => 'required|in:disetujui,ditolak',
            'catatan' => 'nullable|string',
        ]);

        $bimbingan = Bimbingan::find($id_bimbingan);

        if (! $bimbingan) {
            return response()->json(['message' => 'Data bimbingan tidak ditemukan'], 404);
        }

        $bimbingan->status_verifikasi = $request->status_verifikasi;
        if ($request->filled('catatan')) {
            $bimbingan->catatan_verifikasi = $request->catatan;
        }
        $bimbingan->save();

        return response()->json([
            'message' => 'Mahasiswa bimbingan berhasil di-verifikasi ('.$request->status_verifikasi.')',
            'data' => $bimbingan,
        ], 200);
    }
}
