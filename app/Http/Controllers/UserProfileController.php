<?php

namespace App\Http\Controllers;

use App\Models\Mahasiswa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class UserProfileController extends Controller
{
    public function show(Request $request)
    {
        return response()->json([
            'data' => $this->formatUser($request->user()),
        ]);
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'semester' => 'required|integer|min:1|max:14',
            'phone' => 'required|string|max:15',
        ]);

        $user = DB::transaction(function () use ($request, $validated) {
            $user = $request->user();
            $user->update([
                'name' => $validated['name'],
                'semester' => $validated['semester'],
                'phone' => $validated['phone'],
            ]);

            Mahasiswa::updateOrCreate(
                ['id_user' => (string) $user->id],
                [
                    'id_mahasiswa' => $user->email_or_nim,
                    'nama' => $validated['name'],
                    'jurusan' => $user->mahasiswa?->jurusan
                        ?? $user->konsentrasi
                        ?? 'Belum ditentukan',
                ],
            );

            return $user->fresh();
        });

        return response()->json([
            'message' => 'Profil berhasil diperbarui.',
            'data' => $this->formatUser($user),
        ]);
    }

    private function formatUser($user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email_or_nim' => $user->email_or_nim,
            'role' => $user->role,
            'semester' => $user->semester !== null ? (int) $user->semester : null,
            'phone' => $user->phone,
        ];
    }
}
