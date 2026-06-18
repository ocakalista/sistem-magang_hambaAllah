<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // 1. Fungsi Pendaftaran Mahasiswa (Register)
    public function register(Request $request)
    {
        // Validasi data yang dikirim dari Frontend
        $request->validate([
            'name' => 'required|string|max:255',
            'email_or_nim' => 'required|string|unique:users,email_or_nim',
            'password' => 'required|string|min:6',
        ]);

        // Simpan ke database
        $user = User::create([
            'name' => $request->name,
            'email_or_nim' => $request->email_or_nim,
            'password' => Hash::make($request->password), // Password wajib dienkripsi
            // Catatan: role 'mahasiswa' otomatis terisi karena setelan default di Migration
        ]);

        // Terbitkan Tiket/Token
        $token = $user->createToken('nexus_token')->plainTextToken;

        return response()->json([
            'message' => 'Registrasi berhasil',
            'data' => $user,
            'token' => $token
        ], 201);
    }

    // 2. Fungsi Masuk (Login)
    public function login(Request $request)
    {
        // Validasi inputan
        $request->validate([
            'email_or_nim' => 'required|string',
            'password' => 'required|string',
        ]);

        // Cari user di database berdasarkan Email atau NIM
        $user = User::where('email_or_nim', $request->email_or_nim)->first();

        // Cek apakah user ketemu DAN password-nya cocok
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email/NIM atau Password salah!'
            ], 401);
        }

        // Pengecekan ekstra jika Frontend mengirimkan centang "Login as Admin"
        if ($request->has('is_admin') && $request->is_admin == true) {
            if ($user->role !== 'admin') {
                return response()->json([
                    'message' => 'Akses ditolak. Anda bukan Admin!'
                ], 403);
            }
        }

        // Terbitkan Tiket/Token
        $token = $user->createToken('nexus_token')->plainTextToken;

        return response()->json([
            'message' => 'Login berhasil',
            'role' => $user->role,
            'data' => $user,
            'token' => $token
        ], 200);
    }
}