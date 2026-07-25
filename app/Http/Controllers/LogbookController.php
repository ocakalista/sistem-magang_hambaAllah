<?php

namespace App\Http\Controllers;

use App\Http\Resources\LogbookResource;
use App\Models\Logbook;
use App\Models\Pendaftaran;
use App\Notifications\ApiNotification;
use App\Support\SendsNotificationsSafely;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Throwable;

class LogbookController extends Controller
{
    use SendsNotificationsSafely;

    // 1. FITUR BARU: Menampilkan riwayat logbook (Khusus Mahasiswa yang sedang login)
    public function index(Request $request)
    {
        $logbook = Logbook::query()
            ->whereHas('pendaftaran', fn ($query) => $query
                ->where('id_mahasiswa', $request->user()->email_or_nim))
            ->with([
                'validatorDosen.user',
                'pendaftaran.bimbingan.dosen.user',
            ])
            ->latest('tanggal')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil riwayat logbook',
            'data' => LogbookResource::collection($logbook),
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
        if ($pendaftaran->id_mahasiswa !== $request->user()->email_or_nim) {
            return response()->json(['message' => 'Akses ditolak!'], 403);
        }

        if (! in_array($pendaftaran->status, ['accepted', 'diterima'], true)) {
            return response()->json([
                'message' => 'Gagal! Mahasiswa ini belum berstatus diterima.',
            ], 403);
        }

        $attachmentPath = null;
        if ($request->hasFile('berkas_lampiran')) {
            $file = $request->file('berkas_lampiran');
            $name = uniqid('logbook_', true).'_'.preg_replace('/\s+/', '_', $file->getClientOriginalName());
            $attachmentPath = $file->storeAs('logbook', $name, 'public');
        }

        try {
            $logbook = DB::transaction(fn () => Logbook::create([
                'id_pendaftaran' => $pendaftaran->id_pendaftaran,
                'minggu_ke' => $request->minggu_ke,
                'tanggal' => $request->tanggal,
                'deskripsi_kegiatan' => $request->deskripsi_kegiatan,
                'berkas_lampiran' => $attachmentPath,
                'status_validasi' => 'pending',
                'feedback_dosen' => null,
            ]));
        } catch (Throwable $exception) {
            if ($attachmentPath) {
                Storage::disk('public')->delete($attachmentPath);
            }

            Log::error('Logbook submission failed.', [
                'user_id' => $request->user()->id,
                'id_pendaftaran' => $pendaftaran->id_pendaftaran,
                'exception' => $exception::class,
                'message' => $exception->getMessage(),
            ]);

            return response()->json(['message' => 'Logbook gagal disimpan.'], 500);
        }

        $this->notifySupervisor($logbook, $pendaftaran, 'logbook_submitted');

        return response()->json([
            'message' => 'Logbook minggu ke-'.$request->minggu_ke.' berhasil dikirim!',
            'data' => new LogbookResource(
                $logbook->load(['validatorDosen.user', 'pendaftaran.bimbingan.dosen.user'])
            ),
        ], 201);
    }

    // 3. FITUR DOSEN: Mengubah status logbook & memberikan feedback (US-21)
    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'status_validasi' => 'required|in:disetujui,revisi',
            'feedback_dosen' => 'nullable|required_if:status_validasi,revisi|string|max:5000',
        ]);

        $logbook = Logbook::with([
            'pendaftaran.bimbingan.dosen.user',
            'pendaftaran.mahasiswa.user',
            'validatorDosen.user',
        ])->find($id);

        if (! $logbook) {
            return response()->json(['message' => 'Data logbook tidak ditemukan'], 404);
        }

        $dosen = $request->user()->dosen;
        if (
            ! $dosen
            || ! $logbook->pendaftaran?->bimbingan
            || $logbook->pendaftaran->bimbingan->nidn !== $dosen->nidn
        ) {
            return response()->json([
                'message' => 'Anda bukan dosen pembimbing untuk logbook ini.',
            ], 403);
        }

        DB::transaction(function () use ($logbook, $validated, $dosen) {
            $logbook->status_validasi = $validated['status_validasi'];
            $logbook->feedback_dosen = $validated['feedback_dosen'] ?? null;
            $logbook->id_dosen_feedback = $dosen->nidn;
            $logbook->validated_at = now();
            $logbook->save();
        });

        $this->notifySafely(
            $logbook->pendaftaran?->mahasiswa?->user,
            new ApiNotification(
                'status_logbook',
                $logbook->status_validasi === 'disetujui'
                    ? 'Logbook disetujui'
                    : 'Logbook perlu direvisi',
                $logbook->feedback_dosen
                    ?: 'Status logbook minggu ke-'.$logbook->minggu_ke.' diperbarui.',
                [
                    'id_logbook' => $logbook->id_logbook,
                    'id_pendaftaran' => $logbook->id_pendaftaran,
                    'status_validasi' => $logbook->status_validasi,
                    'category' => 'update',
                    'requires_action' => false,
                ],
            ),
            'logbook.reviewed',
        );

        return response()->json([
            'message' => 'Status logbook berhasil diubah menjadi '.$logbook->status_validasi,
            'data' => new LogbookResource(
                $logbook->load(['validatorDosen.user', 'pendaftaran.bimbingan.dosen.user'])
            ),
        ], 200);
    }

    public function resubmit(Request $request, $id)
    {
        $validated = $request->validate([
            'tanggal' => 'required|date',
            'deskripsi_kegiatan' => 'nullable|required_without:berkas_lampiran|string|max:10000',
            'berkas_lampiran' => 'nullable|required_without:deskripsi_kegiatan|file|mimes:pdf,doc,docx,jpg,jpeg,png|max:5120',
        ]);

        $logbook = Logbook::with('pendaftaran.bimbingan.dosen.user')->find($id);
        if (! $logbook) {
            return response()->json(['message' => 'Data logbook tidak ditemukan'], 404);
        }

        $pendaftaran = $logbook->pendaftaran;
        if (! $pendaftaran || $pendaftaran->id_mahasiswa !== $request->user()->email_or_nim) {
            return response()->json(['message' => 'Akses ditolak!'], 403);
        }

        if ($logbook->status_validasi !== 'revisi') {
            return response()->json([
                'message' => 'Hanya logbook berstatus revisi yang dapat dikirim ulang.',
            ], 409);
        }

        $oldAttachment = $logbook->berkas_lampiran;
        $newAttachment = null;

        if ($request->hasFile('berkas_lampiran')) {
            $file = $request->file('berkas_lampiran');
            $name = uniqid('logbook_', true).'_'.preg_replace('/\s+/', '_', $file->getClientOriginalName());
            $newAttachment = $file->storeAs('logbook', $name, 'public');
        }

        try {
            DB::transaction(function () use ($logbook, $validated, $newAttachment) {
                $logbook->tanggal = $validated['tanggal'];
                $logbook->deskripsi_kegiatan = $validated['deskripsi_kegiatan'] ?? null;
                if ($newAttachment) {
                    $logbook->berkas_lampiran = $newAttachment;
                }
                $logbook->status_validasi = 'pending';
                $logbook->feedback_dosen = null;
                $logbook->id_dosen_feedback = null;
                $logbook->validated_at = null;
                $logbook->save();
            });
        } catch (Throwable $exception) {
            if ($newAttachment) {
                Storage::disk('public')->delete($newAttachment);
            }

            Log::error('Logbook resubmission failed.', [
                'user_id' => $request->user()->id,
                'id_logbook' => $logbook->id_logbook,
                'exception' => $exception::class,
                'message' => $exception->getMessage(),
            ]);

            return response()->json(['message' => 'Logbook gagal dikirim ulang.'], 500);
        }

        if ($newAttachment && $oldAttachment) {
            Storage::disk('public')->delete($oldAttachment);
        }

        $this->notifySupervisor($logbook, $pendaftaran, 'logbook_resubmitted');

        return response()->json([
            'message' => 'Logbook berhasil dikirim ulang dan menunggu review.',
            'data' => new LogbookResource(
                $logbook->load(['validatorDosen.user', 'pendaftaran.bimbingan.dosen.user'])
            ),
        ]);
    }

    // 4. FITUR BARU: Dosen & Mitra melihat isi logbook mahasiswa tertentu
    public function getLogbookByPendaftaran(Request $request, $id_pendaftaran)
    {
        $pendaftaran = Pendaftaran::with(['bimbingan.dosen', 'lowongan.mitra'])->find($id_pendaftaran);
        if (! $pendaftaran) {
            return response()->json(['message' => 'Data pendaftaran tidak ditemukan.'], 404);
        }

        if ($request->user()->role === 'dosen') {
            $dosen = $request->user()->dosen;
            if (! $dosen || $pendaftaran->bimbingan?->nidn !== $dosen->nidn) {
                return response()->json([
                    'message' => 'Anda bukan dosen pembimbing mahasiswa ini.',
                ], 403);
            }
        } elseif ($request->user()->role === 'mitra') {
            $mitra = $request->user()->mitra;
            if (! $mitra || $pendaftaran->lowongan?->id_mitra !== $mitra->id_mitra) {
                return response()->json([
                    'message' => 'Anda tidak memiliki akses ke logbook ini.',
                ], 403);
            }
        }

        $logbook = Logbook::query()
            ->where('id_pendaftaran', $pendaftaran->id_pendaftaran)
            ->with(['validatorDosen.user', 'pendaftaran.bimbingan.dosen.user'])
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
            'data' => LogbookResource::collection($logbook),
        ], 200);
    }

    private function notifySupervisor(Logbook $logbook, Pendaftaran $pendaftaran, string $type): void
    {
        $pendaftaran->loadMissing(['mahasiswa', 'bimbingan.dosen.user']);
        $dosenUser = $pendaftaran->bimbingan?->dosen?->user;

        $this->notifySafely(
            $dosenUser,
            new ApiNotification(
                $type,
                $type === 'logbook_submitted'
                    ? 'Logbook baru menunggu review'
                    : 'Logbook revisi menunggu review',
                ($pendaftaran->mahasiswa?->nama ?? $pendaftaran->id_mahasiswa)
                    .' mengirim logbook minggu ke-'.$logbook->minggu_ke.'.',
                [
                    'id_logbook' => $logbook->id_logbook,
                    'id_pendaftaran' => $logbook->id_pendaftaran,
                    'id_mahasiswa' => $pendaftaran->id_mahasiswa,
                    'category' => 'approval',
                    'requires_action' => true,
                    'priority' => 'high',
                ],
            ),
            $type,
        );
    }
}
