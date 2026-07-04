<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Lowongan;

class AdminController extends Controller
{
    // 1. FITUR BARU: Dashboard Rekapitulasi untuk Admin
    public function dashboard()
    {
        // Admin menghitung semua data di database
        $total_mahasiswa = DB::table('users')->where('role', 'mahasiswa')->count();
        $total_mitra = DB::table('users')->where('role', 'mitra')->count();
        $total_lowongan = DB::table('lowongan')->count();
        $total_pendaftaran = DB::table('pendaftaran')->count();
        $pendaftaran_diterima = DB::table('pendaftaran')->where('status', 'diterima')->count();

        return response()->json([
            'message' => 'Berhasil mengambil data dashboard admin',
            'data' => [
                'total_mahasiswa' => $total_mahasiswa,
                'total_mitra' => $total_mitra,
                'total_lowongan' => $total_lowongan,
                'total_pendaftaran' => $total_pendaftaran,
                'pendaftaran_diterima' => $pendaftaran_diterima,
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