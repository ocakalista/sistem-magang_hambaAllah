<?php

namespace App\Http\Controllers;

use App\Models\Lowongan;
use App\Models\User;
use App\Notifications\ApiNotification;
use App\Support\SendsNotificationsSafely;
use Illuminate\Http\Request;

class LowonganController extends Controller
{
    use SendsNotificationsSafely;

    public function store(Request $request)
    {
        $validated = $request->validate([
            'judul_posisi' => 'required|string|max:255',
            'deskripsi' => 'required|string',
            'persyaratan' => 'required|string',
            'kategori' => 'required|string|max:100',
            'lokasi' => 'required|string|max:255',
            'tipe_kerja' => 'required|string|max:50',
            'tipe_kontrak' => 'required|string|max:50',
            'benefit' => 'nullable|string',
            'kuota' => 'required|integer|min:1',
            'batas_waktu' => 'required|date|after_or_equal:today',
        ]);

        $mitra = $request->user()->mitra;
        if (! $mitra) {
            return response()->json(['message' => 'Profil mitra tidak ditemukan.'], 422);
        }

        $lowongan = $mitra->lowongan()->create($validated + ['status_approval' => 'pending']);

        User::where('role', 'admin')->each(
            fn (User $admin) => $this->notifySafely(
                $admin,
                new ApiNotification(
                    'lowongan_baru',
                    'Lowongan baru menunggu persetujuan',
                    $mitra->nama_perusahaan.' mengajukan lowongan '.$lowongan->judul_posisi.'.',
                    ['id_lowongan' => $lowongan->id_lowongan]
                ),
                'lowongan.created',
            )
        );

        return response()->json([
            'message' => 'Lowongan berhasil dibuat dan menunggu persetujuan admin.',
            'data' => $lowongan,
        ], 201);
    }

    // =========================================================
    // Public (no auth required)
    // =========================================================

    /**
     * GET /api/lowongan  — list lowongan yang masih ada kuotanya (publik)
     */
    public function index(Request $request)
    {
        $validated = $request->validate([
            'search' => 'nullable|string|max:255',
            'kategori' => 'nullable|string|max:100',
            'lokasi' => 'nullable|string|max:255',
            'tipe_kerja' => 'nullable|string|max:50',
            'page' => 'nullable|integer|min:1',
            'per_page' => 'nullable|integer|min:1|max:50',
        ]);

        $query = Lowongan::query()
            ->with('mitra')
            ->approved()
            ->where('kuota', '>', 0)
            ->whereDate('batas_waktu', '>=', today());

        if ($search = $validated['search'] ?? null) {
            $query->where(function ($builder) use ($search) {
                $builder
                    ->where('judul_posisi', 'like', '%'.$search.'%')
                    ->orWhere('lokasi', 'like', '%'.$search.'%')
                    ->orWhereHas('mitra', fn ($mitra) => $mitra
                        ->where('nama_perusahaan', 'like', '%'.$search.'%'));
            });
        }

        foreach (['kategori', 'lokasi', 'tipe_kerja'] as $filter) {
            if ($value = $validated[$filter] ?? null) {
                $query->where($filter, $value);
            }
        }

        $query->latest('id_lowongan');
        $usesPagination = $request->hasAny(['page', 'per_page']);

        if ($usesPagination) {
            $paginator = $query
                ->paginate($validated['per_page'] ?? 15)
                ->withQueryString();

            return response()->json([
                'message' => 'Berhasil mengambil katalog lowongan',
                'data' => $paginator->getCollection()
                    ->map(fn (Lowongan $item) => self::formatLowongan($item)),
                'meta' => [
                    'current_page' => $paginator->currentPage(),
                    'last_page' => $paginator->lastPage(),
                    'per_page' => $paginator->perPage(),
                    'total' => $paginator->total(),
                ],
                'links' => [
                    'next' => $paginator->nextPageUrl(),
                    'previous' => $paginator->previousPageUrl(),
                ],
            ]);
        }

        $lowongan = $query->get()
            ->map(fn (Lowongan $item) => self::formatLowongan($item));

        return response()->json([
            'message' => $lowongan->isEmpty()
                ? 'Belum ada lowongan magang yang tersedia saat ini.'
                : 'Berhasil mengambil katalog lowongan',
            'data' => $lowongan,
        ]);
    }

    /**
     * GET /api/lowongan/{id}  — detail 1 lowongan (publik)
     */
    public function show($id)
    {
        $lowongan = Lowongan::with('mitra')->find($id);

        if (! $lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        // Pertahankan kontrak lama: detail dikembalikan langsung, bukan dibungkus "data".
        return response()->json(self::formatLowongan($lowongan));
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
                    'id_lowongan' => $item->id_lowongan,
                    'company_name' => $item->mitra->nama_perusahaan ?? null,
                    'company_category' => $item->kategori,
                    'request_description' => $item->deskripsi,
                    'status_approval' => $item->status_approval,
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

        if (! $lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        if ($lowongan->status_approval === 'approved') {
            return response()->json(['message' => 'Lowongan sudah di-approve sebelumnya.'], 400);
        }

        $lowongan->status_approval = 'approved';
        $lowongan->save();
        $this->notifySafely(
            $lowongan->mitra?->user,
            new ApiNotification(
                'status_lowongan',
                'Lowongan disetujui',
                'Lowongan '.$lowongan->judul_posisi.' telah disetujui.',
                ['id_lowongan' => $lowongan->id_lowongan, 'status' => 'approved']
            ),
            'lowongan.approved',
        );

        return response()->json([
            'message' => 'Lowongan berhasil di-approve.',
            'data' => $lowongan,
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

        if (! $lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        if ($lowongan->status_approval !== 'pending') {
            return response()->json(['message' => 'Lowongan tidak dalam status pending.'], 400);
        }

        $lowongan->status_approval = 'rejected';
        $lowongan->save();
        $this->notifySafely(
            $lowongan->mitra?->user,
            new ApiNotification(
                'status_lowongan',
                'Lowongan ditolak',
                $validated['reason'] ?: 'Lowongan '.$lowongan->judul_posisi.' ditolak.',
                ['id_lowongan' => $lowongan->id_lowongan, 'status' => 'rejected']
            ),
            'lowongan.rejected',
        );

        // Restore kuota jika sebelumnya ada pelamar yang diterima
        // (karena kuota sudah dipotong saat approve/reject lowongan tidak mengembalikan otomatis)
        // Kita hanya set status = rejected tanpa ubah kuota.
        // Kuota restore ditangani oleh mitra saat updateStatus pendaftaran ke 'ditolak'.

        return response()->json([
            'message' => 'Lowongan berhasil di-reject.',
            'data' => $lowongan,
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

        if (! $mitra) {
            return response()->json([
                'message' => 'Profil mitra tidak ditemukan untuk user ini.',
                'data' => [],
            ], 404);
        }

        $lowongan = Lowongan::where('id_mitra', $mitra->id_mitra)->get();

        return response()->json(['data' => $lowongan]);
    }

    public static function formatLowongan(Lowongan $lowongan): array
    {
        return [
            'id_lowongan' => $lowongan->id_lowongan,
            'id_mitra' => $lowongan->id_mitra,
            'nama_perusahaan' => $lowongan->mitra?->nama_perusahaan,
            'judul_posisi' => $lowongan->judul_posisi,
            'deskripsi' => $lowongan->deskripsi,
            'persyaratan' => $lowongan->persyaratan,
            'kategori' => $lowongan->kategori,
            'lokasi' => $lowongan->lokasi,
            'tipe_kerja' => $lowongan->tipe_kerja,
            'tipe_kontrak' => $lowongan->tipe_kontrak,
            'benefit' => $lowongan->benefit,
            'kuota' => (int) $lowongan->kuota,
            'batas_waktu' => $lowongan->batas_waktu?->toDateString(),
            'status_approval' => $lowongan->status_approval,
        ];
    }
}
