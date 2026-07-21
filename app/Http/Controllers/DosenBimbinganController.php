<?php

namespace App\Http\Controllers;

use App\Models\Bimbingan;
use Illuminate\Http\Request;

class DosenBimbinganController extends Controller
{
    /**
     * GET /api/dosen/bimbingan
     * List mahasiswa bimbingan milik dosen yang sedang login, lengkap
     * dengan weekly reports dari logbook.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $dosen = $user->dosen;

        if (!$dosen) {
            return response()->json([
                'message' => 'Profil dosen tidak ditemukan untuk user ini.',
                'data' => [],
            ], 404);
        }

        $nidn = $dosen->nidn;

        // Ambil semua bimbingan untuk dosen ini + relasi yang dibutuhkan
        $bimbingans = Bimbingan::with([
            'pendaftaran.mahasiswa',
            'pendaftaran.logbook',
            'pendaftaran.lowongan.mitra',
        ])->where('nidn', $nidn)->get();

        $result = $bimbingans->map(function ($bimbingan) {
            $pendaftaran = $bimbingan->pendaftaran;
            if (!$pendaftaran) {
                return null;
            }

            $mahasiswa = $pendaftaran->mahasiswa;
            $logbooks  = $pendaftaran->logbook->sortBy('minggu_ke');

            // Default 12 minggu. Bisa di-override jika lowongan punya batas_waktu
            $totalWeeks = 12;
            if ($pendaftaran->lowongan && $pendaftaran->lowongan->batas_waktu) {
                $weeksFromDates = (int) round(
                    now()->diffInWeeks($pendaftaran->lowongan->batas_waktu, false)
                );
                if ($weeksFromDates > 0) {
                    $totalWeeks = $weeksFromDates;
                }
            }

            $currentWeek = $logbooks->count() > 0
                ? (int) $logbooks->max('minggu_ke')
                : 0;

            $progress = $totalWeeks > 0
                ? round(min(100.0, ($currentWeek / $totalWeeks) * 100), 1)
                : 0.0;

            $weeklyReports = $logbooks->map(function ($lb) {
                return [
                    'id'               => $lb->id_logbook,
                    'minggu_ke'        => $lb->minggu_ke,
                    'tanggal'          => $lb->tanggal,
                    'deskripsi'        => $lb->deskripsi_kegiatan,
                    'status_validasi'  => $lb->status_validasi,
                ];
            })->values();

            return [
                'id'            => $mahasiswa ? $mahasiswa->id_mahasiswa : null,
                'name'          => $mahasiswa ? $mahasiswa->nama : '(Tanpa Nama)',
                'position'      => $pendaftaran->lowongan->judul_posisi ?? null,
                'company'       => $pendaftaran->lowongan->mitra->nama_perusahaan ?? null,
                'currentWeek'   => $currentWeek,
                'totalWeeks'    => $totalWeeks,
                'progress'      => $progress,
                'weeklyReports' => $weeklyReports,
            ];
        })->filter()->values();

        return response()->json(['data' => $result]);
    }
}
