<?php

// Headers commonly set by proxies, VPNs, and anonymizers
$proxyHeaders = [
    'HTTP_VIA',
    'HTTP_X_FORWARDED',
    'HTTP_FORWARDED',
    'HTTP_CLIENT_IP',
    'HTTP_X_CLIENT_IP',
    'HTTP_X_CLUSTER_CLIENT_IP',
    'HTTP_PROXY',
    'HTTP_X_PROXY',
    'HTTP_PROXY_ID',
    'HTTP_X_ORIGINATING_IP',
    'HTTP_X_REMOTE_IP',
    'HTTP_X_REMOTE_ADDR',
//    'HTTP_CF_CONNECTING_IP',   // Cloudflare
//    'HTTP_TRUE_CLIENT_IP',     // Akamai / Cloudflare Enterprise
//    'HTTP_FORWARDED_FOR',
//    'HTTP_X_FORWARDED_FOR',
//    'HTTP_X_REAL_IP',
];

function isProxy(array $proxyHeaders): bool
{
    foreach ($proxyHeaders as $header) {
        if (!empty($_SERVER[$header])) {
            return true;
        }
    }

    return false;
}

if (isProxy($proxyHeaders)) {
    http_response_code(403);
    exit('Access denied.');
}


function isProxyIP(string $ip): bool
{
    // Example using ip-api.com (free tier, non-commercial)
    $response = @file_get_contents("http://ip-api.com/json/{$ip}?fields=proxy,hosting,vpn");
    if (!$response) return false;

    $data = json_decode($response, true);
    return !empty($data['proxy']) || !empty($data['hosting']) || !empty($data['vpn']);
}

$ip = $_SERVER['REMOTE_ADDR'] ?? '';

if (isProxy($proxyHeaders) || isProxyIP($ip)) {
    http_response_code(403);
    exit('Access denied.');
}
