<?php
/**
 * validasi ip dan browser yang akses php
 * 1 clientIP di cek jika tidak terdaftar di allowedIPs maka diblokir
 * 2 useragent di cek jika bukan firefox maka diblokir
 * 3 blokir akses tanpa referer
 */

// --- Configuration ---
$allowedIPs = ['192.168.13.200', '1.1.1.2'];

// --- 1. IP Check ---
$clientIP = $_SERVER['REMOTE_ADDR'] ?? '';

if (!in_array($clientIP, $allowedIPs, true)) {
    http_response_code(403);
    exit('Access denied.');
}

// --- 2. Browser Check ---
if (!empty($_SERVER['HTTP_SEC_CH_UA'])) {
    http_response_code(403);
    exit('Access denied.');
}

$uaBlockKeywords = [
    'chrom',
    'edg',
    'opr',
    'opios',
    'browser',
    'bot',
    'crawl',
    'spider',
    'slurp',
    'scrap',
];

$uaRequireStart = 'Mozilla/5.0';

$uaRequireAll = [
    'Gecko',
];

$uaRequireAny = [
    'Firefox',
    'FxiOS',
];

function checkUserAgent(string $ua, array $blockKeywords, string $requireStart, array $requireAll, array $requireAny): bool
{
    $uaLower = strtolower($ua);

    if (!str_starts_with($ua, $requireStart)) {
        return false;
    }

    foreach ($blockKeywords as $keyword) {
        if (str_contains($uaLower, $keyword)) {
            return false;
        }
    }

    foreach ($requireAll as $keyword) {
        if (!str_contains($ua, $keyword)) {
            return false;
        }
    }

    foreach ($requireAny as $keyword) {
        if (str_contains($ua, $keyword)) {
            return true;
        }
    }

    return false;
}

$ua = $_SERVER['HTTP_USER_AGENT'] ?? '';

if (!checkUserAgent($ua, $uaBlockKeywords, $uaRequireStart, $uaRequireAll, $uaRequireAny)) {
    http_response_code(403);
    exit('Access denied.');
}

// --- 3. referer check
$requestUri = parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH);
$referer    = $_SERVER['HTTP_REFERER'] ?? '';

if ($requestUri !== '/index.php' && empty($referer)) {
    http_response_code(403);
    exit('Access denied.');
}
