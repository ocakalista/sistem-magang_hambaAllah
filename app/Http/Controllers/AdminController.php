<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Lowongan;

class AdminController extends Controller
{
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
    public function validasiLowongan(Request $request, $id)
    {
        $request->validate([
            'status_approval' => 'required|in:pending,disetujui,ditolak'
        ]);

        $lowongan = Lowongan::find($id);

        if (!$lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        $lowongan->status_approval = $request->status_approval;
        $lowongan->save();

        return response()->json([
            'message' => 'Status lowongan berhasil diubah menjadi ' . $request->status_approval,
            'data' => $lowongan
        ], 200);
    }

    // 3. FITUR MANAJEMEN PENGGUNA (CRUD ADMIN)
    
    // A. Melihat semua daftar pengguna
    public function getUsers()
    {
        $users = \App\Models\User::all();
        return response()->json([
            'message' => 'Berhasil mengambil data semua pengguna', 
            'data' => $users
        ], 200);
    }

    // B. Admin menambah pengguna baru (Misal: Daftarkan Dosen / Mitra)
    public function storeUser(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email_or_nim' => 'required|string|unique:users,email_or_nim',
            'password' => 'required|string|min:6',
            'role' => 'required|in:admin,mahasiswa,mitra,dosen'
        ]);

        $user = \App\Models\User::create([
            'name' => $request->name,
            'email_or_nim' => $request->email_or_nim,
            'password' => \Illuminate\Support\Facades\Hash::make($request->password),
            'role' => $request->role
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
            'data' => $user
        ], 201);
    }

    // C. Admin menghapus pengguna
    public function destroyUser($id)
    {
        $user = \App\Models\User::find($id);
        
        if (!$user) {
            return response()->json(['message' => 'Pengguna tidak ditemukan'], 404);
        }
        
        $user->delete();
        
        return response()->json(['message' => 'Pengguna berhasil dihapus dari sistem'], 200);
    }
}