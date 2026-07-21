<?php

namespace App\Http\Controllers;

use App\Models\Lowongan;
use App\Models\Pendaftaran;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
<<<<<<< HEAD
    // 1. Dashboard Rekapitulasi untuk Admin
    public function dashboard()
    {
        // Admin menghitung semua data di database
        $total_mahasiswa = DB::table('users')->where('role', 'mahasiswa')->count();
        $total_mitra = DB::table('users')->where('role', 'mitra')->count();
        $total_dosen = DB::table('users')->where('role', 'dosen')->count();
        $total_users = DB::table('users')->count();
        $total_lowongan = DB::table('lowongan')->count();
        $total_pendaftaran = DB::table('pendaftaran')->count();
        $pendaftaran_diterima = DB::table('pendaftaran')->where('status', 'diterima')->count();

        // Daftar pendaftaran siswa terbaru
        $enrollments = DB::table('pendaftaran')
            ->join('mahasiswa', 'pendaftaran.id_mahasiswa', '=', 'mahasiswa.id_mahasiswa')
            ->join('lowongan', 'pendaftaran.id_lowongan', '=', 'lowongan.id_lowongan')
            ->join('mitra', 'lowongan.id_mitra', '=', 'mitra.id_mitra')
            ->select(
                'mahasiswa.nama as user_name',
                'mahasiswa.id_mahasiswa as nim',
                'lowongan.judul_posisi as program_name',
                'mitra.nama_perusahaan as company_name',
                'pendaftaran.status'
            )
            ->latest('pendaftaran.created_at')
            ->take(6)
            ->get();

        // Lowongan pending persetujuan
        $pending_lowongan = DB::table('lowongan')
            ->join('mitra', 'lowongan.id_mitra', '=', 'mitra.id_mitra')
            ->where('lowongan.status_approval', 'pending')
            ->select(
                'lowongan.id_lowongan as id',
                'mitra.nama_perusahaan as company_name',
                'lowongan.kategori as company_category',
                'lowongan.judul_posisi',
                'lowongan.lokasi',
                'lowongan.kuota',
                'lowongan.deskripsi as request_description',
                'lowongan.status_approval as status'
            )
            ->get();

        // Distribusi bidang magang
        $distribution = DB::table('lowongan')
            ->select('kategori as label', DB::raw('count(*) as value'))
            ->groupBy('kategori')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil data dashboard admin',
            'data' => [
                'total_users' => $total_users,
                'total_mahasiswa' => $total_mahasiswa,
                'total_mitra' => $total_mitra,
                'total_dosen' => $total_dosen,
                'total_lowongan' => $total_lowongan,
                'total_pendaftaran' => $total_pendaftaran,
                'active_internships' => $pendaftaran_diterima,
                'enrollments' => $enrollments,
                'pending_lowongan' => $pending_lowongan,
                'distribution' => $distribution,
            ]
        ], 200);
    }

    // 2. FITUR BARU: Admin memvalidasi (menyetujui/menolak) lowongan dari Mitra
=======
    // =========================================================================
    // Legacy method for Flutter — validasiLowongan (PUT /admin/lowongan/{id}/validasi)
    // =========================================================================
>>>>>>> f6b3645b01dc7980f13ef018c69ed208e5e79b85
    public function validasiLowongan(Request $request, $id)
    {
        $validated = $request->validate([
            'status_approval' => 'required|in:pending,approved,rejected',
        ]);

        $lowongan = Lowongan::find($id);
        if (! $lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        $lowongan->status_approval = $validated['status_approval'];
        $lowongan->save();

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
        } else if ($request->role === 'mitra') {
            DB::table('mitra')->insert([
                'id_user' => $user->id,
                'nama_perusahaan' => $user->name,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        } else if ($request->role === 'dosen') {
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
        $users = User::select('id', 'name', 'email_or_nim', 'phone', 'role')
            ->get();

        return response()->json([
            'data' => $users,
        ]);
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
        $activeInternships = Pendaftaran::whereIn('status', ['diterima', 'selesai'])
            ->whereHas('lowongan', function ($q) use ($now) {
                $q->where('batas_waktu', '>=', $now)
                    ->where('status_approval', 'approved');
            })->count();

        $acceptedLast30 = Pendaftaran::where('status', 'diterima')
            ->where('created_at', '>=', $thirtyAgo)->count();
        $acceptedPrior30 = Pendaftaran::where('status', 'diterima')
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
}
