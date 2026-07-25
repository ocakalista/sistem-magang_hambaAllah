<?php

namespace App\Http\Controllers;

use App\Models\Lowongan;
use App\Models\PendaftaranDraft;
use Illuminate\Http\Request;

class PendaftaranDraftController extends Controller
{
    public function index(Request $request)
    {
        $drafts = PendaftaranDraft::query()
            ->where('user_id', $request->user()->id)
            ->with('lowongan.mitra')
            ->latest('updated_at')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil draft lamaran.',
            'data' => $drafts,
        ]);
    }

    public function show(Request $request, string $idLowongan)
    {
        $draft = PendaftaranDraft::query()
            ->where('user_id', $request->user()->id)
            ->where('id_lowongan', $idLowongan)
            ->with('lowongan.mitra')
            ->first();

        if (! $draft) {
            return response()->json(['message' => 'Draft lamaran tidak ditemukan.'], 404);
        }

        return response()->json([
            'message' => 'Berhasil mengambil draft lamaran.',
            'data' => $draft,
        ]);
    }

    public function update(Request $request, string $idLowongan)
    {
        if (! Lowongan::whereKey($idLowongan)->exists()) {
            return response()->json(['message' => 'Lowongan tidak ditemukan.'], 404);
        }

        $validated = $request->validate([
            'nama_lengkap' => 'nullable|string|max:255',
            'no_telp' => 'nullable|string|max:20',
            'semester' => 'nullable|integer|min:1|max:14',
            'motivasi' => 'nullable|string|max:5000',
            'portfolio_link' => 'nullable|url|max:2048',
        ]);

        $draft = PendaftaranDraft::updateOrCreate(
            [
                'user_id' => $request->user()->id,
                'id_lowongan' => $idLowongan,
            ],
            $validated,
        );

        return response()->json([
            'message' => 'Draft lamaran berhasil disimpan.',
            'data' => $draft,
        ]);
    }

    public function destroy(Request $request, string $idLowongan)
    {
        PendaftaranDraft::query()
            ->where('user_id', $request->user()->id)
            ->where('id_lowongan', $idLowongan)
            ->delete();

        return response()->json(['message' => 'Draft lamaran berhasil dihapus.']);
    }
}
