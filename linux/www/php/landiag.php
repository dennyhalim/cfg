<?php
/**
 * Single-file client IP and network diagnostics.
 * Requires PHP 7.4+ for array-form proc_open commands.
 * Edit the PHP configuration defaults; environment variables can override them.
 */
declare(strict_types=1);

header('Content-Type: text/html; charset=UTF-8');
header('Cache-Control: no-store, private');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: no-referrer');
header("Content-Security-Policy: default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; frame-ancestors 'none'; form-action 'none'");

// PHP defaults; environment variables override these values when present.
// This diagnostic page is intended for controlled/internal use. With
// trust_proxy_headers=true and an empty trusted_proxies list, forwarding
// headers are accepted from any peer. Set trusted_proxies to CIDRs in production.
$config = [
    'trust_proxy_headers' => true,
    'trusted_proxies' => [],
    'geo_enabled' => true,
    'geo_api_key' => '',
    'ping_enabled' => true,
    'traceroute_enabled' => true,
    'port_scan_enabled' => true,
    'command_timeout' => 5,
    'trace_timeout' => 15,
    'connect_timeout' => 0.3,
    'auth_user' => '',
    'auth_pass' => '',
];

function envBool(string $name, bool $default): bool
{
    $value = getenv($name);
    if ($value === false || $value === '') return $default;
    return !in_array(strtolower(trim($value)), ['0', 'false', 'no', 'off'], true);
}

function envString(string $name, string $default): string
{
    $value = getenv($name);
    return $value === false ? $default : $value;
}

$config['trust_proxy_headers'] = envBool('TRUST_PROXY_HEADERS', $config['trust_proxy_headers']);
$config['geo_enabled'] = envBool('ENABLE_GEOLOOKUP', $config['geo_enabled']);
$config['ping_enabled'] = envBool('ENABLE_PING', $config['ping_enabled']);
$config['traceroute_enabled'] = envBool('ENABLE_TRACEROUTE', $config['traceroute_enabled']);
$config['port_scan_enabled'] = envBool('ENABLE_PORT_SCAN', $config['port_scan_enabled']);
$config['geo_api_key'] = envString('IPAPI_KEY', $config['geo_api_key']);
$config['auth_user'] = envString('DIAG_USER', $config['auth_user']);
$config['auth_pass'] = envString('DIAG_PASS', $config['auth_pass']);
$config['trusted_proxies'] = array_values(array_filter(array_map('trim', explode(',', envString(
    'TRUSTED_PROXIES', implode(',', $config['trusted_proxies'])
)))));
$config['command_timeout'] = max(1, (int) envString('COMMAND_TIMEOUT', (string) $config['command_timeout']));
$config['trace_timeout'] = max(1, (int) envString('TRACE_TIMEOUT', (string) $config['trace_timeout']));
$config['connect_timeout'] = max(0.1, (float) envString('CONNECT_TIMEOUT', (string) $config['connect_timeout']));

$authUser = $config['auth_user'];
$authPass = $config['auth_pass'];
if ($authUser !== '' || $authPass !== '') {
    if ($authUser === '' || $authPass === '') {
        http_response_code(500);
        exit('Set both auth_user and auth_pass, or leave both empty.');
    }
    $givenUser = (string) ($_SERVER['PHP_AUTH_USER'] ?? '');
    $givenPass = (string) ($_SERVER['PHP_AUTH_PW'] ?? '');
    if (!hash_equals($authUser, $givenUser) || !hash_equals($authPass, $givenPass)) {
        header('WWW-Authenticate: Basic realm="Network diagnostics"');
        http_response_code(401);
        exit('Authentication required.');
    }
}

$trustedProxyCidrs = $config['trusted_proxies'];
$ipApiKey = trim($config['geo_api_key']);
$geoEnabled = $config['geo_enabled'];
$probesEnabled = $config['ping_enabled'] || $config['traceroute_enabled'] || $config['port_scan_enabled'];

$ports = [
    21 => 'FTP', 22 => 'SSH', 25 => 'SMTP', 53 => 'DNS/TCP', 80 => 'HTTP',
    110 => 'POP3', 143 => 'IMAP', 443 => 'HTTPS', 445 => 'SMB',
    465 => 'SMTPS', 587 => 'SMTP submission', 993 => 'IMAPS', 995 => 'POP3S',
    3306 => 'MySQL', 3389 => 'RDP', 5432 => 'PostgreSQL', 5900 => 'VNC',
    8080 => 'HTTP alternate', 8443 => 'HTTPS alternate',
];

function h($value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function validIp(string $ip): bool
{
    return filter_var($ip, FILTER_VALIDATE_IP) !== false;
}

function sameIp(string $left, string $right): bool
{
    $leftPacked = @inet_pton($left);
    $rightPacked = @inet_pton($right);
    return $leftPacked !== false && $rightPacked !== false && $leftPacked === $rightPacked;
}

function isPublicIp(string $ip): bool
{
    return filter_var(
        $ip,
        FILTER_VALIDATE_IP,
        FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE
    ) !== false;
}

function ipMatchesCidr(string $ip, string $cidr): bool
{
    $parts = explode('/', $cidr, 2);
    $address = @inet_pton($ip);
    $network = @inet_pton(trim($parts[0]));
    if ($address === false || $network === false || strlen($address) !== strlen($network)) {
        return false;
    }

    $maxBits = strlen($address) * 8;
    $prefix = isset($parts[1]) ? (int) $parts[1] : $maxBits;
    if ($prefix < 0 || $prefix > $maxBits) {
        return false;
    }

    $wholeBytes = intdiv($prefix, 8);
    $remainingBits = $prefix % 8;
    if (substr($address, 0, $wholeBytes) !== substr($network, 0, $wholeBytes)) {
        return false;
    }
    if ($remainingBits === 0) {
        return true;
    }

    $mask = (0xFF << (8 - $remainingBits)) & 0xFF;
    return (ord($address[$wholeBytes]) & $mask) === (ord($network[$wholeBytes]) & $mask);
}

function isTrustedProxy(string $ip, array $trustedCidrs): bool
{
    foreach ($trustedCidrs as $cidr) {
        if (ipMatchesCidr($ip, $cidr)) {
            return true;
        }
    }
    return false;
}

function requestHeaders(): array
{
    $headers = [];
    if (function_exists('getallheaders')) {
        $received = getallheaders();
        if (is_array($received)) {
            $headers = $received;
        }
    }

    foreach ($_SERVER as $key => $value) {
        if (strpos($key, 'HTTP_') === 0 && is_scalar($value)) {
            $name = str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($key, 5)))));
            if (!array_key_exists($name, $headers)) {
                $headers[$name] = (string) $value;
            }
        }
    }
    foreach (['CONTENT_TYPE', 'CONTENT_LENGTH'] as $key) {
        if (isset($_SERVER[$key]) && !isset($headers[$key])) {
            $headers[str_replace('_', '-', ucwords(strtolower($key), '_'))] = (string) $_SERVER[$key];
        }
    }

    uksort($headers, 'strcasecmp');
    return $headers;
}

function headerValue(array $headers, string $wanted): string
{
    foreach ($headers as $name => $value) {
        if (strcasecmp((string) $name, $wanted) === 0) {
            return trim((string) $value);
        }
    }
    return '';
}

function resolveClientIp(string $remoteIp, array $headers, array $trustedCidrs, bool $trustHeaders): array
{
    $result = ['ip' => $remoteIp, 'source' => 'REMOTE_ADDR', 'chain' => []];
    if (!$trustHeaders || !validIp($remoteIp)) return $result;
    if ($trustedCidrs && !isTrustedProxy($remoteIp, $trustedCidrs)) return $result;

    $xff = headerValue($headers, 'X-Forwarded-For');
    if ($xff !== '') {
        $chain = [];
        foreach (explode(',', $xff) as $item) {
            $candidate = trim($item);
            if (validIp($candidate)) $chain[] = $candidate;
        }
        $result['chain'] = $chain;
        if ($chain) {
            $result['ip'] = $chain[0];
            $result['source'] = 'X-Forwarded-For (first valid entry)';
            return $result;
        }
    }

    foreach (['CF-Connecting-IP', 'True-Client-IP', 'X-Real-IP'] as $name) {
        $candidate = headerValue($headers, $name);
        if (validIp($candidate)) {
            $result['ip'] = $candidate;
            $result['source'] = $name;
            return $result;
        }
    }
    return $result;
}

function canUseProcOpen(): bool
{
    if (PHP_VERSION_ID < 70400 || !function_exists('proc_open')) {
        return false;
    }
    $disabled = array_map('trim', explode(',', (string) ini_get('disable_functions')));
    return !in_array('proc_open', $disabled, true);
}

function findExecutable(array $names): ?string
{
    $path = (string) getenv('PATH');
    $directories = $path !== '' ? explode(PATH_SEPARATOR, $path) : [];
    $directories = array_merge($directories, [
        '/usr/bin', '/bin', '/usr/sbin', '/sbin', '/usr/local/bin',
        'C:\\Windows\\System32',
    ]);

    foreach (array_unique($directories) as $directory) {
        if ($directory === '') {
            continue;
        }
        foreach ($names as $name) {
            $candidate = rtrim($directory, DIRECTORY_SEPARATOR . '/\\') . DIRECTORY_SEPARATOR . $name;
            if (is_file($candidate) && is_executable($candidate)) {
                return $candidate;
            }
        }
    }
    return null;
}

/** Run a fixed executable with an argument array; no shell interpolation. */
function runCommand(array $command, int $timeoutSeconds): array
{
    $descriptors = [
        0 => ['pipe', 'r'],
        1 => ['pipe', 'w'],
        2 => ['pipe', 'w'],
    ];
    $process = @proc_open($command, $descriptors, $pipes, null, null, ['bypass_shell' => true]);
    if (!is_resource($process)) {
        return ['output' => 'Unable to start the system command.', 'timed_out' => false, 'exit_code' => null];
    }

    fclose($pipes[0]);
    stream_set_blocking($pipes[1], false);
    stream_set_blocking($pipes[2], false);

    $stdout = '';
    $stderr = '';
    $timedOut = false;
    $exitCode = null;
    $started = microtime(true);

    while (true) {
        $stdout .= (string) stream_get_contents($pipes[1]);
        $stderr .= (string) stream_get_contents($pipes[2]);
        $status = proc_get_status($process);

        if (!$status['running']) {
            $exitCode = $status['exitcode'];
            break;
        }
        if ((microtime(true) - $started) >= $timeoutSeconds) {
            $timedOut = true;
            @proc_terminate($process, 9);
            break;
        }
        usleep(100000);
    }

    $stdout .= (string) stream_get_contents($pipes[1]);
    $stderr .= (string) stream_get_contents($pipes[2]);
    fclose($pipes[1]);
    fclose($pipes[2]);
    $closeCode = proc_close($process);
    if ($exitCode === null || $exitCode < 0) {
        $exitCode = $closeCode;
    }

    $output = trim($stdout . ($stderr !== '' ? "\n" . $stderr : ''));
    return [
        'output' => $output !== '' ? $output : '(No command output.)',
        'timed_out' => $timedOut,
        'exit_code' => $exitCode,
    ];
}

function postJson(string $url, array $payload, int $timeout = 4): ?array
{
    $body = json_encode($payload, JSON_UNESCAPED_SLASHES);
    if ($body === false) {
        return null;
    }

    if (function_exists('curl_init')) {
        $curl = curl_init($url);
        curl_setopt_array($curl, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $body,
            CURLOPT_HTTPHEADER => ['Content-Type: application/json', 'Accept: application/json'],
            CURLOPT_CONNECTTIMEOUT => 2,
            CURLOPT_TIMEOUT => $timeout,
            CURLOPT_FOLLOWLOCATION => false,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSL_VERIFYHOST => 2,
            CURLOPT_USERAGENT => 'PHP-Network-Diagnostics/1.0',
        ]);
        $response = curl_exec($curl);
        $status = (int) curl_getinfo($curl, CURLINFO_HTTP_CODE);
        curl_close($curl);
        if (!is_string($response) || $status < 200 || $status >= 300) {
            return null;
        }
    } else {
        $context = stream_context_create([
            'http' => [
                'method' => 'POST',
                'header' => "Content-Type: application/json\r\nAccept: application/json\r\n",
                'content' => $body,
                'timeout' => $timeout,
                'ignore_errors' => true,
            ],
            'ssl' => ['verify_peer' => true, 'verify_peer_name' => true],
        ]);
        $response = @file_get_contents($url, false, $context);
        if (!is_string($response)) {
            return null;
        }
    }

    $data = json_decode($response, true);
    return is_array($data) ? $data : null;
}

function scanTcpPorts(string $ip, array $ports, float $timeout = 0.3): array
{
    $host = filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV6) ? '[' . $ip . ']' : $ip;
    $results = [];
    foreach ($ports as $port => $label) {
        $errno = 0;
        $error = '';
        $socket = @stream_socket_client(
            'tcp://' . $host . ':' . $port,
            $errno,
            $error,
            $timeout,
            STREAM_CLIENT_CONNECT
        );
        if (is_resource($socket)) {
            $results[$port] = ['label' => $label, 'status' => 'Open'];
            fclose($socket);
        }
    }
    return $results;
}

$headers = requestHeaders();
$remoteIp = (string) ($_SERVER['REMOTE_ADDR'] ?? '');
$resolution = resolveClientIp($remoteIp, $headers, $trustedProxyCidrs, $config['trust_proxy_headers']);
$clientIp = $resolution['ip'];
$clientIpSource = $resolution['source'];
$forwardedChain = $resolution['chain'];
$serverIp = (string) ($_SERVER['SERVER_ADDR'] ?? '');
$publicIp = validIp($clientIp) && isPublicIp($clientIp);

// One target for every probe. Never substitute another forwarded address.
$probeIp = validIp($clientIp) && !(validIp($serverIp) && sameIp($clientIp, $serverIp))
    ? $clientIp
    : '';
$probeTargetNote = $probeIp === ''
    ? (validIp($clientIp) && validIp($serverIp) && sameIp($clientIp, $serverIp)
        ? 'Network tests skipped: resolved client IP is the server IP.'
        : 'Network tests skipped: no valid client IP was resolved.')
    : 'Probe target: ' . $probeIp;

$proxyHeaderNames = [
    'Forwarded', 'Via', 'X-Forwarded-For', 'X-Forwarded-Host', 'X-Forwarded-Proto',
    'X-Real-IP', 'CF-Connecting-IP', 'CF-Ray', 'True-Client-IP', 'X-Proxy-ID',
];
$proxyHeaders = [];
foreach ($proxyHeaderNames as $name) {
    $value = headerValue($headers, $name);
    if ($value !== '') {
        $proxyHeaders[$name] = $value;
    }
}

$geo = null;
$geoError = '';
if ($geoEnabled && $publicIp) {
    $payload = ['q' => $clientIp];
    if ($ipApiKey !== '') {
        $payload['key'] = $ipApiKey;
    }
    $geo = postJson('https://api.ipapi.is/', $payload);
    if ($geo === null) {
        $geoError = 'Lookup unavailable (network, PHP HTTP restrictions or API limit).';
    }
} elseif (!$publicIp) {
    $geoError = 'Skipped: client IP is private, reserved or invalid.';
} else {
    $geoError = 'Disabled by ENABLE_GEOLOOKUP=0.';
}

$location = is_array($geo['location'] ?? null) ? $geo['location'] : (is_array($geo) ? $geo : []);
$city = (string) ($location['city'] ?? '');
$region = (string) ($location['state'] ?? $location['region'] ?? '');
$country = (string) ($location['country'] ?? '');
$latitude = $location['latitude'] ?? $location['lat'] ?? null;
$longitude = $location['longitude'] ?? $location['lon'] ?? null;
$timezone = (string) ($location['timezone'] ?? '');
$company = $geo['company'] ?? null;
if (is_array($company)) {
    $company = $company['name'] ?? $company['org'] ?? '';
}
$asn = $geo['asn'] ?? null;
if (is_array($asn)) {
    $asn = $asn['descr'] ?? $asn['org'] ?? ($asn['asn'] ?? '');
}

$securityFlags = [
    'is_proxy' => 'Known proxy',
    'is_vpn' => 'VPN',
    'is_tor' => 'Tor exit node',
    'is_datacenter' => 'Datacenter / hosting',
    'is_abuser' => 'Abuse-listed network',
    'is_mobile' => 'Mobile network',
    'is_satellite' => 'Satellite network',
    'is_anycast' => 'Anycast network',
];
$hasSecurityFlags = false;
foreach (array_keys($securityFlags) as $key) {
    if (array_key_exists($key, $geo ?? [])) {
        $hasSecurityFlags = true;
        break;
    }
}

$procOpenAvailable = canUseProcOpen();
$isWindows = PHP_OS_FAMILY === 'Windows';
$isDarwin = PHP_OS_FAMILY === 'Darwin';
$pingBinary = findExecutable($isWindows ? ['ping.exe', 'ping'] : ['ping']);
$traceBinary = findExecutable($isWindows ? ['tracert.exe', 'tracert'] : ['traceroute', 'tracepath']);
$traceTool = $traceBinary !== null ? strtolower(basename($traceBinary)) : '';
$canRunTraceroute = $procOpenAvailable && $traceBinary !== null;

$pingResult = null;
$traceResult = null;
$openPorts = [];
$portScanAvailable = function_exists('stream_socket_client');
$probeNote = '';
if ($probeIp === '') {
    $probeNote = $probeTargetNote;
} else {
    if ($config['ping_enabled']) {
        if ($procOpenAvailable && $pingBinary !== null) {
            if ($isWindows) $pingCommand = [$pingBinary, '-n', '1', '-w', '2000', $probeIp];
            elseif ($isDarwin) $pingCommand = [$pingBinary, '-c', '1', '-W', '2000', $probeIp];
            else $pingCommand = [$pingBinary, '-c', '1', '-W', '2', $probeIp];
            $pingResult = runCommand($pingCommand, $config['command_timeout']);
        } else {
            $reason = !$procOpenAvailable ? 'PHP proc_open() is unavailable.' : 'ping executable not found.';
            $pingResult = ['output' => 'Unavailable: ' . $reason, 'timed_out' => false];
        }
    }

    if ($config['traceroute_enabled']) {
        if ($canRunTraceroute) {
            if ($isWindows) $traceCommand = [$traceBinary, '-d', '-h', '10', '-w', '1000', $probeIp];
            elseif ($traceTool === 'tracepath') $traceCommand = [$traceBinary, '-n', '-m', '10', $probeIp];
            else $traceCommand = [$traceBinary, '-n', '-m', '10', '-w', '1', '-q', '1', $probeIp];
            $traceResult = runCommand($traceCommand, $config['trace_timeout']);
        } else {
            $reason = !$procOpenAvailable ? 'PHP proc_open() is unavailable.' : 'traceroute / tracepath executable not found.';
            $traceResult = ['output' => 'Unavailable: ' . $reason, 'timed_out' => false];
        }
    }

    if ($config['port_scan_enabled'] && $portScanAvailable) {
        $openPorts = scanTcpPorts($probeIp, $ports, $config['connect_timeout']);
    }
}

$serverScheme = (!empty($_SERVER['HTTPS']) && strtolower((string) $_SERVER['HTTPS']) !== 'off') ? 'https' : 'http';
$agent = (string) ($_SERVER['HTTP_USER_AGENT'] ?? '');
$method = (string) ($_SERVER['REQUEST_METHOD'] ?? '');
$host = (string) ($_SERVER['HTTP_HOST'] ?? '');
$requestUri = (string) ($_SERVER['REQUEST_URI'] ?? '');
$requestPath = (string) (parse_url($requestUri, PHP_URL_PATH) ?: $requestUri);

?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Network Diagnostics</title>
<style>
:root{color-scheme:dark;--bg:#111820;--panel:#1a2530;--panel2:#202e3a;--line:#344452;--text:#e5edf3;--muted:#aab8c4;--accent:#8db8d5;--good:#9bd2ad;--warn:#e4c28a}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font:15px/1.55 system-ui,-apple-system,Segoe UI,Roboto,sans-serif}
main{width:min(1100px,calc(100% - 32px));margin:32px auto 56px}header{margin-bottom:22px}h1{font-size:1.8rem;margin:0 0 5px}h2{font-size:1.05rem;margin:0 0 14px}p{margin:5px 0;color:var(--muted)}
.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}.card{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:18px;min-width:0;margin-bottom:14px}
dl{display:grid;grid-template-columns:minmax(115px, .7fr) minmax(0,1.6fr);gap:8px 14px;margin:0}dt{color:var(--muted)}dd{margin:0;overflow-wrap:anywhere}
table{width:100%;border-collapse:collapse}th,td{text-align:left;padding:9px 8px;border-bottom:1px solid var(--line);vertical-align:top;overflow-wrap:anywhere}th{color:var(--muted);font-weight:600}tr:last-child td{border-bottom:0}
pre{white-space:pre-wrap;overflow-wrap:anywhere;background:#0d141b;border:1px solid var(--line);border-radius:8px;padding:12px;margin:8px 0 0;max-height:360px;overflow:auto;color:#d6e1e9;font:13px/1.5 ui-monospace,SFMono-Regular,Consolas,monospace}
.pill{display:inline-block;border:1px solid var(--line);border-radius:999px;padding:2px 9px;color:var(--muted);font-size:.82rem}.yes{color:var(--good)}.no{color:var(--warn)}.muted{color:var(--muted)}.wide{grid-column:1/-1}.small{font-size:.88rem}
@media(max-width:720px){main{width:min(100% - 20px,1100px);margin:18px auto 36px}.grid{grid-template-columns:1fr}.wide{grid-column:auto}dl{grid-template-columns:1fr;gap:2px}dd{margin-bottom:8px}h1{font-size:1.5rem}}
</style>
</head>
<body>
<main>
<header>
    <h1>Network Diagnostics</h1>
    <p>Server-side view of this request and connectivity to the resolved client IP.</p>
</header>

<div class="grid">
<section class="card">
    <h2>Ping</h2>
    <?php if ($probeTargetNote !== ''): ?><p class="small muted"><?= h($probeTargetNote) ?></p><?php endif; ?>
    <?php if ($pingResult !== null): ?>
        <?php if (!empty($pingResult['timed_out'])): ?><p class="no">Command timed out.</p><?php endif; ?>
        <pre><?= h($pingResult['output']) ?></pre>
    <?php else: ?><p><?= h($probeNote ?: 'Not run.') ?></p><?php endif; ?>
</section>

<section class="card">
    <h2>Traceroute</h2>
    <?php if ($traceResult !== null): ?>
        <?php if (!empty($traceResult['timed_out'])): ?><p class="no">Command timed out.</p><?php endif; ?>
        <pre><?= h($traceResult['output']) ?></pre>
    <?php else: ?><p><?= h($probeNote ?: 'Not run.') ?></p><?php endif; ?>
</section>

<section class="card wide">
    <h2>Request headers</h2>
    <table>
        <thead><tr><th style="width:28%">Header</th><th>Value</th></tr></thead>
        <tbody>
        <?php foreach ($headers as $name => $value):
            $sensitive = in_array(strtolower((string) $name), ['authorization', 'proxy-authorization', 'cookie', 'set-cookie', 'x-api-key', 'api-key', 'x-auth-token', 'x-access-token', 'x-csrf-token', 'x-xsrf-token', 'x-amz-security-token'], true);
        ?>
            <tr><td><?= h($name) ?></td><td><?= $sensitive ? '<span class="muted">[redacted]</span>' : h($value) ?></td></tr>
        <?php endforeach; ?>
        <?php if (!$headers): ?><tr><td colspan="2">No request headers available.</td></tr><?php endif; ?>
        </tbody>
    </table>
</section>

<section class="card">
    <h2>Client connection</h2>
    <dl>
        <dt>Resolved client IP</dt><dd><strong><?= h($clientIp ?: 'Unavailable') ?></strong> <?= $publicIp ? '<span class="pill yes">Public</span>' : '<span class="pill no">Not public</span>' ?></dd>
        <dt>Resolution source</dt><dd><?= h($clientIpSource) ?></dd>
        <dt>Server IP</dt><dd><?= h($serverIp ?: 'Unavailable') ?></dd>
        <?php if ($forwardedChain): ?><dt>X-Forwarded-For chain</dt><dd><?= h(implode(' → ', $forwardedChain)) ?></dd><?php endif; ?>
        <dt>Probe target</dt><dd><?= h($probeIp ?: 'Skipped') ?></dd>
        <dt>TCP peer / REMOTE_ADDR</dt><dd><?= h($remoteIp ?: 'Unavailable') ?></dd>
        <dt>Trusted proxy peer</dt><dd><?= isTrustedProxy($remoteIp, $trustedProxyCidrs) ? '<span class="yes">Yes</span>' : 'No' ?></dd>
        <dt>Request method</dt><dd><?= h($method) ?></dd>
        <dt>Host</dt><dd><?= h($host) ?></dd>
        <dt>Server-side scheme</dt><dd><?= h($serverScheme) ?></dd>
        <dt>Request path</dt><dd><?= h($requestPath) ?></dd>
    </dl>
</section>

<section class="card">
    <h2>Browser / user agent</h2>
    <dl>
        <dt>User-Agent</dt><dd><?= h($agent ?: 'Not supplied') ?></dd>
        <dt>Accept-Language</dt><dd><?= h(headerValue($headers, 'Accept-Language') ?: 'Not supplied') ?></dd>
        <dt>Referer</dt><dd><?= h(headerValue($headers, 'Referer') ?: 'Not supplied') ?></dd>
        <dt>Forwarded protocol</dt><dd><?= h(headerValue($headers, 'X-Forwarded-Proto') ?: 'Not supplied') ?></dd>
    </dl>
</section>

<section class="card">
    <h2>IP geolocation and network</h2>
    <?php if ($geo !== null): ?>
    <dl>
        <dt>Approximate location</dt><dd><?= h(implode(', ', array_filter([$city, $region, $country])) ?: 'Unknown') ?></dd>
        <dt>Coordinates</dt><dd><?= h(($latitude !== null && $longitude !== null) ? $latitude . ', ' . $longitude : 'Unknown') ?></dd>
        <dt>Timezone</dt><dd><?= h($timezone ?: 'Unknown') ?></dd>
        <dt>Company / ISP</dt><dd><?= h(is_string($company) ? $company : 'Unknown') ?></dd>
        <dt>ASN</dt><dd><?= h(is_string($asn) ? $asn : 'Unknown') ?></dd>
    </dl>
    <?php else: ?><p><?= h($geoError) ?></p><?php endif; ?>
    <p class="small muted">IP geolocation is approximate, not a physical-address lookup.</p>
</section>

<section class="card">
    <h2>Proxy / VPN indicators</h2>
    <?php if ($proxyHeaders): ?>
        <p class="no">Proxy-related headers present. Header presence alone does not prove a proxy; untrusted clients can spoof them.</p>
        <dl>
        <?php foreach ($proxyHeaders as $name => $value): ?>
            <dt><?= h($name) ?></dt><dd><?= h($value) ?></dd>
        <?php endforeach; ?>
        </dl>
    <?php else: ?><p>No common proxy-related headers detected.</p><?php endif; ?>
    <?php if ($hasSecurityFlags): ?>
        <table><tbody>
        <?php foreach ($securityFlags as $key => $label): if (!array_key_exists($key, $geo)) continue; ?>
            <tr><td><?= h($label) ?></td><td><?= !empty($geo[$key]) ? '<span class="no">Yes</span>' : '<span class="yes">No</span>' ?></td></tr>
        <?php endforeach; ?>
        </tbody></table>
    <?php else: ?>
        <p class="muted small">IP reputation flags were not returned. An ipapi.is API key is required for its VPN, proxy, Tor and hosting detection flags.</p>
    <?php endif; ?>
</section>

<section class="card">
    <h2>System command capability</h2>
    <dl>
        <dt>PHP version</dt><dd><?= h(PHP_VERSION) ?></dd>
        <dt>Operating system</dt><dd><?= h(PHP_OS_FAMILY) ?></dd>
        <dt>proc_open()</dt><dd><?= $procOpenAvailable ? '<span class="yes">Available</span>' : '<span class="no">Unavailable / disabled</span>' ?></dd>
        <dt>Ping executable</dt><dd><?= h($pingBinary ?: 'Not found') ?></dd>
        <dt>Traceroute executable</dt><dd><?= h($traceBinary ?: 'Not found') ?></dd>
        <dt>Can run system traceroute</dt><dd><?= $canRunTraceroute ? '<span class="yes">Yes</span>' : '<span class="no">No</span>' ?></dd>
    </dl>
    <p class="small muted">This script uses proc_open() with an argument array; exec() is not required.</p>
</section>

<section class="card wide">
    <h2>Common TCP ports</h2>
    <?php if (!$config['port_scan_enabled'] || !validIp($probeIp)): ?>
        <p><?= h($probeNote) ?></p>
    <?php elseif (!$portScanAvailable): ?>
        <p>Unavailable: PHP stream_socket_client() is disabled.</p>
    <?php else: ?>
        <p class="small muted">Target: <?= h($probeIp) ?>. Tested <?= count($ports) ?> predefined ports from this server. Only successful TCP connections are listed as open; filtered and unreachable ports are not distinguished.</p>
        <?php if ($openPorts): ?>
        <table><thead><tr><th>Port</th><th>Service</th><th>Status</th></tr></thead><tbody>
        <?php foreach ($openPorts as $port => $result): ?>
            <tr><td><?= h($port) ?>/tcp</td><td><?= h($result['label']) ?></td><td class="yes">Open</td></tr>
        <?php endforeach; ?>
        </tbody></table>
        <?php else: ?><p>No open ports detected in the tested list.</p><?php endif; ?>
    <?php endif; ?>
</section>
</div>

<p class="small muted">Diagnostics originate from the web server, not the visitor's device. Firewalls, NAT, hosting restrictions and ICMP filtering can affect results. When geolocation is enabled, the resolved IP is sent to ipapi.is for lookup.</p>
</main>
</body>
</html>

