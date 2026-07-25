<?php

namespace App\Support;

use Illuminate\Support\Facades\Log;
use Throwable;

trait SendsNotificationsSafely
{
    protected function notifySafely(?object $recipient, object $notification, string $event): void
    {
        if (! $recipient) {
            return;
        }

        try {
            $recipient->notify($notification);
        } catch (Throwable $exception) {
            Log::error('Notification delivery failed.', [
                'event' => $event,
                'recipient_id' => $recipient->getKey(),
                'exception' => $exception::class,
                'message' => $exception->getMessage(),
            ]);
        }
    }
}
