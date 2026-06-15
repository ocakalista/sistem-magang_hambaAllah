<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LowonganController;
use App\Http\Controllers\PendaftaranController;
use App\Http\Controllers\MitraController;
use App\Http\Controllers\LogbookController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::post('/lowongan', [LowonganController::class, 'store']);
Route::get('/pendaftaran', [PendaftaranController::class, 'index']);
Route::get('/logbook', [LogbookController::class, 'index']);
Route::get('/mitra', [MitraController::class, 'index']);