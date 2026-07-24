<?php

use App\Http\Controllers\AdminController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\BimbinganController;
use App\Http\Controllers\DosenBimbinganController;
use App\Http\Controllers\LogbookController;
use App\Http\Controllers\LowonganController;
use App\Http\Controllers\MitraController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\PendaftaranController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
|  PUBLIC ROUTES (tidak butuh token)
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/lowongan', [LowonganController::class, 'index']);
Route::get('/lowongan/{id}', [LowonganController::class, 'show']);
Route::get('/mitra', [MitraController::class, 'index']);

/*
|--------------------------------------------------------------------------
|  AUTHENTICATED ROUTES (wajib auth:sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::patch('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);

    // -------- ADMIN --------
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        // Approval lowongan (Flutter endpoints)
        Route::get('lowongan', [LowonganController::class, 'adminListPending']);
        Route::post('lowongan/{id}/approve', [LowonganController::class, 'approve']);
        Route::post('lowongan/{id}/reject', [LowonganController::class, 'reject']);

        // Legacy validasi endpoint
        Route::put('lowongan/{id}/validasi', [AdminController::class, 'validasiLowongan']);

        // Profile & user management
        Route::get('profile', [AdminController::class, 'profile']);
        Route::get('users', [AdminController::class, 'usersList']);
        Route::post('users', [AdminController::class, 'storeUser']);
        Route::delete('users/{id}', [AdminController::class, 'destroyUser']);

        // Dashboard stats
        Route::get('dashboard', [AdminController::class, 'dashboard']);
    });

    // Admin tetapkan dosen pembimbing
    Route::post('/bimbingan', [BimbinganController::class, 'store']);

    // -------- MITRA --------
    Route::middleware('role:mitra')->group(function () {
        // Buat lowongan baru
        Route::post('/lowongan', [LowonganController::class, 'store']);

        // Lowongan milik sendiri
        Route::get('/mitra/lowongan', [LowonganController::class, 'myLowongan']);

        // Pelamar untuk satu lowongan
        Route::get('/lowongan/{id_lowongan}/pelamar', [PendaftaranController::class, 'getPelamar']);

        // Terima/tolak pelamar
        Route::put('/pendaftaran/{id}/status', [PendaftaranController::class, 'updateStatus']);

        // Mitra pantau logbook
        Route::get('/mitra/logbook/{id_pendaftaran}', [LogbookController::class, 'getLogbookByPendaftaran']);
    });

    // -------- DOSEN --------
    Route::middleware('role:dosen')->group(function () {
        // List mahasiswa bimbingan + weekly reports (Flutter)
        Route::get('/dosen/bimbingan', [DosenBimbinganController::class, 'index']);

        // Legacy endpoint (HEAD style)
        Route::get('/dosen/bimbingan-list', [BimbinganController::class, 'getBimbinganDosen']);
        Route::get('/dosen/logbook/{id_pendaftaran}', [LogbookController::class, 'getLogbookByPendaftaran']);

        // Validasi logbook
        Route::put('/logbook/{id}/status', [LogbookController::class, 'updateStatus']);
    });

    // -------- MAHASISWA --------
    Route::middleware('role:mahasiswa')->group(function () {
        // Riwayat pendaftaran
        Route::get('/pendaftaran/riwayat', [PendaftaranController::class, 'index']);

        // Apply internship — multipart form submission
        Route::post('/pendaftaran', [PendaftaranController::class, 'store']);

        // Upload laporan akhir
        Route::post('/pendaftaran/{id}/laporan', [PendaftaranController::class, 'uploadLaporanAkhir']);

        // Logbook mingguan
        Route::get('/logbook', [LogbookController::class, 'index']);
        Route::post('/logbook', [LogbookController::class, 'store']);
    });
});
