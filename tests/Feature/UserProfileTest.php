<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class UserProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_can_update_own_profile_and_get_consistent_profile(): void
    {
        $student = $this->user('Nama Lama', '22.11.0002', 'mahasiswa');
        Sanctum::actingAs($student);

        $this->putJson('/api/user/profile', [
            'name' => 'Andi Wibowo',
            'semester' => 6,
            'phone' => '081234567890',
        ])->assertOk()
            ->assertJsonPath('message', 'Profil berhasil diperbarui.')
            ->assertJsonPath('data.id', $student->id)
            ->assertJsonPath('data.name', 'Andi Wibowo')
            ->assertJsonPath('data.email_or_nim', '22.11.0002')
            ->assertJsonPath('data.role', 'mahasiswa')
            ->assertJsonPath('data.semester', 6)
            ->assertJsonPath('data.phone', '081234567890');

        $this->assertDatabaseHas('users', [
            'id' => $student->id,
            'name' => 'Andi Wibowo',
            'semester' => 6,
            'phone' => '081234567890',
        ]);
        $this->assertDatabaseHas('mahasiswa', [
            'id_user' => (string) $student->id,
            'id_mahasiswa' => '22.11.0002',
            'nama' => 'Andi Wibowo',
        ]);
        $this->assertDatabaseCount('mahasiswa', 1);

        $this->getJson('/api/user')
            ->assertOk()
            ->assertJsonPath('data.semester', 6)
            ->assertJsonPath('data.phone', '081234567890');
    }

    public function test_request_cannot_update_another_user_and_non_student_is_forbidden(): void
    {
        $student = $this->user('Mahasiswa', '22.11.0002', 'mahasiswa');
        $other = $this->user('Mahasiswa Lain', '22.11.0003', 'mahasiswa');
        Sanctum::actingAs($student);

        $this->putJson('/api/user/profile', [
            'id' => $other->id,
            'name' => 'Andi Wibowo',
            'semester' => 6,
            'phone' => '081234567890',
        ])->assertOk();

        $this->assertSame('Mahasiswa Lain', $other->fresh()->name);
        $this->assertNull($other->fresh()->semester);
        $this->assertNull($other->fresh()->phone);

        $partner = $this->user('Mitra', 'mitra@nexus.test', 'mitra');
        Sanctum::actingAs($partner);
        $this->putJson('/api/user/profile', [
            'name' => 'Mitra Baru',
            'semester' => 6,
            'phone' => '081234567890',
        ])->assertForbidden();
    }

    public function test_invalid_token_is_unauthorized(): void
    {
        $this->withToken('token-tidak-valid')
            ->putJson('/api/user/profile', [
                'name' => 'Tidak Valid',
                'semester' => 6,
                'phone' => '081234567890',
            ])->assertUnauthorized();
    }

    public function test_profile_validation_returns_422(): void
    {
        $student = $this->user('Mahasiswa', '22.11.0002', 'mahasiswa');
        Sanctum::actingAs($student);

        $this->putJson('/api/user/profile', [
            'name' => '',
            'semester' => 15,
            'phone' => str_repeat('1', 16),
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'semester', 'phone']);
    }

    private function user(string $name, string $identifier, string $role): User
    {
        return User::create([
            'name' => $name,
            'email_or_nim' => $identifier,
            'password' => 'password',
            'role' => $role,
        ]);
    }
}
