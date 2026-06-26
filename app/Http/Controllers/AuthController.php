<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // 1. Fungsi Pendaftaran (Register)
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
            'password' => Hash::make($request->password), 
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
        $request->validate([
            'email_or_nim' => 'required',
            'password' => 'required',
        ]);
        
    // Cari user berdasarkan Email atau NIM
    $user = User::where('email_or_nim', $request->email_or_nim)->first();

    // Cek apakah user ada dan passwordnya benar
    if (!$user || !Hash::check($request->password, $user->password)) {
        return response()->json(['message' => 'Email/NIM atau Password salah!'], 401);
    }

    // Buat token
    $token = $user->createToken('auth_token')->plainTextToken;

    // KEMBALIKAN TOKEN DAN ROLE KE FLUTTER
    return response()->json([
        'message' => 'Login success',
        'token' => $token,
        'role' => $user->role
    ], 200);
}
}