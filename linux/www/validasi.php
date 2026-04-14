<?php
/**
* browsers validations
*
*/
$proxyKeywords = ['HTTP_SEC_CH_UA', 'PROXY', 'CLIENT_IP'];

function hasProxyHeaders(array $keywords): bool
{
    foreach (array_keys($_SERVER) as $key) {
        foreach ($keywords as $keyword) {
            if (str_contains($key, $keyword)) {
                return true;
            }
        }
    }
    return false;
}

if (hasProxyHeaders($proxyKeywords)) {
    http_response_code(403);
    exit('Access denied.');
}

//cek useragent
function isFirefox(string $ua): bool
{
    $uaLower = strtolower($ua);

    // must not contain these (case-insensitive)
    foreach (['bot', 'crawl', 'spider', 'slurp', 'scrap', 'chrom', 'edg', 'browser'] as $keyword) {
        if (str_contains($uaLower, $keyword)) {
            return false;
        }
    }

    // must start with Mozilla/5.0 (case-sensitive)
    if (!str_starts_with($ua, 'Mozilla/5.0')) {
        return false;
    }

    // must contain Gecko (case-sensitive)
    if (!str_contains($ua, 'Gecko')) {
        return false;
    }

    // iOS device
    $isIOS = str_contains($ua, 'iPhone') || str_contains($ua, 'iPad');

    if ($isIOS) {
        // iOS Firefox must have FxiOS (case-sensitive)
        return str_contains($ua, 'FxiOS');
    }

    // desktop: must have Firefox (case-sensitive)
    if (!str_contains($ua, 'Firefox')) {
        return false;
    }

    // desktop: must not contain these (case-insensitive)
    foreach (['safari', 'like', 'khtml'] as $keyword) {
        if (str_contains($uaLower, $keyword)) {
            return false;
        }
    }

    return true;
}

$ua = $_SERVER['HTTP_USER_AGENT'] ?? '';

if (!isFirefox($ua)) {
    http_response_code(403);
    exit('Access denied.');
}

// send headers
header("Content-Security-Policy: default-src 'self'");
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: same-origin, origin-when-cross-origin');
