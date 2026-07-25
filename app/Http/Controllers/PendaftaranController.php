<?php

namespace App\Http\Controllers;

use App\Models\Lowongan;
use App\Models\Mahasiswa;
use App\Models\Pendaftaran;
use App\Models\PendaftaranDraft;
use App\Models\User;
use App\Notifications\ApiNotification;
use App\Support\SendsNotificationsSafely;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use RuntimeException;
use Throwable;

class PendaftaranController extends Controller
{
    use SendsNotificationsSafely;

    /**
     * GET /api/pendaftaran  — list semua pendaftaran untuk user yang login
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $nim = $user->email_or_nim;

        $pendaftaran = Pendaftaran::where('id_mahasiswa', $nim)->get();

        return response()->json([
            'message' => 'Berhasil mengambil riwayat pendaftaran Anda',
            'data' => $pendaftaran,
        ], 200);
    }

    /**
     * POST /api/pendaftaran  — Multipart form submission dari Flutter.
     * Otomatis membuat record mahasiswa jika belum ada, sinkronkan profile
     * user (phone, semester, name), upload CV & portfolio, decrement kuota.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id_lowongan' => 'required|exists:lowongan,id_lowongan',
            'nama_lengkap' => 'required|string|max:255',
            'no_telp' => 'required|string|max:20',
            'semester' => 'required|integer|min:1|max:14',
            'motivasi' => 'required|string',
            'berkas_cv' => 'required|file|mimes:pdf,doc,docx|max:5120',
            'berkas_portofolio' => 'nullable|file|mimes:pdf,doc,docx|max:5120',
            'portofolio_link' => 'nullable|url',
        ]);

        $user = $request->user();
        $nim = $user->email_or_nim;
        $storedFiles = [];

        try {
            $result = DB::transaction(function () use ($request, $validated, $user, $nim, &$storedFiles) {
                $lowongan = Lowongan::query()
                    ->whereKey($validated['id_lowongan'])
                    ->lockForUpdate()
                    ->first();

                if (! $lowongan) {
                    return ['error' => 'Lowongan tidak ditemukan.', 'status' => 404];
                }

                if ($lowongan->kuota < 1) {
                    return ['error' => 'Maaf, kuota lowongan ini sudah penuh.', 'status' => 409];
                }

                if (
                    $lowongan->status_approval !== 'approved'
                    || $lowongan->batas_waktu?->lt(today())
                ) {
                    return ['error' => 'Lowongan tidak lagi tersedia.', 'status' => 409];
                }

                $existing = Pendaftaran::query()
                    ->where('id_mahasiswa', $nim)
                    ->where('id_lowongan', $lowongan->id_lowongan)
                    ->exists();

                if ($existing) {
                    return ['error' => 'Gagal! Anda sudah mendaftar di lowongan ini.', 'status' => 409];
                }

                $user->update([
                    'name' => $validated['nama_lengkap'],
                    'phone' => $validated['no_telp'],
                    'semester' => (string) $validated['semester'],
                ]);

                Mahasiswa::updateOrCreate(
                    ['id_mahasiswa' => $nim],
                    [
                        'id_user' => $user->id,
                        'nama' => $validated['nama_lengkap'],
                        'jurusan' => $user->konsentrasi ?: 'Belum ditentukan',
                    ],
                );

                $cv = $request->file('berkas_cv');
                $cvPath = $cv->storeAs(
                    'berkas_cv',
                    uniqid('cv_', true).'_'.preg_replace('/\s+/', '_', $cv->getClientOriginalName()),
                    'public',
                );
                if (! $cvPath) {
                    throw new RuntimeException('CV gagal disimpan.');
                }
                $storedFiles[] = $cvPath;

                $portofolioPath = null;
                if ($request->hasFile('berkas_portofolio')) {
                    $portfolio = $request->file('berkas_portofolio');
                    $portofolioPath = $portfolio->storeAs(
                        'berkas_portofolio',
                        uniqid('portfolio_', true).'_'.preg_replace('/\s+/', '_', $portfolio->getClientOriginalName()),
                        'public',
                    );
                    if (! $portofolioPath) {
                        throw new RuntimeException('Portofolio gagal disimpan.');
                    }
                    $storedFiles[] = $portofolioPath;
                }

                $pendaftaran = Pendaftaran::create([
                    'id_mahasiswa' => $nim,
                    'id_lowongan' => $lowongan->id_lowongan,
                    'berkas_cv' => $cvPath,
                    'portofolio' => $portofolioPath,
                    'portfolio_link' => $validated['portofolio_link'] ?? null,
                    'motivasi' => $validated['motivasi'],
                    'status' => 'pending',
                ]);

                $lowongan->decrement('kuota');

                PendaftaranDraft::query()
                    ->where('user_id', $user->id)
                    ->where('id_lowongan', $lowongan->id_lowongan)
                    ->delete();

                return compact('pendaftaran', 'lowongan');
            }, 3);
        } catch (Throwable $exception) {
            foreach ($storedFiles as $path) {
                Storage::disk('public')->delete($path);
            }

            Log::error('Internship application failed.', [
                'user_id' => $user->id,
                'id_lowongan' => $validated['id_lowongan'],
                'exception' => $exception::class,
                'message' => $exception->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Lamaran gagal diproses. Silakan coba kembali.',
            ], 500);
        }

        if (isset($result['error'])) {
            return response()->json([
                'success' => false,
                'message' => $result['error'],
            ], $result['status']);
        }

        $pendaftaran = $result['pendaftaran'];
        $lowongan = $result['lowongan'];

        $this->notifySafely(
            $lowongan->mitra?->user,
            new ApiNotification(
                'pelamar_baru',
                'Pelamar baru',
                $validated['nama_lengkap'].' melamar posisi '.$lowongan->judul_posisi.'.',
                ['id_lowongan' => $lowongan->id_lowongan, 'id_pendaftaran' => $pendaftaran->id_pendaftaran]
            ),
            'pendaftaran.created',
        );

        return response()->json([
            'success' => true,
            'message' => 'Lamaran terkirim!',
            'data' => $pendaftaran,
        ], 201);
    }

    /**
     * PUT /api/pendaftaran/{id}/status  — update status (mitra/admin)
     */
    public function updateStatus(Request $request, string $id)
    {
        $request->validate([
            'status' => 'required|in:diterima,ditolak,selesai',
        ]);

        $pendaftaran = Pendaftaran::find($id);

        if (! $pendaftaran) {
            return response()->json(['message' => 'Data pendaftaran tidak ditemukan'], 404);
        }

        // Restore kuota jika status baru = ditolak (dan sebelumnya bukan ditolak)
        if ($request->status == 'ditolak' && $pendaftaran->status != 'ditolak') {
            $lowongan = Lowongan::find($pendaftaran->id_lowongan);
            if ($lowongan) {
                $lowongan->increment('kuota');
            }
        }

        $pendaftaran->status = $request->status;
        $pendaftaran->save();
        $this->notifySafely(
            $pendaftaran->mahasiswa?->user,
            new ApiNotification(
                'status_pendaftaran',
                'Status lamaran diperbarui',
                'Status lamaran Anda menjadi '.$request->status.'.',
                ['id_pendaftaran' => $pendaftaran->id_pendaftaran, 'status' => $request->status]
            ),
            'pendaftaran.status_updated',
        );

        return response()->json([
            'message' => 'Status pendaftaran berhasil diubah menjadi '.$request->status,
            'data' => $pendaftaran,
        ], 200);
    }

    /**
     * GET /api/lowongan/{id_lowongan}/pelamar  — list pelamar untuk lowongan tertentu (mitra)
     */
    public function getPelamar(string $id_lowongan)
    {
        $pelamar = DB::table('pendaftaran')
            ->join('mahasiswa', 'pendaftaran.id_mahasiswa', '=', 'mahasiswa.id_mahasiswa')
            ->select(
                'pendaftaran.id_pendaftaran',
                'pendaftaran.status',
                'pendaftaran.berkas_cv',
                'pendaftaran.motivasi',
                'pendaftaran.portofolio',
                'pendaftaran.portfolio_link',
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
                'data' => [],
            ], 200);
        }

        $pelamar->transform(function ($item) {
            $item->url_cv = $item->berkas_cv ? asset('storage/'.$item->berkas_cv) : null;
            $item->portfolio = [
                'file_url' => $item->portofolio ? asset('storage/'.$item->portofolio) : null,
                'link' => $item->portfolio_link,
            ];
            unset($item->berkas_cv, $item->portofolio, $item->portfolio_link);

            return $item;
        });

        return response()->json([
            'message' => 'Berhasil mengambil daftar pelamar',
            'data' => $pelamar,
        ], 200);
    }

    /**
     * PATCH /api/pendaftaran/{id}/laporan-akhir  — Mahasiswa upload laporan akhir
     */
    public function uploadLaporanAkhir(Request $request, $id)
    {
        $request->validate([
            'laporan_akhir' => 'required|file|mimes:pdf|max:5120',
        ]);

        $pendaftaran = Pendaftaran::find($id);

        if (! $pendaftaran) {
            return response()->json(['message' => 'Data pendaftaran tidak ditemukan'], 404);
        }

        if ($pendaftaran->id_mahasiswa !== $request->user()->email_or_nim) {
            return response()->json(['message' => 'Akses ditolak!'], 403);
        }

        if ($pendaftaran->status !== 'diterima' && $pendaftaran->status !== 'selesai') {
            return response()->json(['message' => 'Gagal! Anda belum berstatus diterima magang.'], 403);
        }

        $file = $request->file('laporan_akhir');
        $laporanPath = $file->storeAs('laporan_akhir', time().'_'.$file->getClientOriginalName(), 'public');

        $pendaftaran->laporan_akhir = $laporanPath;
        $pendaftaran->save();

        return response()->json([
            'message' => 'Laporan Akhir berhasil diunggah',
            'data' => $pendaftaran,
        ], 200);
    }
}
