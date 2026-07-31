<?php
// these headers might cause false positives
//    'HTTP_CF_CONNECTING_IP',   // Cloudflare
//    'HTTP_TRUE_CLIENT_IP',     // Akamai / Cloudflare Enterprise
//    'HTTP_FORWARDED_FOR',
//    'HTTP_X_FORWARDED_FOR',
//    'HTTP_X_REAL_IP',

// this one shorter
<?php
foreach (getallheaders() as $name => $value) {
    if (preg_match('/proxy|remote|client_ip/via/i', $name)) {
        http_response_code(400);
        exit('You got Blocked by mypolaris.com');
    }
}


// this use function
$proxyKeywords = ['PROXY', 'REMOTE', 'CLIENT_IP', 'VIA'];

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
    http_response_code(400);
    exit('You got Blocked by mypolaris.com');
}
