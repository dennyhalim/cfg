<?php

session_start();

$blocked_file  = 'blocked_ips.txt';
$log_file      = 'honeypot_log.txt';
$htaccess_file = '.htaccess';
$nginx_file    = 'blocked_ips.nginx.conf';

$blockedIPs = file_exists($blocked_file)
    ? array_filter(array_map('trim', file($blocked_file)))
    : [];

$ip = $_SERVER['REMOTE_ADDR'] ?? '';

// ── Logging ────────────────────────────────────────────────────────────────
function writeLog(string $level, string $tag, string $ip, string $reason, array $extra = []): void
{
    global $log_file;

    $ua      = $_SERVER['HTTP_USER_AGENT'] ?? '-';
    $uri     = $_SERVER['REQUEST_URI']     ?? '-';
    $method  = $_SERVER['REQUEST_METHOD']  ?? '-';
    $referer = $_SERVER['HTTP_REFERER']    ?? '-';

    $extraStr = '';
    foreach ($extra as $key => $value) {
        $extraStr .= " {$key}=\"{$value}\"";
    }

    $log = sprintf(
        "[%s] [%s] [%s] ip=%s reason=\"%s\" method=%s uri=\"%s\" referer=\"%s\" ua=\"%s\"%s\n",
        date('Y-m-d H:i:s'),
        $level,
        $tag,
        $ip,
        $reason,
        $method,
        $uri,
        $referer,
        $ua,
        $extraStr
    );

    file_put_contents($log_file, $log, FILE_APPEND | LOCK_EX);
}

// ── Block IP ───────────────────────────────────────────────────────────────
function blockIP(string $ip): void
{
    global $blocked_file, $htaccess_file, $nginx_file;

    file_put_contents($blocked_file, $ip . PHP_EOL, FILE_APPEND | LOCK_EX);

    $htaccess = file_exists($htaccess_file) ? file_get_contents($htaccess_file) : '';
    if (!str_contains($htaccess, $ip)) {
        file_put_contents($htaccess_file, $htaccess . "\nDeny from {$ip}\n", LOCK_EX);
    }

    $nginxContent = file_exists($nginx_file) ? file_get_contents($nginx_file) : '';
    if (!str_contains($nginxContent, $ip)) {
        file_put_contents($nginx_file, $nginxContent . "deny {$ip};\n", LOCK_EX);
    }
}

// ── Already banned ─────────────────────────────────────────────────────────
if (in_array($ip, $blockedIPs, true)) {
    writeLog('WARNING', 'honeypot', $ip, 'already banned access attempt');
    http_response_code(403);
    sleep(9);
    header('Connection: close');
    exit('Access denied.');
}

// ── Handle POST ────────────────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $honeypot  = $_POST['website']         ?? '';
    $name      = trim($_POST['name']       ?? '');
    $email     = trim($_POST['email']      ?? '');
    $message   = trim($_POST['message']    ?? '');
    $csrfToken = $_POST['csrf_token']      ?? '';
    $elapsed   = (int)($_POST['elapsed']   ?? 0);

    $triggered = false;
    $reason    = '';

    // Definite bots — block
    if (!empty($honeypot)) {
        $triggered = true;
        $reason    = 'honeypot filled';
    } elseif ($elapsed < 3000) {
        $triggered = true;
        $reason    = 'submitted too fast';
    } elseif (empty($name) || empty($email) || empty($message)) {
        $triggered = true;
        $reason    = 'empty fields';
    }

    if ($triggered) {
        writeLog('WARNING', 'honeypot', $ip, $reason);
        blockIP($ip);
        http_response_code(403);
        sleep(9);
        header('Connection: close');
        exit('Access denied.');
    }

    // CSRF — log and reject but do not block (may be expired session)
    if (!hash_equals($_SESSION['csrf_token'] ?? '', $csrfToken)) {
        $_SESSION['csrf_fails'] = ($_SESSION['csrf_fails'] ?? 0) + 1;
        writeLog('WARNING', 'honeypot', $ip, 'invalid csrf', ['attempts' => $_SESSION['csrf_fails']]);

        if ($_SESSION['csrf_fails'] >= 3) {
            blockIP($ip);
            http_response_code(403);
            header('Connection: close');
            exit('Access denied.');
        }

        http_response_code(403);
        exit('Form expired. Please try again.');
    }

    // Reset CSRF fail counter on success
    $_SESSION['csrf_fails'] = 0;

    // Successful submission
    writeLog('INFO', 'honeypot', $ip, 'success', [
        'name'    => $name,
        'email'   => $email,
        'elapsed' => $elapsed,
    ]);

    $success = true;
}

$_SESSION['csrf_token'] = bin2hex(random_bytes(32));

?>
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Contact</title></head>
<body id="denny.wordpress.com">
<?php if (!empty($success)): ?>
    <p>Message sent. Thank you!</p>
<?php else: ?>

<form method="POST">
    <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_token']) ?>">
    <input type="hidden" name="elapsed" id="elapsed" value="0">

    <!-- Honeypot — hidden from humans, bots fill it -->
    <div style="display:none;">
        <input type="text" name="website" tabindex="-1" autocomplete="off">
    </div>

    <label>Name<br><input type="text" name="name" required></label><br><br>
    <label>Email<br><input type="email" name="email" required></label><br><br>
    <label>Message<br><textarea name="message" required></textarea></label><br><br>

    <button type="submit">Send</button>
</form>

<script>
    const start = Date.now();
    document.querySelector('form').addEventListener('submit', function () {
        document.getElementById('elapsed').value = Date.now() - start;
    });
</script>

<?php endif; ?>

</body>
</html>
