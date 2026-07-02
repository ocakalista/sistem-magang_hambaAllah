<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LowonganController;
use App\Http\Controllers\PendaftaranController;
use App\Http\Controllers\MitraController;
use App\Http\Controllers\LogbookController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\BimbinganController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/lowongan', [LowonganController::class, 'store']);
Route::get('/lowongan', [LowonganController::class, 'index']);
Route::get('/lowongan/{id}', [LowonganController::class, 'show']);

Route::get('/pendaftaran', [PendaftaranController::class, 'index']);
Route::post('/pendaftaran', [PendaftaranController::class, 'store']);
Route::put('/pendaftaran/{id}/status', [PendaftaranController::class, 'updateStatus']);

Route::get('/logbook', [LogbookController::class, 'index']);
Route::post('/logbook', [LogbookController::class, 'store']);
Route::put('/logbook/{id}/status', [LogbookController::class, 'updateStatus']);

Route::get('/mitra', [MitraController::class, 'index']);

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // --- GRUP KHUSUS MAHASISWA ---
    Route::middleware('role:mahasiswa')->group(function () {
        Route::get('/lowongan', [LowonganController::class, 'index']);

        Route::post('/pendaftaran', [PendaftaranController::class, 'store']); // Mendaftar
        Route::post('/logbook', [LogbookController::class, 'store']); // Isi Logbook
    });

    // --- GRUP KHUSUS MITRA ---
    Route::middleware('role:mitra')->group(function () {
        Route::get('/lowongan/{id_lowongan}/pelamar', [PendaftaranController::class, 'getPelamar']);

        Route::put('/pendaftaran/{id}/status', [PendaftaranController::class, 'updateStatus']); // Terima/Tolak
    });

    // --- GRUP KHUSUS DOSEN ---
    Route::middleware('role:dosen')->group(function () {
        Route::put('/logbook/{id}/status', [LogbookController::class, 'updateStatus']); // Validasi Logbook
    });
});

Route::middleware('role:admin')->group(function () {
    Route::post('/bimbingan', [BimbinganController::class, 'store']);
});