<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LowonganController;
use App\Http\Controllers\PendaftaranController;
use App\Http\Controllers\MitraController;
use App\Http\Controllers\LogbookController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\BimbinganController;
use App\Http\Controllers\AdminController;

// ==========================================
// 1. PINTU DEPAN (Bisa dibuka siapa saja)
// ==========================================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/lowongan', [LowonganController::class, 'index']);
Route::get('/lowongan/{id}', [LowonganController::class, 'show']);
Route::get('/mitra', [MitraController::class, 'index']);


// ==========================================
// 2. DALAM RUMAH (Wajib bawa tiket / login)
// ==========================================
Route::middleware('auth:sanctum')->group(function () {
    
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) { return $request->user(); });
    
    // --- KHUSUS KAMAR MAHASISWA ---
    Route::middleware('role:mahasiswa')->group(function () {
        Route::get('/pendaftaran/riwayat', [PendaftaranController::class, 'index']); 
        Route::post('/pendaftaran', [PendaftaranController::class, 'store']); 
        
        Route::post('/pendaftaran/{id}/laporan', [PendaftaranController::class, 'uploadLaporanAkhir']);
        
        Route::get('/logbook', [LogbookController::class, 'index']); 
        Route::post('/logbook', [LogbookController::class, 'store']); 
    });

    // --- KHUSUS KAMAR MITRA ---
    Route::middleware('role:mitra')->group(function () {
        Route::post('/lowongan', [LowonganController::class, 'store']); 
        Route::get('/lowongan/{id_lowongan}/pelamar', [PendaftaranController::class, 'getPelamar']); 
        Route::put('/pendaftaran/{id}/status', [PendaftaranController::class, 'updateStatus']); 
        
        // JALAN BARU: Mitra memantau logbook anak magang
        Route::get('/mitra/logbook/{id_pendaftaran}', [LogbookController::class, 'getLogbookByPendaftaran']); 
    });

    // --- KHUSUS KAMAR DOSEN ---
    Route::middleware('role:dosen')->group(function () {
        // JALAN BARU: Dosen melihat siapa saja bimbingannya & cek logbook
        Route::get('/dosen/bimbingan', [BimbinganController::class, 'getBimbinganDosen']); 
        Route::get('/dosen/logbook/{id_pendaftaran}', [LogbookController::class, 'getLogbookByPendaftaran']); 
        
        Route::put('/logbook/{id}/status', [LogbookController::class, 'updateStatus']); 
    });

    // --- KHUSUS RUANG ADMIN --- 
    Route::middleware('role:admin')->group(function () {
        Route::post('/bimbingan', [BimbinganController::class, 'store']); 
        
        Route::get('/admin/dashboard', [AdminController::class, 'dashboard']);
        Route::put('/admin/lowongan/{id}/validasi', [AdminController::class, 'validasiLowongan']);
        
        // JALAN BARU: MANAJEMEN PENGGUNA (BOS TERAKHIR)
        Route::get('/admin/users', [AdminController::class, 'getUsers']);
        Route::post('/admin/users', [AdminController::class, 'storeUser']);
        Route::delete('/admin/users/{id}', [AdminController::class, 'destroyUser']);
    });
});