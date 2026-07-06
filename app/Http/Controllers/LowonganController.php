<?php

namespace App\Http\Controllers;

use App\Models\Lowongan;
use Illuminate\Http\Request;

class LowonganController extends Controller
{
    // =========================================================
    // Public (no auth required)
    // =========================================================

    /**
     * GET /api/lowongan  — list lowongan yang masih ada kuotanya (publik)
     */
    public function index()
    {
        $lowongan = Lowongan::approved()->where('kuota', '>', 0)->get();

        if ($lowongan->isEmpty()) {
            return response()->json([
                'message' => 'Belum ada lowongan magang yang tersedia saat ini.',
                'data'    => [],
            ], 200);
        }

        return response()->json([
            'message' => 'Berhasil mengambil katalog lowongan',
            'data'    => $lowongan,
        ], 200);
    }

    /**
     * GET /api/lowongan/{id}  — detail 1 lowongan (publik)
     */
    public function show($id)
    {
        $lowongan = Lowongan::find($id);

        if (!$lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        return response()->json($lowongan, 200);
    }

    // =========================================================
    // Admin routes
    // =========================================================

    /**
     * GET /api/admin/lowongan  — list lowongan pending untuk approval
     */
    public function adminListPending()
    {
        $list = Lowongan::with('mitra')
            ->pending()
            ->get()
            ->map(function ($item) {
                return [
                    'id_lowongan'          => $item->id_lowongan,
                    'company_name'         => $item->mitra->nama_perusahaan ?? null,
                    'company_category'     => $item->kategori,
                    'request_description'  => $item->deskripsi,
                    'status_approval'      => $item->status_approval,
                ];
            });

        return response()->json(['data' => $list]);
    }

    /**
     * POST /api/admin/lowongan/{id}/approve  — approve lowongan
     */
    public function approve($id)
    {
        $lowongan = Lowongan::find($id);

        if (!$lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        if ($lowongan->status_approval === 'approved') {
            return response()->json(['message' => 'Lowongan sudah di-approve sebelumnya.'], 400);
        }

        // Jika sebelumnya rejected, kembalikan kuotanya ke semula (restore)
        $wasRejected = $lowongan->status_approval === 'rejected';

        $lowongan->status_approval = 'approved';
        $lowongan->save();

        return response()->json([
            'message' => 'Lowongan berhasil di-approve.',
            'data'    => $lowongan,
        ], 200);
    }

    /**
     * POST /api/admin/lowongan/{id}/reject  — reject lowongan dengan alasan
     */
    public function reject(Request $request, $id)
    {
        $validated = $request->validate([
            'reason' => 'nullable|string|max:500',
        ]);

        $lowongan = Lowongan::find($id);

        if (!$lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        if ($lowongan->status_approval !== 'pending') {
            return response()->json(['message' => 'Lowongan tidak dalam status pending.'], 400);
        }

        $lowongan->status_approval = 'rejected';
        $lowongan->save();

        // Restore kuota jika sebelumnya ada pelamar yang diterima
        // (karena kuota sudah dipotong saat approve/reject lowongan tidak mengembalikan otomatis)
        // Kita hanya set status = rejected tanpa ubah kuota.
        // Kuota restore ditangani oleh mitra saat updateStatus pendaftaran ke 'ditolak'.

        return response()->json([
            'message' => 'Lowongan berhasil di-reject.',
            'data'    => $lowongan,
        ], 200);
    }

    // =========================================================
    // Mitra route
    // =========================================================

    /**
     * GET /api/mitra/lowongan  — lowongan milik mitra yang login
     */
    public function myLowongan(Request $request)
    {
        $user = $request->user();
        $mitra = $user->mitra;

        if (!$mitra) {
            return response()->json([
                'message' => 'Profil mitra tidak ditemukan untuk user ini.',
                'data'    => [],
            ], 404);
        }

        $lowongan = Lowongan::where('id_mitra', $mitra->id_mitra)->get();

        return response()->json(['data' => $lowongan]);
    }
}
