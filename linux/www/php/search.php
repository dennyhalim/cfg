<?php
/**
 * search.php — 404 handler + search page (Serper-powered)
 *
 * DEPLOYMENT
 * ----------
 * Apache (.htaccess in your document root):
 *   ErrorDocument 404 /search.php
 *
 * Nginx (in your server block):
 *   error_page 404 /search.php;
 *
 * Both preserve the original requested URL in the browser bar while
 * routing the request to this script internally.
 */

// ============================================================
// CONFIG — edit these
// ============================================================

// Get a key at https://serper.dev
// Better than hardcoding: set it as a real environment variable
// (e.g. in your Apache vhost with SetEnv, or a .env loader) and read
// it with getenv('SERPER_API_KEY') instead of the literal string below.
const SERPER_API_KEY = 'YOUR_API_KEYS';

// "unrestricted" -> searches the whole web, no site: filter
// "host"         -> restrict to the current request's Host header
// "domain"       -> restrict to a fixed domain below, regardless of host
const SEARCH_SCOPE = 'host';

// Only used when SEARCH_SCOPE = 'domain'
const FIXED_DOMAIN = 'example.com';

// Simple file-based cache to avoid burning API quota on repeat queries.
// Set to null to disable caching.
const CACHE_DIR = __DIR__ . '/.search-cache';
const CACHE_TTL_SECONDS = 3600; // 1 hour

// ============================================================
// Detect whether we were invoked as the 404 error handler, or as a
// normal, direct page load (e.g. a "Search" link in your nav).
//
// Apache: when ErrorDocument triggers an internal redirect to this
// script, it sets REDIRECT_STATUS to "404". Note that REDIRECT_STATUS
// can also be set by OTHER internal redirects (e.g. mod_rewrite rules
// for pretty URLs) with a value like "200" — so it's important to
// check the actual value, not just whether it's set.
//
// Nginx: `error_page 404 /search.php;` does an internal redirect too,
// but doesn't expose a reliable equivalent flag by default. The
// simplest fix is to pass one explicitly:
//   error_page 404 /search.php?via_404=1;
// which is checked below as a fallback.
// ============================================================
$isErrorPage = (isset($_SERVER['REDIRECT_STATUS']) && $_SERVER['REDIRECT_STATUS'] === '404')
    || (isset($_GET['via_404']) && $_GET['via_404'] === '1');

// Only send a 404 status when we're actually handling a broken link —
// a normal direct visit to this page should respond 200 like any other page.
if ($isErrorPage) {
    http_response_code(404);
}

// ============================================================
// Figure out what the user was actually looking for
// ============================================================

// Apache's ErrorDocument sets REQUEST_URI to the original request path.
// REDIRECT_URL is a fallback some configs expose instead.
$requestUri = $_SERVER['REQUEST_URI'] ?? ($_SERVER['REDIRECT_URL'] ?? '/');
$hostname   = $_SERVER['HTTP_HOST'] ?? 'localhost';

$parts    = parse_url($requestUri);
$path     = $parts['path'] ?? '/';
$queryStr = $parts['query'] ?? '';

function pathToKeywords(string $path): string {
    $s = preg_replace('/\.[a-z0-9]+$/i', '', $path); // strip extension
    $s = trim($s, '/');
    $s = preg_replace('/[-_\/]+/', ' ', $s);
    return trim($s);
}

function queryStringToKeywords(string $qs): string {
    if ($qs === '') return '';
    parse_str($qs, $parsed);
    $words = [];
    foreach ($parsed as $k => $v) {
        $words[] = $k;
        if (is_string($v)) $words[] = $v;
    }
    return implode(' ', $words);
}

// Only auto-derive a query from the URL path when we're actually
// handling a 404 — on a normal direct visit, the path is just
// "/search.php" and isn't a meaningful search term.
$autoQuery = $isErrorPage
    ? trim(pathToKeywords($path) . ' ' . queryStringToKeywords($queryStr))
    : '';

// If the user submitted the search form, that overrides the auto-derived query
$userQuery = isset($_GET['q']) ? trim($_GET['q']) : $autoQuery;

// ============================================================
// Build the Serper query string according to SEARCH_SCOPE
// ============================================================
function buildScopedQuery(string $text): string {
    $text = trim($text);
    switch (SEARCH_SCOPE) {
        case 'host':
            return trim('site:' . $GLOBALS['hostname'] . ' ' . $text);
        case 'domain':
            return trim('site:' . FIXED_DOMAIN . ' ' . $text);
        default:
            return $text;
    }
}

// ============================================================
// Call Serper (with a simple file cache)
// ============================================================
function serperSearch(string $q): array {
    $cacheKey  = CACHE_DIR ? CACHE_DIR . '/' . md5($q) . '.json' : null;

    if ($cacheKey && is_file($cacheKey) && (time() - filemtime($cacheKey) < CACHE_TTL_SECONDS)) {
        $cached = json_decode(file_get_contents($cacheKey), true);
        if (is_array($cached)) return $cached;
    }

    $ch = curl_init('https://google.serper.dev/search');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => [
            'X-API-KEY: ' . SERPER_API_KEY,
            'Content-Type: application/json',
        ],
        CURLOPT_POSTFIELDS => json_encode(['q' => $q]),
        CURLOPT_TIMEOUT => 8,
    ]);
    $response = curl_exec($ch);
    $status   = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error    = curl_error($ch);
    curl_close($ch);

    if ($response === false || $status !== 200) {
        return ['error' => $error ?: "Serper request failed ({$status})"];
    }

    $data = json_decode($response, true);
    if (!is_array($data)) {
        return ['error' => 'Invalid response from Serper'];
    }

    if ($cacheKey) {
        if (!is_dir(CACHE_DIR)) @mkdir(CACHE_DIR, 0755, true);
        @file_put_contents($cacheKey, json_encode($data));
    }

    return $data;
}

$results = [];
$searchError = null;

if ($userQuery !== '') {
    $scopedQuery = buildScopedQuery($userQuery);
    $data = serperSearch($scopedQuery);
    if (isset($data['error'])) {
        $searchError = $data['error'];
    } else {
        $results = $data['organic'] ?? [];
    }
}

function h(string $s): string {
    return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
}
?>
<!doctype html>
<html lang="en" data-theme="light">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light">
<title><?= $isErrorPage ? 'Page Not Found' : 'Search' ?></title>
<link id="pico-css" rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css">
<script>
// Apply any saved theme immediately, before body renders, to avoid a
// flash of the default theme.
(function () {
    try {
        var saved = JSON.parse(localStorage.getItem('picoTheme'));
        if (!saved || !saved.color || !saved.mode) return;
        var link = document.getElementById('pico-css');
        link.href = saved.color === 'default'
            ? 'https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css'
            : 'https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.' + saved.color + '.min.css';
        document.documentElement.setAttribute('data-theme', saved.mode);
    } catch (e) {}
})();
</script>
<style>
:root { color-scheme: light; }
main { max-width: 760px; margin: 2rem auto; }
#theme-bar {
    display: flex;
    justify-content: flex-end;
    margin-bottom: .5rem;
}
#theme-select { width: auto; margin: 0; }
#search-form {
    display: flex;
    gap: .5rem;
    align-items: center;
    margin-bottom: 1.5rem;
}
#search-form input { flex: 1; width: auto; margin: 0; }
#search-form button { flex: 0 0 auto; width: auto; margin: 0; }

.result {
    padding-block: .9rem;
    border-bottom: 1px solid var(--pico-muted-border-color);
}
.result:last-child { border-bottom: none; }
.result-url {
    display: block;
    font-size: .8rem;
    color: var(--pico-muted-color);
    margin-bottom: .15rem;
}
.result-title { font-size: 1.05rem; text-decoration: none; }
.result-snippet { margin: .3rem 0 0; color: var(--pico-color); }
#status { color: var(--pico-muted-color); }
</style>
</head>
<body>
<main class="container">
<div id="theme-bar">
    <select id="theme-select" aria-label="Theme"></select>
</div>

<h1><?= $isErrorPage ? 'Page not found' : 'Search' ?></h1>
<p>
<?php if ($isErrorPage): ?>
    The page doesn't exist. Here's what we found searching for it instead.
<?php else: ?>
    Search this site.
<?php endif; ?>
</p>

<form id="search-form" method="get">
    <input type="search" name="q" value="<?= h($userQuery) ?>" placeholder="Search this site..." autocomplete="off">
    <button type="submit">Search</button>
</form>

<?php if ($searchError): ?>
    <p id="status">Search failed: <?= h($searchError) ?></p>
<?php elseif ($userQuery === ''): ?>
    <p id="status"></p>
<?php elseif (empty($results)): ?>
    <p id="status">No results found.</p>
<?php else: ?>
    <p id="status"><?= count($results) ?> result<?= count($results) === 1 ? '' : 's' ?> for "<?= h($userQuery) ?>"</p>
    <div id="results">
        <?php foreach ($results as $r): ?>
            <div class="result">
                <span class="result-url"><?= h($r['link'] ?? '') ?></span>
                <a class="result-title" href="<?= h($r['link'] ?? '#') ?>" target="_blank" rel="noopener">
                    <?= h($r['title'] ?? ($r['link'] ?? 'Untitled')) ?>
                </a>
                <p class="result-snippet"><?= h($r['snippet'] ?? '') ?></p>
            </div>
        <?php endforeach; ?>
    </div>
<?php endif; ?>

</main>

<script>
(() => {
    // All Pico v2 color-theme builds, per https://picocss.com/docs/colors
    const COLORS = [
        'default', 'red', 'pink', 'fuchsia', 'purple', 'violet', 'indigo',
        'blue', 'azure', 'cyan', 'jade', 'green', 'lime', 'yellow', 'amber',
        'pumpkin', 'orange', 'sand', 'grey', 'zinc', 'slate'
    ];
    const MODES = ['light', 'dark'];

    const select = document.getElementById('theme-select');
    const link = document.getElementById('pico-css');

    // Build the 40 (color x mode) options
    for (const color of COLORS) {
        for (const mode of MODES) {
            const opt = document.createElement('option');
            opt.value = color + '|' + mode;
            const label = color === 'default' ? 'Default' : color[0].toUpperCase() + color.slice(1);
            opt.textContent = `${label} — ${mode === 'light' ? 'Light' : 'Dark'}`;
            select.appendChild(opt);
        }
    }

    function hrefFor(color) {
        return color === 'default'
            ? 'https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css'
            : `https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.${color}.min.css`;
    }

    function applyTheme(color, mode, persist) {
        link.href = hrefFor(color);
        document.documentElement.setAttribute('data-theme', mode);
        select.value = color + '|' + mode;
        if (persist) {
            localStorage.setItem('picoTheme', JSON.stringify({ color, mode }));
        }
    }

    // Reflect whatever was already applied by the head script (or default)
    let saved = null;
    try { saved = JSON.parse(localStorage.getItem('picoTheme')); } catch (e) {}
    applyTheme(saved?.color || 'default', saved?.mode || 'light', false);

    select.addEventListener('change', () => {
        const [color, mode] = select.value.split('|');
        applyTheme(color, mode, true);
    });
})();
</script>
<script>window.goatcounter={path:function(p){return location.host+p}}</script>
<script data-goatcounter="https://mypolaris.goatcounter.com/count" async src="//gc.zgo.at/count.js"></script>
<p><small><a href="https://mypolaris.com">Free Polaris Network Tools</a></small></p>
</body>
</html>
