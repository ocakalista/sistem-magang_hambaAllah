<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;
use App\Models\Lowongan;
use App\Models\Pendaftaran; 

class PendaftaranController extends Controller
{
    // Menampilkan daftar pendaftaran (untuk fitur Monitoring)
    public function index()
    {
        // 1. Kita ambil NIM dari mahasiswa yang sedang login
        $nim = Auth::user()->email_or_nim;

        // 2. Kita cari lamaran yang HANYA milik NIM tersebut
        $pendaftaran = DB::table('pendaftaran')
            ->where('id_mahasiswa', $nim)
            ->get();

        // 3. Kirim datanya ke Flutter
        return response()->json([
            'message' => 'Berhasil mengambil riwayat pendaftaran Anda',
            'data' => $pendaftaran
        ], 200);
    }

    // Proses mendaftar magang (termasuk Sistem Validasi Kuota)
    public function store(Request $request)
    {
        // 1. Validasi Input
        $request->validate([
            'id_lowongan' => 'required',
            'motivasi' => 'required',
            'berkas_cv' => 'required|file|mimes:pdf,doc,docx,png,jpg,jpeg|max:20480',
            'portofolio_link' => 'nullable|string',
            'portofolio_file' => 'nullable|file|mimes:pdf,doc,docx,png,jpg,jpeg|max:20480',
        ]);

        // 2. CEK & AMBIL DATA LOWONGAN DULU 👇
        $lowongan = Lowongan::find($request->id_lowongan);
        
        if (!$lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan'], 404);
        }

        // Cek Kuota
        if ($lowongan->kuota < 1) {
            return response()->json(['message' => 'Maaf, kuota magang sudah penuh'], 400);
        }

        // US-16: Cek Batas Waktu / Kadaluarsa
        if ($lowongan->batas_waktu && $lowongan->batas_waktu < date('Y-m-d')) {
            return response()->json(['message' => 'Maaf, pendaftaran lowongan ini sudah ditutup (kadaluarsa).'], 400);
        }

        // US-14 AC2: Mencegah Pendaftaran Ganda
        $nim = Auth::user()->email_or_nim;
        $existing = Pendaftaran::where('id_mahasiswa', $nim)
            ->where('id_lowongan', $request->id_lowongan)
            ->first();

        if ($existing) {
            return response()->json(['message' => 'Anda sudah mendaftar pada lowongan ini sebelumnya.'], 400);
        }

        // 3. Simpan CV & Portofolio
        $cvPath = $request->file('berkas_cv')->store('berkas_cv', 'public');
        
        $portofolioData = null;
        if ($request->hasFile('portofolio_file')) {
            $portofolioData = $request->file('portofolio_file')->store('portofolio', 'public');
        } elseif ($request->filled('portofolio_link')) {
            $portofolioData = $request->portofolio_link;
        }

        // 4. Simpan ke Database
        $pendaftaran = Pendaftaran::create([
            'id_mahasiswa' => Auth::user()->email_or_nim, 
            'id_lowongan' => $request->id_lowongan,
            'motivasi' => $request->motivasi,
            'berkas_cv' => $cvPath,
            'portofolio' => $portofolioData,
        ]);

        // 5. POTONG KUOTA LOWONGAN 👇
        $lowongan->decrement('kuota');

        // 6. Kirim Balasan Sukses
        return response()->json([
            'message' => 'Lamaran berhasil dikirim dan kuota berkurang',
            'data' => $pendaftaran
        ], 201);
    }

    public function updateStatus(Request $request, string $id)
    {
        $request->validate([
            'status' => 'required|in:diterima,ditolak,selesai'
        ]);

        $pendaftaran = DB::table('pendaftaran')->where('id_pendaftaran', $id)->first();

        if (!$pendaftaran) {
            return response()->json(['message' => 'Data pendaftaran tidak ditemukan'], 404);
        }

        if ($request->status == 'ditolak' && $pendaftaran->status != 'ditolak') {
            $lowongan = Lowongan::find($pendaftaran->id_lowongan);
            if ($lowongan) {
                $lowongan->increment('kuota');
            }
        }

        DB::table('pendaftaran')->where('id_pendaftaran', $id)->update([
            'status' => $request->status
        ]);

        return response()->json([
            'message' => 'Status pendaftaran berhasil diubah menjadi ' . $request->status
        ], 200);
    }

    public function getPelamar(string $id_lowongan)
    {
        $pelamar = DB::table('pendaftaran')
            ->join('mahasiswa', 'pendaftaran.id_mahasiswa', '=', 'mahasiswa.id_mahasiswa')
            ->select(
                'pendaftaran.id_pendaftaran',
                'pendaftaran.status',
                'pendaftaran.berkas_cv',
                'pendaftaran.created_at as tanggal_daftar',
                'mahasiswa.id_mahasiswa as nim',
                'mahasiswa.nama as nama_mahasiswa',
                'mahasiswa.jurusan'
            )
            ->where('pendaftaran.id_lowongan', $id_lowongan)
            ->get();

        if ($pelamar->isEmpty()) {
            return response()->json([
                'message' => 'Belum ada pelamar untuk lowongan ini.',
                'data' => []
            ], 200);
        }

        $pelamar->transform(function ($item) {
            $item->url_cv = asset('storage/' . $item->berkas_cv);
            return $item;
        });

        return response()->json([
            'message' => 'Berhasil mengambil daftar pelamar',
            'data' => $pelamar
        ], 200);
    }

    // FITUR BARU: Mahasiswa Mengunggah Laporan Akhir
    public function uploadLaporanAkhir(Request $request, $id)
    {
        // 1. Satpam mengecek file yang dikirim (harus PDF, maksimal 5MB)
        $request->validate([
            'laporan_akhir' => 'required|file|mimes:pdf|max:5120',
        ]);

        $pendaftaran = Pendaftaran::find($id);

        if (!$pendaftaran) {
            return response()->json(['message' => 'Data pendaftaran tidak ditemukan'], 404);
        }

        // 2. Pastikan mahasiswa tidak salah mengirim ke lamaran orang lain
        if ($pendaftaran->id_mahasiswa !== Auth::user()->email_or_nim) {
            return response()->json(['message' => 'Akses ditolak! Ini bukan data lamaran Anda.'], 403);
        }

        // 3. Pastikan statusnya sudah Diterima Magang
        if ($pendaftaran->status !== 'diterima' && $pendaftaran->status !== 'selesai') {
            return response()->json(['message' => 'Gagal! Anda belum berstatus diterima magang.'], 403);
        }

        // 4. Simpan file fisik PDF-nya ke dalam server
        $laporanPath = $request->file('laporan_akhir')->store('laporan_akhir', 'public');

        // 5. Simpan nama filenya ke laci database yang baru kita buat
        $pendaftaran->laporan_akhir = $laporanPath;
        $pendaftaran->save();

        return response()->json([
            'message' => 'Laporan Akhir berhasil diunggah',
            'data' => $pendaftaran
        ], 200);
    }
}