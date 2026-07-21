<?php

namespace App\Http\Controllers;

use App\Models\Logbook;
use App\Models\Pendaftaran;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class LogbookController extends Controller
{
    // 1. FITUR BARU: Menampilkan riwayat logbook (Khusus Mahasiswa yang sedang login)
    public function index()
    {
        // Ambil NIM mahasiswa dari token loginnya
        $nim = Auth::user()->email_or_nim;

        // Cari catatan logbook yang terhubung dengan pendaftarannya
        $logbook = DB::table('logbook')
            ->join('pendaftaran', 'logbook.id_pendaftaran', '=', 'pendaftaran.id_pendaftaran')
            ->where('pendaftaran.id_mahasiswa', $nim)
            ->select('logbook.*')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil riwayat logbook',
            'data' => $logbook->map(fn ($item) => $this->formatLogbook($item)),
        ], 200);
    }

    // 2. FITUR ASLI ABANG: Menyimpan logbook baru
    public function store(Request $request)
    {
        $request->validate([
            'id_pendaftaran' => 'required|exists:pendaftaran,id_pendaftaran',
            'minggu_ke' => 'required|integer',
            'tanggal' => 'required|date',
            'deskripsi_kegiatan' => 'nullable|required_without:berkas_lampiran|string',
            'berkas_lampiran' => 'nullable|required_without:deskripsi_kegiatan|file|mimes:pdf,doc,docx,jpg,jpeg,png|max:5120',
        ]);

        $pendaftaran = Pendaftaran::find($request->id_pendaftaran);
        if ($pendaftaran->status != 'diterima') {
            return response()->json([
                'message' => 'Gagal! Mahasiswa ini belum berstatus diterima.',
            ], 403);
        }

        $logbook = new Logbook;
        $logbook->id_pendaftaran = $request->id_pendaftaran;
        $logbook->minggu_ke = $request->minggu_ke;
        $logbook->tanggal = $request->tanggal;
        $logbook->deskripsi_kegiatan = $request->deskripsi_kegiatan;
        if ($request->hasFile('berkas_lampiran')) {
            $file = $request->file('berkas_lampiran');
            $name = time().'_'.preg_replace('/\s+/', '_', $file->getClientOriginalName());
            $logbook->berkas_lampiran = $file->storeAs('logbook', $name, 'public');
        }
        $logbook->status_validasi = 'pending';
        $logbook->save();

        return response()->json([
            'message' => 'Logbook minggu ke-'.$request->minggu_ke.' berhasil dikirim!',
            'data' => $this->formatLogbook($logbook),
        ], 201);
    }

    // 3. FITUR DOSEN: Mengubah status logbook & memberikan feedback (US-21)
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status_validasi' => 'required|in:disetujui,revisi',
<<<<<<< HEAD
            'feedback_dosen'  => 'nullable|string'
=======
>>>>>>> f6b3645b01dc7980f13ef018c69ed208e5e79b85
        ]);

        $logbook = Logbook::find($id);

        if (! $logbook) {
            return response()->json(['message' => 'Data logbook tidak ditemukan'], 404);
        }

        $logbook->status_validasi = $request->status_validasi;
        if ($request->has('feedback_dosen')) {
            $logbook->feedback_dosen = $request->feedback_dosen;
        }
        $logbook->save();

        return response()->json([
            'message' => 'Status logbook berhasil diubah menjadi '.$request->status_validasi,
            'data' => $this->formatLogbook($logbook),
        ], 200);
    }

    // 4. FITUR BARU: Dosen & Mitra melihat isi logbook mahasiswa tertentu
    public function getLogbookByPendaftaran($id_pendaftaran)
    {
        // Kita cari semua logbook milik pendaftaran ini, diurutkan dari minggu pertama
        $logbook = DB::table('logbook')
            ->where('id_pendaftaran', $id_pendaftaran)
            ->orderBy('minggu_ke', 'asc')
            ->get();

        // Kalau mahasiswanya malas dan belum isi sama sekali
        if ($logbook->isEmpty()) {
            return response()->json([
                'message' => 'Mahasiswa ini belum mengisi logbook sama sekali.',
                'data' => [],
            ], 200);
        }

        // Kalau ada datanya, kirim ke HP Dosen/Mitra
        return response()->json([
            'message' => 'Berhasil mengambil data logbook',
            'data' => $logbook->map(fn ($item) => $this->formatLogbook($item)),
        ], 200);
    }

    private function formatLogbook(object $logbook): array
    {
        return [
            'id_logbook' => $logbook->id_logbook,
            'id_pendaftaran' => $logbook->id_pendaftaran,
            'minggu_ke' => (int) $logbook->minggu_ke,
            'tanggal' => $logbook->tanggal,
            'deskripsi_kegiatan' => $logbook->deskripsi_kegiatan,
            'berkas_lampiran_url' => $logbook->berkas_lampiran
                ? asset('storage/'.$logbook->berkas_lampiran)
                : null,
            'tipe_konten' => $logbook->deskripsi_kegiatan && $logbook->berkas_lampiran
                ? 'teks_dan_file'
                : ($logbook->berkas_lampiran ? 'file' : 'teks'),
            'status_validasi' => $logbook->status_validasi,
            'created_at' => $logbook->created_at,
            'updated_at' => $logbook->updated_at,
        ];
    }
}
