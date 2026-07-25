<?php

namespace Tests\Feature;

use App\Models\User;
use App\Notifications\ApiNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class NotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_notifications_are_private_and_can_be_marked_read_idempotently(): void
    {
        $user = $this->user('22.11.0001');
        $other = $this->user('22.11.0002');
        $user->notify(new ApiNotification('test', 'Judul', 'Deskripsi', ['key' => 'value']));
        $other->notify(new ApiNotification('other', 'Rahasia', 'Milik orang lain'));

        Sanctum::actingAs($user);

        $response = $this->getJson('/api/notifications')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.description', 'Deskripsi')
            ->assertJsonPath('data.0.data.key', 'value');

        $ownId = $response->json('data.0.id');
        $otherId = $other->notifications()->first()->id;

        $this->patchJson('/api/notifications/'.$otherId.'/read')->assertNotFound();
        $this->patchJson('/api/notifications/'.$ownId.'/read')->assertOk();
        $this->patchJson('/api/notifications/'.$ownId.'/read')->assertOk();
    }

    public function test_mark_all_only_updates_current_users_notifications(): void
    {
        $user = $this->user('22.11.0001');
        $other = $this->user('22.11.0002');
        $user->notify(new ApiNotification('one', 'Satu', 'Satu'));
        $user->notify(new ApiNotification('two', 'Dua', 'Dua'));
        $other->notify(new ApiNotification('other', 'Lain', 'Lain'));

        Sanctum::actingAs($user);

        $this->patchJson('/api/notifications/read-all')
            ->assertOk()
            ->assertJsonPath('updated_count', 2);

        $this->assertSame(0, $user->unreadNotifications()->count());
        $this->assertSame(1, $other->unreadNotifications()->count());
    }

    private function user(string $identifier): User
    {
        return User::create([
            'name' => $identifier,
            'email_or_nim' => $identifier,
            'password' => 'password',
            'role' => 'mahasiswa',
        ]);
    }
}
