<?php

namespace App\Http\Controllers;

use App\Models\Lowongan;
use App\Models\Pendaftaran;
use App\Models\User;
use App\Notifications\ApiNotification;
use App\Support\SendsNotificationsSafely;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    use SendsNotificationsSafely;

    // =========================================================================
    // Legacy method for Flutter — validasiLowongan (PUT /admin/lowongan/{id}/validasi)
    // =========================================================================
    public function validasiLowongan(Request $request, $id)
    {
        $validated = $request->validate([
            'status_approval' => 'required|in:pending,approved,rejected',
        ]);

        $lowongan = Lowongan::find($id);
        if (! $lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        if ($lowongan->status_approval === $validated['status_approval']) {
            return response()->json([
                'message' => 'Status lowongan tidak berubah.',
                'data' => $lowongan,
            ]);
        }

        if ($lowongan->status_approval !== 'pending') {
            return response()->json([
                'message' => 'Lowongan tidak dalam status pending.',
            ], 409);
        }

        $lowongan->status_approval = $validated['status_approval'];
        $lowongan->save();

        if (in_array($validated['status_approval'], ['approved', 'rejected'], true)) {
            $this->notifySafely(
                $lowongan->mitra?->user,
                new ApiNotification(
                    'status_lowongan',
                    $validated['status_approval'] === 'approved' ? 'Lowongan disetujui' : 'Lowongan ditolak',
                    'Status lowongan '.$lowongan->judul_posisi.' menjadi '.$validated['status_approval'].'.',
                    [
                        'id_lowongan' => $lowongan->id_lowongan,
                        'status' => $validated['status_approval'],
                    ],
                ),
                'lowongan.status_updated',
            );
        }

        return response()->json([
            'message' => 'Status lowongan berhasil diubah menjadi '.$validated['status_approval'],
            'data' => $lowongan,
        ], 200);
    }

    // =========================================================================
    // User management (legacy — HEAD style)
    // =========================================================================
    public function getUsers()
    {
        $users = User::select('id', 'name', 'email_or_nim', 'phone', 'role')->get();

        return response()->json([
            'message' => 'Berhasil mengambil data semua pengguna',
            'data' => $users,
        ], 200);
    }

    public function storeUser(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email_or_nim' => 'required|string|unique:users,email_or_nim',
            'password' => 'required|string|min:6',
            'role' => 'required|in:admin,mahasiswa,mitra,dosen',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email_or_nim' => $validated['email_or_nim'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
        ]);

        if ($request->role === 'mahasiswa') {
            DB::table('mahasiswa')->insert([
                'id_mahasiswa' => $user->email_or_nim,
                'id_user' => (string) $user->id,
                'nama' => $user->name,
                'jurusan' => $request->jurusan ?? 'Informatika',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } elseif ($request->role === 'mitra') {
            DB::table('mitra')->insert([
                'id_user' => $user->id,
                'nama_perusahaan' => $user->name,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } elseif ($request->role === 'dosen') {
            DB::table('dosen')->insert([
                'nidn' => $user->email_or_nim,
                'id_user' => $user->id,
                'nama' => $user->name,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        return response()->json([
            'message' => 'Pengguna baru berhasil ditambahkan',
            'data' => $user,
        ], 201);
    }

    public function destroyUser($id)
    {
        $user = User::find($id);
        if (! $user) {
            return response()->json(['message' => 'Pengguna tidak ditemukan'], 404);
        }

        $user->delete();

        return response()->json(['message' => 'Pengguna berhasil dihapus dari sistem'], 200);
    }

    // =========================================================================
    // New methods for Flutter
    // =========================================================================
    /**
     * GET /api/admin/profile
     * Return current admin user data for Flutter.
     */
    public function profile(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'data' => [
                'name' => $user->name,
                'email' => $user->email_or_nim,
                'role' => $user->role,
                'username' => $user->username,      // alias ke email_or_nim
                'phone' => $user->phone,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ],
        ]);
    }

    /**
     * GET /api/admin/users
     * List semua user agar Flutter bisa filter berdasarkan role di client.
     */
    public function usersList()
    {
        $users = User::query()
            ->select('id', 'name', 'email_or_nim', 'phone', 'role', 'created_at')
            ->with(['mahasiswa', 'dosen', 'mitra'])
            ->latest('created_at')
            ->get()
            ->map(fn (User $user) => [
                'id' => $user->id,
                'name' => $this->displayName($user),
                'email' => $user->email_or_nim,
                'email_or_nim' => $user->email_or_nim,
                'username' => null,
                'phone' => $user->phone,
                'role' => $user->role,
                'created_at' => $user->created_at?->toISOString(),
            ]);

        return response()->json([
            'data' => $users,
        ]);
    }

    public function enrollments(Request $request)
    {
        $validated = $request->validate([
            'status' => 'nullable|in:pending,under_review,interview,accepted,rejected,withdrawn,completed,diterima,ditolak,selesai',
            'search' => 'nullable|string|max:255',
            'page' => 'nullable|integer|min:1',
            'per_page' => 'nullable|integer|min:1|max:100',
        ]);

        $query = Pendaftaran::query()
            ->with(['mahasiswa.user', 'lowongan.mitra', 'bimbingan.dosen'])
            ->withCount('logbook')
            ->withCount([
                'logbook as approved_logbook_count' => fn ($query) => $query
                    ->where('status_validasi', 'disetujui'),
            ])
            ->latest('created_at');

        if ($status = $validated['status'] ?? null) {
            $query->where('status', $status);
        }

        if ($search = $validated['search'] ?? null) {
            $query->where(function ($builder) use ($search) {
                $builder
                    ->where('id_mahasiswa', 'like', '%'.$search.'%')
                    ->orWhereHas('mahasiswa', fn ($mahasiswa) => $mahasiswa
                        ->where('nama', 'like', '%'.$search.'%'))
                    ->orWhereHas('lowongan', fn ($lowongan) => $lowongan
                        ->where('judul_posisi', 'like', '%'.$search.'%')
                        ->orWhereHas('mitra', fn ($mitra) => $mitra
                            ->where('nama_perusahaan', 'like', '%'.$search.'%')));
            });
        }

        $paginator = $query->paginate($validated['per_page'] ?? 20)->withQueryString();

        return response()->json([
            'data' => $paginator->getCollection()
                ->map(fn (Pendaftaran $item) => $this->formatEnrollment($item)),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'last_page' => $paginator->lastPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
            ],
        ]);
    }

    public function showUser(string $id)
    {
        $user = User::query()
            ->with([
                'mahasiswa.pendaftaran.lowongan.mitra',
                'mahasiswa.pendaftaran.bimbingan.dosen.user',
                'mahasiswa.pendaftaran.logbook',
                'dosen.bimbingan.pendaftaran.mahasiswa',
                'dosen.bimbingan.pendaftaran.lowongan.mitra',
                'dosen.bimbingan.pendaftaran.logbook',
                'mitra.lowongan.pendaftaran.mahasiswa',
            ])
            ->find($id);

        if (! $user) {
            return response()->json(['message' => 'Pengguna tidak ditemukan.'], 404);
        }

        $data = [
            'id' => $user->id,
            'name' => $this->displayName($user),
            'email' => $user->email_or_nim,
            'email_or_nim' => $user->email_or_nim,
            'phone' => $user->phone,
            'role' => $user->role,
            'created_at' => $user->created_at?->toISOString(),
            'profile' => (object) [],
            'applications' => [],
            'supervisor' => null,
            'supervised_students' => [],
            'vacancies' => [],
            'applicants' => [],
        ];

        if ($user->role === 'mahasiswa' && $user->mahasiswa) {
            $student = $user->mahasiswa;
            $data['profile'] = [
                'nim' => $student->id_mahasiswa,
                'nama' => $student->nama,
                'jurusan' => $student->jurusan,
                'semester' => $user->semester !== null ? (int) $user->semester : null,
            ];
            $data['applications'] = $student->pendaftaran
                ->map(fn (Pendaftaran $item) => $this->formatEnrollment($item))
                ->values();

            $supervisedApplication = $student->pendaftaran
                ->filter(fn (Pendaftaran $item) => $item->bimbingan?->dosen !== null)
                ->sortByDesc(fn (Pendaftaran $item) => [
                    $item->status === 'accepted' ? 1 : 0,
                    $item->created_at?->timestamp ?? 0,
                ])
                ->first();
            $supervisor = $supervisedApplication?->bimbingan?->dosen;
            if ($supervisor) {
                $data['supervisor'] = [
                    'id_dosen' => $supervisor->nidn,
                    'nama_dosen' => $supervisor->user?->name ?? $supervisor->nama,
                    'nidn' => $supervisor->nidn,
                    'email' => $supervisor->user?->email_or_nim,
                    'jumlah_logbook' => $supervisedApplication->logbook->count(),
                ];
            }
        } elseif ($user->role === 'dosen' && $user->dosen) {
            $lecturer = $user->dosen;
            $data['profile'] = [
                'nidn' => $lecturer->nidn,
                'nama' => $lecturer->nama,
                'program_studi' => $user->konsentrasi,
            ];
            $data['supervised_students'] = $lecturer->bimbingan
                ->map(function ($guidance) {
                    $application = $guidance->pendaftaran;
                    $logbookCount = $application?->logbook->count() ?? 0;
                    $approvedLogbooks = $application?->logbook
                        ->where('status_validasi', 'disetujui')
                        ->count() ?? 0;

                    return [
                        'id_bimbingan' => $guidance->id_bimbingan,
                        'id_pendaftaran' => $application?->id_pendaftaran,
                        'id_mahasiswa' => $application?->id_mahasiswa,
                        'nim' => $application?->id_mahasiswa,
                        'nama_mahasiswa' => $application?->mahasiswa?->nama,
                        'judul_posisi' => $application?->lowongan?->judul_posisi,
                        'nama_perusahaan' => $application?->lowongan?->mitra?->nama_perusahaan,
                        'status' => $application?->status,
                        'jumlah_logbook' => $logbookCount,
                        'progress' => $this->progress($approvedLogbooks),
                    ];
                })->values();
        } elseif ($user->role === 'mitra' && $user->mitra) {
            $partner = $user->mitra;
            $data['profile'] = [
                'id_mitra' => $partner->id_mitra,
                'nama_perusahaan' => $partner->nama_perusahaan,
            ];
            $data['vacancies'] = $partner->lowongan->map(fn (Lowongan $item) => [
                'id_lowongan' => $item->id_lowongan,
                'judul_posisi' => $item->judul_posisi,
                'status_approval' => $item->status_approval,
                'kuota' => (int) $item->kuota,
                'jumlah_pendaftar' => $item->pendaftaran->count(),
            ])->values();
            $data['applicants'] = $partner->lowongan
                ->flatMap(fn (Lowongan $vacancy) => $vacancy->pendaftaran->map(
                    fn (Pendaftaran $item) => [
                        'id_pendaftaran' => $item->id_pendaftaran,
                        'id_lowongan' => $item->id_lowongan,
                        'judul_posisi' => $vacancy->judul_posisi,
                        'id_mahasiswa' => $item->id_mahasiswa,
                        'nim' => $item->id_mahasiswa,
                        'nama_mahasiswa' => $item->mahasiswa?->nama,
                        'status' => $item->status,
                        'tanggal_daftar' => $item->created_at?->toISOString(),
                    ]
                ))->values();
        }

        return response()->json(['data' => $data]);
    }

    /**
     * GET /api/admin/dashboard
     * Stats: totalUsers, growth%, activeInternships, growth%.
     */
    public function dashboard()
    {
        $now = now();
        $sevenAgo = now()->subDays(7);
        $prior7 = now()->subDays(14);
        $thirtyAgo = now()->subDays(30);
        $prior30 = now()->subDays(60);

        // ---- Total users & growth (7 hari) ----
        $totalUsers = User::count();
        $newLast7 = User::where('created_at', '>=', $sevenAgo)->count();
        $newPrior7 = User::whereBetween('created_at', [$prior7, $sevenAgo])->count();
        $usersGrowth = $this->calcGrowthPercent($newLast7, $newPrior7);

        // ---- Active internships & growth (30 hari) ----
        $activeInternships = Pendaftaran::where('status', 'accepted')
            ->whereNull('completed_at')
            ->whereHas('lowongan', function ($q) use ($now) {
                $q->where('batas_waktu', '>=', $now)
                    ->where('status_approval', 'approved');
            })->count();

        $acceptedLast30 = Pendaftaran::where('status', 'accepted')
            ->where('created_at', '>=', $thirtyAgo)->count();
        $acceptedPrior30 = Pendaftaran::where('status', 'accepted')
            ->whereBetween('created_at', [$prior30, $thirtyAgo])->count();
        $internGrowth = $this->calcGrowthPercent($acceptedLast30, $acceptedPrior30);

        return response()->json([
            'data' => [
                'totalUsers' => $totalUsers,
                'totalUsersGrowthPercent' => $usersGrowth,
                'activeInternships' => $activeInternships,
                'activeInternshipsGrowthPercent' => $internGrowth,
            ],
        ]);
    }

    /**
     * Helper: hitung persentase pertumbuhan.
     * Prior == 0 & current > 0 => +100%
     * Both 0 => 0%
     */
    private function calcGrowthPercent(float $current, float $prior): float
    {
        if ($prior == 0) {
            return $current > 0 ? 100.0 : 0.0;
        }

        return round((($current - $prior) / $prior) * 100, 1);
    }

    private function formatEnrollment(Pendaftaran $item): array
    {
        $logbookCount = isset($item->logbook_count)
            ? (int) $item->logbook_count
            : $item->logbook->count();
        $approvedLogbookCount = isset($item->approved_logbook_count)
            ? (int) $item->approved_logbook_count
            : $item->logbook->where('status_validasi', 'disetujui')->count();

        return [
            'id_pendaftaran' => $item->id_pendaftaran,
            'id_mahasiswa' => $item->id_mahasiswa,
            'nama_mahasiswa' => $item->mahasiswa?->nama,
            'email' => $item->mahasiswa?->user?->email_or_nim,
            'avatar_url' => null,
            'id_lowongan' => $item->id_lowongan,
            'judul_posisi' => $item->lowongan?->judul_posisi,
            'nama_perusahaan' => $item->lowongan?->mitra?->nama_perusahaan,
            'status' => $item->status,
            'tanggal_daftar' => $item->created_at?->toISOString(),
            'dosen_pembimbing' => $item->bimbingan?->dosen?->nama,
            'jumlah_logbook' => $logbookCount,
            'progress' => $this->progress($approvedLogbookCount),
        ];
    }

    private function progress(int $logbookCount): int
    {
        $totalWeeks = max(1, config('internship.total_weeks'));

        return min(100, (int) round(($logbookCount / $totalWeeks) * 100));
    }

    private function displayName(User $user): string
    {
        return match ($user->role) {
            'mahasiswa' => $user->mahasiswa?->nama ?? $user->name,
            'dosen' => $user->dosen?->nama ?? $user->name,
            'mitra' => $user->mitra?->nama_perusahaan ?? $user->name,
            default => $user->name,
        };
    }
}
