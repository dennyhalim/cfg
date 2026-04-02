<?php
// these headers might cause false positives
//    'HTTP_CF_CONNECTING_IP',   // Cloudflare
//    'HTTP_TRUE_CLIENT_IP',     // Akamai / Cloudflare Enterprise
//    'HTTP_FORWARDED_FOR',
//    'HTTP_X_FORWARDED_FOR',
//    'HTTP_X_REAL_IP',

$proxyKeywords = ['PROXY', 'REMOTE', 'CLIENT_IP'];

function hasProxyHeaders(array $keywords): bool
{
    foreach ($_SERVER as $key => $value) {
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
