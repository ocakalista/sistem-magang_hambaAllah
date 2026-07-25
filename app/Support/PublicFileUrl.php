<?php

namespace App\Support;

use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class PublicFileUrl
{
    public static function from(?string $path): ?string
    {
        if (! $path || ! trim($path)) {
            return null;
        }

        $path = str_replace('\\', '/', trim($path));

        if (filter_var($path, FILTER_VALIDATE_URL)) {
            return Str::replaceStart('http://', 'https://', $path);
        }

        $path = preg_replace('#^.*?/storage/app/public/#i', '', $path);
        $path = preg_replace('#^/?app/storage/#i', '', $path);

        do {
            $previous = $path;
            $path = preg_replace('#^/?(?:storage|public)/+#i', '', $path);
        } while ($path !== $previous);

        $storageUrl = Storage::disk('public')->url(ltrim($path, '/'));
        $absoluteUrl = Str::startsWith($storageUrl, ['http://', 'https://'])
            ? $storageUrl
            : url($storageUrl);

        return Str::replaceStart('http://', 'https://', $absoluteUrl);
    }
}
