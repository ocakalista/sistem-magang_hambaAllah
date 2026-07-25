<?php

namespace App\Http\Controllers;

use App\Models\Lowongan;
use App\Models\SavedLowongan;
use Illuminate\Http\Request;

class SavedLowonganController extends Controller
{
    public function index(Request $request)
    {
        $items = SavedLowongan::query()
            ->where('user_id', $request->user()->id)
            ->with('lowongan.mitra')
            ->latest()
            ->get()
            ->pluck('lowongan')
            ->filter()
            ->values()
            ->map(fn (Lowongan $lowongan) => LowonganController::formatLowongan($lowongan));

        return response()->json([
            'message' => 'Berhasil mengambil lowongan tersimpan.',
            'data' => $items,
        ]);
    }

    public function store(Request $request, string $idLowongan)
    {
        $lowongan = Lowongan::find($idLowongan);
        if (! $lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan.'], 404);
        }

        $saved = SavedLowongan::firstOrCreate([
            'user_id' => $request->user()->id,
            'id_lowongan' => $lowongan->id_lowongan,
        ]);

        return response()->json([
            'message' => $saved->wasRecentlyCreated
                ? 'Lowongan berhasil disimpan.'
                : 'Lowongan sudah tersimpan.',
            'data' => LowonganController::formatLowongan($lowongan->load('mitra')),
        ], $saved->wasRecentlyCreated ? 201 : 200);
    }

    public function destroy(Request $request, string $idLowongan)
    {
        SavedLowongan::query()
            ->where('user_id', $request->user()->id)
            ->where('id_lowongan', $idLowongan)
            ->delete();

        return response()->json(['message' => 'Lowongan tersimpan berhasil dihapus.']);
    }
}
