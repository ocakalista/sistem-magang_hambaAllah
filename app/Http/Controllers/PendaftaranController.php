<?php

namespace App\Http\Controllers;

use App\Http\Resources\PendaftaranResource;
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
use Illuminate\Support\Str;
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
        $pendaftaran = Pendaftaran::query()
            ->where('id_mahasiswa', $request->user()->email_or_nim)
            ->with('lowongan.mitra')
            ->latest('created_at')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil riwayat pendaftaran Anda',
            'data' => PendaftaranResource::collection($pendaftaran),
        ], 200);
    }

    public function active(Request $request)
    {
        $pendaftaran = Pendaftaran::query()
            ->where('id_mahasiswa', $request->user()->email_or_nim)
            ->where('status', 'accepted')
            ->whereNull('completed_at')
            ->with(['lowongan.mitra', 'logbook'])
            ->latest('accepted_at')
            ->first();

        return response()->json([
            'data' => $pendaftaran ? new PendaftaranResource($pendaftaran) : null,
        ]);
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

                $hasActiveInternship = Pendaftaran::query()
                    ->where('id_mahasiswa', $nim)
                    ->where('status', 'accepted')
                    ->whereNull('completed_at')
                    ->lockForUpdate()
                    ->first();

                if ($hasActiveInternship) {
                    return [
                        'error' => 'Anda masih memiliki program magang aktif.',
                        'status' => 422,
                        'code' => 'ACTIVE_INTERNSHIP_EXISTS',
                    ];
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
                'code' => $result['code'] ?? null,
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
                [
                    'id_pendaftaran' => $pendaftaran->id_pendaftaran,
                    'id_lowongan' => $lowongan->id_lowongan,
                    'category' => 'approval',
                    'requires_action' => true,
                    'priority' => 'high',
                ]
            ),
            'pendaftaran.created',
        );

        return response()->json([
            'success' => true,
            'message' => 'Lamaran terkirim!',
            'data' => new PendaftaranResource(
                $pendaftaran->load('lowongan.mitra')
            ),
        ], 201);
    }

    /**
     * PUT /api/pendaftaran/{id}/status  — update status (mitra/admin)
     */
    public function updateStatus(Request $request, string $id)
    {
        $validated = $request->validate([
            'status' => 'required|in:pending,under_review,interview,accepted,rejected,withdrawn,diterima,ditolak',
            'rejection_reason' => 'nullable|string|max:2000',
        ]);

        $result = DB::transaction(function () use ($request, $validated, $id) {
            $pendaftaran = Pendaftaran::query()
                ->with(['mahasiswa.user', 'lowongan.mitra'])
                ->lockForUpdate()
                ->find($id);

            if (! $pendaftaran) {
                return ['error' => 'Data pendaftaran tidak ditemukan', 'status' => 404];
            }

            $mitra = $request->user()->mitra;
            if (
                ! $mitra
                || ! $pendaftaran->lowongan
                || $pendaftaran->lowongan->id_mitra !== $mitra->id_mitra
            ) {
                return [
                    'error' => 'Anda tidak memiliki akses ke pendaftaran ini.',
                    'status' => 403,
                ];
            }

            $oldStatus = $pendaftaran->status;
            $newStatus = match ($validated['status']) {
                'diterima' => 'accepted',
                'ditolak' => 'rejected',
                default => $validated['status'],
            };
            $changed = $oldStatus !== $newStatus;

            if ($changed) {
                if ($newStatus === 'accepted') {
                    $hasActiveInternship = Pendaftaran::query()
                        ->where('id_mahasiswa', $pendaftaran->id_mahasiswa)
                        ->whereKeyNot($pendaftaran->id_pendaftaran)
                        ->where('status', 'accepted')
                        ->whereNull('completed_at')
                        ->lockForUpdate()
                        ->first();

                    if ($hasActiveInternship) {
                        return [
                            'error' => 'Mahasiswa sudah memiliki program magang aktif.',
                            'status' => 409,
                            'code' => 'ACTIVE_INTERNSHIP_EXISTS',
                        ];
                    }

                    if ($oldStatus === 'rejected') {
                        $lowongan = Lowongan::query()
                            ->whereKey($pendaftaran->id_lowongan)
                            ->lockForUpdate()
                            ->first();
                        if (! $lowongan || $lowongan->kuota < 1) {
                            return ['error' => 'Kuota lowongan sudah penuh.', 'status' => 409];
                        }
                        $lowongan->decrement('kuota');
                    }

                    $otherApplications = Pendaftaran::query()
                        ->where('id_mahasiswa', $pendaftaran->id_mahasiswa)
                        ->whereKeyNot($pendaftaran->id_pendaftaran)
                        ->whereIn('status', ['pending', 'under_review', 'interview'])
                        ->lockForUpdate()
                        ->get();

                    foreach ($otherApplications as $other) {
                        Lowongan::query()
                            ->whereKey($other->id_lowongan)
                            ->lockForUpdate()
                            ->increment('kuota');
                        $other->update([
                            'status' => 'withdrawn',
                            'withdrawn_at' => now(),
                        ]);
                    }
                }

                if ($newStatus === 'rejected' && $oldStatus !== 'rejected') {
                    Lowongan::query()
                        ->whereKey($pendaftaran->id_lowongan)
                        ->lockForUpdate()
                        ->increment('kuota');
                }

                $pendaftaran->update([
                    'status' => $newStatus,
                    'accepted_at' => $newStatus === 'accepted'
                        ? ($pendaftaran->accepted_at ?? now())
                        : $pendaftaran->accepted_at,
                    'rejected_at' => $newStatus === 'rejected' ? now() : $pendaftaran->rejected_at,
                    'withdrawn_at' => $newStatus === 'withdrawn' ? now() : $pendaftaran->withdrawn_at,
                    'completed_at' => $pendaftaran->completed_at,
                    'rejection_reason' => $newStatus === 'rejected'
                        ? ($validated['rejection_reason'] ?? null)
                        : $pendaftaran->rejection_reason,
                ]);
            }

            return compact('pendaftaran', 'changed');
        }, 3);

        if (isset($result['error'])) {
            return response()->json([
                'message' => $result['error'],
                'code' => $result['code'] ?? null,
            ], $result['status']);
        }

        $pendaftaran = $result['pendaftaran'];
        $status = $pendaftaran->status;

        if ($result['changed']) {
            $title = match ($status) {
                'accepted' => 'Lamaran diterima',
                'rejected' => 'Lamaran ditolak',
                default => 'Status lamaran diperbarui',
            };

            $this->notifySafely(
                $pendaftaran->mahasiswa?->user,
                new ApiNotification(
                    'status_pendaftaran',
                    $title,
                    'Status lamaran Anda menjadi '.$status.'.',
                    [
                        'id_pendaftaran' => $pendaftaran->id_pendaftaran,
                        'id_lowongan' => $pendaftaran->id_lowongan,
                        'status' => $status,
                        'category' => 'update',
                        'requires_action' => false,
                    ]
                ),
                'pendaftaran.status_updated',
            );
        }

        return response()->json([
            'message' => $result['changed']
                ? 'Status pendaftaran berhasil diubah menjadi '.$status
                : 'Status pendaftaran tidak berubah.',
            'data' => new PendaftaranResource(
                $pendaftaran->load('lowongan.mitra')
            ),
        ], 200);
    }

    public function complete(Request $request, string $id)
    {
        $result = DB::transaction(function () use ($request, $id) {
            $pendaftaran = Pendaftaran::query()
                ->with(['mahasiswa.user', 'lowongan.mitra', 'bimbingan.dosen'])
                ->withCount([
                    'logbook as approved_logbooks_count' => fn ($query) => $query
                        ->where('status_validasi', 'disetujui'),
                ])
                ->lockForUpdate()
                ->find($id);

            if (! $pendaftaran) {
                return ['error' => 'Data pendaftaran tidak ditemukan.', 'status' => 404];
            }

            if ($request->user()->role === 'dosen') {
                $dosen = $request->user()->dosen;
                if (! $dosen || $pendaftaran->bimbingan?->nidn !== $dosen->nidn) {
                    return [
                        'error' => 'Anda bukan dosen pembimbing mahasiswa ini.',
                        'status' => 403,
                    ];
                }
            }

            if ($pendaftaran->status === 'completed' && $pendaftaran->completed_at) {
                return compact('pendaftaran') + ['changed' => false];
            }

            if ($pendaftaran->status !== 'accepted') {
                return [
                    'error' => 'Hanya magang berstatus accepted yang dapat diselesaikan.',
                    'status' => 422,
                ];
            }

            $minimumLogbooks = config('internship.minimum_logbooks_to_complete');
            if ($pendaftaran->approved_logbooks_count < $minimumLogbooks) {
                return [
                    'error' => 'Persyaratan logbook belum terpenuhi.',
                    'status' => 422,
                    'code' => 'LOGBOOK_REQUIREMENT_NOT_MET',
                    'required_logbooks' => $minimumLogbooks,
                    'approved_logbooks' => $pendaftaran->approved_logbooks_count,
                ];
            }

            $pendaftaran->update([
                'status' => 'completed',
                'completed_at' => now(),
            ]);

            return compact('pendaftaran') + ['changed' => true];
        }, 3);

        if (isset($result['error'])) {
            return response()->json($result, $result['status']);
        }

        $pendaftaran = $result['pendaftaran'];
        if ($result['changed']) {
            $this->notifySafely(
                $pendaftaran->mahasiswa?->user,
                new ApiNotification(
                    'internship_completed',
                    'Program magang selesai',
                    'Program magang Anda telah dinyatakan selesai.',
                    [
                        'id_pendaftaran' => $pendaftaran->id_pendaftaran,
                        'id_lowongan' => $pendaftaran->id_lowongan,
                        'status' => 'completed',
                        'category' => 'update',
                        'requires_action' => false,
                    ],
                ),
                'pendaftaran.completed',
            );
        }

        return response()->json([
            'message' => $result['changed']
                ? 'Program magang berhasil diselesaikan.'
                : 'Program magang sudah diselesaikan sebelumnya.',
            'data' => new PendaftaranResource(
                $pendaftaran->load(['lowongan.mitra', 'logbook'])
            ),
        ]);
    }

    /**
     * GET /api/lowongan/{id_lowongan}/pelamar  — list pelamar untuk lowongan tertentu (mitra)
     */
    public function getPelamar(Request $request, string $id_lowongan)
    {
        $lowongan = Lowongan::with('mitra')->find($id_lowongan);
        if (! $lowongan) {
            return response()->json(['message' => 'Lowongan tidak ditemukan.'], 404);
        }

        $mitra = $request->user()->mitra;
        if (! $mitra || $lowongan->id_mitra !== $mitra->id_mitra) {
            return response()->json([
                'message' => 'Anda tidak memiliki akses ke pelamar lowongan ini.',
            ], 403);
        }

        $pelamar = Pendaftaran::query()
            ->where('id_lowongan', $lowongan->id_lowongan)
            ->with(['mahasiswa.user', 'lowongan'])
            ->latest('created_at')
            ->get()
            ->map(fn (Pendaftaran $item) => [
                'id_pendaftaran' => $item->id_pendaftaran,
                'id_lowongan' => $item->id_lowongan,
                'nama_mahasiswa' => $item->mahasiswa?->nama,
                'nim' => $item->id_mahasiswa,
                'jurusan' => $item->mahasiswa?->jurusan,
                'email' => $item->mahasiswa?->user?->email_or_nim,
                'no_telp' => $item->mahasiswa?->user?->phone,
                'semester' => $item->mahasiswa?->user?->semester !== null
                    ? (int) $item->mahasiswa->user->semester
                    : null,
                'motivasi' => $item->motivasi,
                'status' => $item->status,
                'tanggal_daftar' => $item->created_at?->toISOString(),
                'url_cv' => $this->publicFileUrl($item->berkas_cv),
                'url_portofolio' => $this->publicFileUrl($item->portofolio),
                'portofolio_link' => $item->portfolio_link,
            ]);

        return response()->json([
            'message' => $pelamar->isEmpty()
                ? 'Belum ada pelamar untuk lowongan ini.'
                : 'Berhasil mengambil daftar pelamar',
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

        if (! in_array($pendaftaran->status, ['accepted', 'completed', 'diterima', 'selesai'], true)) {
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

    private function publicFileUrl(?string $path): ?string
    {
        if (! $path) {
            return null;
        }

        $storageUrl = Storage::disk('public')->url($path);
        $absoluteUrl = Str::startsWith($storageUrl, ['http://', 'https://'])
            ? $storageUrl
            : url($storageUrl);

        return Str::replaceStart('http://', 'https://', $absoluteUrl);
    }
}
