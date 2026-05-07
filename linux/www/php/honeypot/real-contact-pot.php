<?php

session_start();

// ── Email config ───────────────────────────────────────────────────────────
define('MAIL_TO',      'you@yourdomain.com');
define('MAIL_FROM',    'noreply@yourdomain.com');
define('MAIL_SUBJECT', 'New contact form submission');

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

// ── Send email ─────────────────────────────────────────────────────────────
function sendEmail(string $name, string $email, string $message, string $ip): bool
{
    $name    = htmlspecialchars($name);
    $email   = htmlspecialchars($email);
    $message = htmlspecialchars($message);

    $body = "New contact form submission\n";
    $body .= "============================\n\n";
    $body .= "Name:    {$name}\n";
    $body .= "Email:   {$email}\n";
    $body .= "IP:      {$ip}\n";
    $body .= "Time:    " . date('Y-m-d H:i:s') . "\n\n";
    $body .= "Message:\n{$message}\n";

    $headers   = [];
    $headers[] = 'From: ' . MAIL_FROM;
    $headers[] = 'Reply-To: ' . $email;
    $headers[] = 'X-Mailer: PHP/' . phpversion();
    $headers[] = 'Content-Type: text/plain; charset=utf-8';

    return mail(MAIL_TO, MAIL_SUBJECT, $body, implode("\r\n", $headers));
}

// ── Already banned ─────────────────────────────────────────────────────────
if (in_array($ip, $blockedIPs, true)) {
    writeLog('WARNING', 'honeypot', $ip, 'already banned access attempt');
    http_response_code(403);
    header('Connection: close');
    exit('Access denied.');
}

// ── Handle POST ────────────────────────────────────────────────────────────
$error   = '';
$success = false;

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
        header('Connection: close');
        exit('Access denied.');
    }

    // CSRF — reject but do not block unless repeated
    if (!hash_equals($_SESSION['csrf_token'] ?? '', $csrfToken)) {
        $_SESSION['csrf_fails'] = ($_SESSION['csrf_fails'] ?? 0) + 1;
        writeLog('WARNING', 'honeypot', $ip, 'invalid csrf', ['attempts' => $_SESSION['csrf_fails']]);

        if ($_SESSION['csrf_fails'] >= 3) {
            blockIP($ip);
            http_response_code(403);
            header('Connection: close');
            exit('Access denied.');
        }

        $error = 'Form expired. Please try again.';
    } else {

        // Validate email format
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $error = 'Invalid email address.';
        } else {
            $_SESSION['csrf_fails'] = 0;

            $sent = sendEmail($name, $email, $message, $ip);

            if ($sent) {
                writeLog('INFO', 'honeypot', $ip, 'success', [
                    'name'    => $name,
                    'email'   => $email,
                    'elapsed' => $elapsed,
                ]);
                $success = true;
            } else {
                writeLog('ERROR', 'honeypot', $ip, 'mail() failed', [
                    'name'  => $name,
                    'email' => $email,
                ]);
                $error = 'Failed to send message. Please try again.';
            }
        }
    }
}

$_SESSION['csrf_token'] = bin2hex(random_bytes(32));

?>
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><title>Contact</title></head>
<body id="denny.wordpress.com">
<?php if ($success): ?>

    <p>Message sent. Thank you!</p>

<?php else: ?>

    <?php if ($error): ?>
        <p style="color:red;"><?= htmlspecialchars($error) ?></p>
    <?php endif; ?>

    <form method="POST">
        <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_token']) ?>">
        <input type="hidden" name="elapsed" id="elapsed" value="0">

        <!-- Honeypot — hidden from humans, bots fill it -->
        <div style="display:none;">
            <input type="text" name="website" tabindex="-1" autocomplete="off">
        </div>

        <label>Name<br><input type="text" name="name" required value="<?= htmlspecialchars($_POST['name'] ?? '') ?>"></label><br><br>
        <label>Email<br><input type="email" name="email" required value="<?= htmlspecialchars($_POST['email'] ?? '') ?>"></label><br><br>
        <label>Message<br><textarea name="message" required><?= htmlspecialchars($_POST['message'] ?? '') ?></textarea></label><br><br>

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
