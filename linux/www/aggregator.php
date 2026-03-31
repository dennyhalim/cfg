<?php
/**
 * Simple RSS Aggregator — Security-hardened
 * - Reads an OPML file
 * - Displays all feed content
 * - Outputs an aggregated RSS feed
 *
 * Usage:
 *   Browser view : aggregator.php
 *   RSS output   : aggregator.php?output=rss
 *
 * Requires: PHP 7.4+, allow_url_fopen = On
 * Optional: composer require ezyang/htmlpurifier  (richer body sanitization)
 */

// ─── CONFIG ──────────────────────────────────────────────────────────────────
define('OPML_FILE',          'feeds.opml');
define('CACHE_DIR',          '../cache/');          // outside web root
define('CACHE_TTL',          1800);                 // seconds (30 min)
define('MAX_ITEMS',          10);                   // max items per feed
define('MAX_FEEDS',          50);                   // DoS guard: max feeds in OPML
define('FEED_TITLE_DEFAULT', 'My Aggregator');
define('SITE_URL',           'https://example.com/aggregator.php'); // *** hardcode your URL ***
define('FEED_DESC',          'Aggregated RSS feed');
define('ERROR_LOG',          '../cache/aggregator-errors.log');
// ─────────────────────────────────────────────────────────────────────────────

// ── [Fix #7] Security headers — sent on every response ───────────────────────
header('X-Frame-Options: SAMEORIGIN');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: no-referrer');
header("Content-Security-Policy: default-src 'self'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; img-src * data:; frame-src 'none'");

// ── Helpers ───────────────────────────────────────────────────────────────────

// [Fix #9] Proper error logging — replaces @ suppression
function log_error(string $msg): void {
    error_log(date('Y-m-d H:i:s') . ' ' . $msg . PHP_EOL, 3, ERROR_LOG);
}

// [Fix #3] Validate URL is a public http/https address — blocks SSRF
function is_safe_url(string $url): bool {
    if (!preg_match('#^https?://#i', $url)) return false;
    $host = parse_url($url, PHP_URL_HOST);
    if (!$host) return false;
    $ip = gethostbyname($host);
    // Block private/loopback/reserved IP ranges
    return filter_var($ip, FILTER_VALIDATE_IP,
        FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false;
}

// [Fix #4] Return URL only if http/https — blocks javascript: hrefs
function safe_url(string $url): string {
    return preg_match('#^https?://#i', $url) ? $url : '#';
}

// [Fix #1] Sanitize feed HTML — strip dangerous tags/attributes
// Automatically uses HTMLPurifier if installed via Composer; falls back to strip_tags
function sanitize_html(string $html): string {
    if (class_exists('HTMLPurifier')) {
        static $purifier = null;
        if (!$purifier) {
            $config = HTMLPurifier_Config::createDefault();
            $config->set('HTML.Allowed',
                'p,br,b,strong,i,em,u,a[href|title],ul,ol,li,blockquote,pre,code,h2,h3,h4,img[src|alt|width|height]');
            $config->set('URI.AllowedSchemes', ['http' => true, 'https' => true]);
            $config->set('HTML.TargetBlank', true);
            $purifier = new HTMLPurifier($config);
        }
        return $purifier->purify($html);
    }
    // Fallback: allowlist of safe tags only
    return strip_tags($html,
        '<p><br><b><strong><i><em><u><a><ul><ol><li><blockquote><pre><code><h2><h3><h4><img>');
}

// [Fix #2] Load XML with XXE and external network access disabled
function safe_simplexml(string $path): ?SimpleXMLElement {
    if (PHP_VERSION_ID < 80000) {
        libxml_disable_entity_loader(true); // PHP 7.x
    }
    libxml_use_internal_errors(true);
    $xml = simplexml_load_file($path, 'SimpleXMLElement',
        LIBXML_NONET | LIBXML_NOERROR | LIBXML_NOWARNING);
    libxml_clear_errors();
    return $xml ?: null;
}

// [Fix #5, #8] Read OPML — caps feed count, validates URLs
function read_opml(string $file): array {
    if (!file_exists($file)) die('OPML file not found.');  // no path disclosure
    $xml = safe_simplexml($file);
    if (!$xml) die('Failed to parse OPML file.');

    $title = trim((string)($xml->head->title ?? ''));
    if ($title) define('FEED_TITLE', $title);

    $feeds = [];
    foreach ($xml->xpath('//outline[@type="rss"]') as $o) {
        if (count($feeds) >= MAX_FEEDS) break; // [Fix #8] DoS guard

        $url     = (string)($o['xmlUrl']  ?? '');
        $htmlUrl = (string)($o['htmlUrl'] ?? '');

        if (!is_safe_url($url)) {           // [Fix #3] skip unsafe URLs
            log_error("Skipped unsafe feed URL: $url");
            continue;
        }

        $feeds[] = [
            'title'   => (string)($o['title'] ?? $o['text'] ?? 'Untitled'),
            'url'     => $url,
            'htmlUrl' => is_safe_url($htmlUrl) ? $htmlUrl : '',
        ];
    }
    return $feeds;
}

// [Fix #6] Protect cache directory — writes .htaccess denial
function ensure_cache_dir(): void {
    if (!is_dir(CACHE_DIR)) mkdir(CACHE_DIR, 0750, true);
    $htaccess = CACHE_DIR . '.htaccess';
    if (!file_exists($htaccess)) {
        file_put_contents($htaccess, "Require all denied\nDeny from all\n");
    }
}

function fetch_feed(string $url): ?SimpleXMLElement {
    ensure_cache_dir();
    $key   = CACHE_DIR . md5($url) . '.xml';
    $fresh = file_exists($key) && (time() - filemtime($key) < CACHE_TTL);

    if (!$fresh) {
        $ctx = stream_context_create(['http' => [
            'timeout'          => 8,
            'follow_location'  => true,
            'max_redirects'    => 3,         // limit redirect chain
            'user_agent'       => 'SimpleAggregator/1.0',
            'protocol_version' => '1.1',
        ]]);
        // [Fix #9] Explicit error handling — no @ suppression
        $raw = file_get_contents($url, false, $ctx);
        if ($raw === false) {
            log_error("Failed to fetch feed: $url");
            return null;
        }
        file_put_contents($key, $raw);
    }

    return safe_simplexml($key); // [Fix #2]
}

function parse_items(SimpleXMLElement $xml, string $source): array {
    $items = [];
    $nodes = $xml->channel->item ?? $xml->entry ?? [];  // RSS 2.0 + Atom

    foreach ($nodes as $node) {
        $link = isset($node->link['href'])
            ? (string)$node->link['href']
            : (string)$node->link;

        $ns   = $node->children('content', true);
        $body = (string)($ns->encoded ?? $node->description ?? $node->summary ?? '');

        $date = (string)($node->pubDate ?? $node->updated ?? $node->published ?? '');

        $items[] = [
            'title'  => html_entity_decode(strip_tags((string)$node->title), ENT_QUOTES, 'UTF-8'),
            'link'   => safe_url($link),         // [Fix #4] block javascript: hrefs
            'body'   => sanitize_html($body),    // [Fix #1] sanitize body HTML
            'date'   => $date ? strtotime($date) : 0,
            'source' => $source,
        ];
    }
    return array_slice($items, 0, MAX_ITEMS);
}

function collect_all(array $feeds): array {
    $all = [];
    foreach ($feeds as $feed) {
        $xml = fetch_feed($feed['url']);
        if (!$xml) continue;
        $all = array_merge($all, parse_items($xml, $feed['title']));
    }
    usort($all, fn($a, $b) => $b['date'] - $a['date']);
    return $all;
}

// ── Output modes ─────────────────────────────────────────────────────────────

function output_rss(array $items): void {
    header('Content-Type: application/rss+xml; charset=utf-8');
    echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    echo '<rss version="2.0"><channel>';
    echo '<title>'       . htmlspecialchars(FEED_TITLE) . '</title>';
    echo '<link>'        . htmlspecialchars(SITE_URL)   . '</link>'; // [Fix #5]
    echo '<description>' . htmlspecialchars(FEED_DESC)  . '</description>';

    foreach ($items as $item) {
        $pub = $item['date'] ? date(DATE_RSS, $item['date']) : date(DATE_RSS);
        echo '<item>';
        echo '<title>'       . htmlspecialchars($item['title'])            . '</title>';
        echo '<link>'        . htmlspecialchars($item['link'])             . '</link>';
        echo '<description>' . htmlspecialchars(strip_tags($item['body'])) . '</description>';
        echo '<category>'    . htmlspecialchars($item['source'])           . '</category>';
        echo '<pubDate>'     . $pub                                        . '</pubDate>';
        echo '<guid isPermaLink="true">' . htmlspecialchars($item['link']) . '</guid>';
        echo '</item>';
    }
    echo '</channel></rss>';
}

function output_html(array $items, array $feeds): void {
    $rss_url = htmlspecialchars(SITE_URL . '?output=rss'); // [Fix #5]
?><!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= htmlspecialchars(FEED_TITLE) ?></title>
<link rel="alternate" type="application/rss+xml" title="<?= htmlspecialchars(FEED_TITLE) ?>" href="<?= $rss_url ?>">
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body   { font-family: system-ui, sans-serif; background: #f5f5f5; color: #222; line-height: 1.6; }
  header { background: #1a1a2e; color: #eee; padding: 1rem 2rem; display: flex; align-items: center; gap: 1rem; }
  header h1  { font-size: 1.3rem; font-weight: 600; }
  header a   { color: #f0a500; font-size: .85rem; margin-left: auto; text-decoration: none; }
  header a:hover { text-decoration: underline; }
  .layout    { display: flex; width: 100%; margin: 1.5rem auto; gap: 1.5rem; padding: 0 1.5rem; }
  aside      { width: 200px; flex-shrink: 0; }
  aside h2   { font-size: .8rem; text-transform: uppercase; letter-spacing: .06em; color: #888; margin-bottom: .5rem; }
  aside ul   { list-style: none; }
  aside li   { font-size: .875rem; padding: .3rem 0; border-bottom: 1px solid #e5e5e5; }
  aside li a { color: #1a1a2e; text-decoration: none; }
  aside li a:hover { color: #e63946; text-decoration: underline; }
  main       { flex: 1; min-width: 0; overflow: hidden; }
  .card      { background: #fff; border-radius: 8px; padding: 1.1rem 1.3rem; margin-bottom: 1rem;
               box-shadow: 0 1px 3px rgba(0,0,0,.07); overflow: hidden; word-break: break-word; }
  .card h2   { font-size: 1rem; margin-bottom: .3rem; overflow-wrap: break-word; }
  .card h2 a { color: #1a1a2e; text-decoration: none; }
  .card h2 a:hover { text-decoration: underline; color: #e63946; }
  .meta      { font-size: .78rem; color: #888; margin-bottom: .6rem; }
  .meta span { background: #eef; color: #446; border-radius: 4px; padding: 1px 6px; margin-right: 4px; }
  .body      { font-size: .88rem; color: #444; max-height: 5rem; overflow: hidden; position: relative;
               -webkit-mask-image: linear-gradient(to bottom, black 60%, transparent 100%);
                        mask-image: linear-gradient(to bottom, black 60%, transparent 100%);
               transition: max-height .3s ease; }
  .body.expanded { max-height: none; -webkit-mask-image: none; mask-image: none; }
  .body img  { max-width: 100%; height: auto; display: block; }
  .body *    { max-width: 100%; }
  .toggle-btn { margin-top: .5rem; background: none; border: none; cursor: pointer;
                font-size: .78rem; color: #446; padding: 0; }
  .toggle-btn:hover { text-decoration: underline; color: #e63946; }
  @media (max-width: 640px) { .layout { flex-direction: column; } aside { width: 100%; } }
</style>
</head>
<body>
<header>
  <h1>📰 <?= htmlspecialchars(FEED_TITLE) ?></h1>
  <a href="<?= $rss_url ?>">🔗 RSS Feed</a>
</header>

<div class="layout">
  <aside>
    <h2>Sources (<?= count($feeds) ?>)</h2>
    <ul>
    <?php foreach ($feeds as $f): ?>
      <li>
        <?php if ($f['htmlUrl']): ?>
          <a href="<?= htmlspecialchars($f['htmlUrl']) ?>" target="_blank" rel="noopener noreferrer">
            <?= htmlspecialchars($f['title']) ?>
          </a>
        <?php else: ?>
          <?= htmlspecialchars($f['title']) ?>
        <?php endif; ?>
      </li>
    <?php endforeach; ?>
    </ul>
  </aside>

  <main>
  <?php if (!$items): ?>
    <p>No items found. Check your OPML file or network access.</p>
  <?php endif; ?>
  <?php foreach ($items as $item): ?>
    <article class="card">
      <h2><a href="<?= htmlspecialchars($item['link']) ?>" target="_blank" rel="noopener noreferrer">
        <?= htmlspecialchars($item['title']) ?>
      </a></h2>
      <div class="meta">
        <span><?= htmlspecialchars($item['source']) ?></span>
        <?= $item['date'] ? date('M j, Y · H:i', $item['date']) : '' ?>
      </div>
      <div class="body"><?= $item['body'] ?></div>
      <button class="toggle-btn" onclick="toggleBody(this)">▼ Read more</button>
    </article>
  <?php endforeach; ?>
<script>
function toggleBody(btn) {
  const body = btn.previousElementSibling;
  const expanded = body.classList.toggle('expanded');
  btn.textContent = expanded ? '▲ Show less' : '▼ Read more';
}
document.querySelectorAll('.card').forEach(card => {
  const body = card.querySelector('.body');
  const btn  = card.querySelector('.toggle-btn');
  if (body.scrollHeight <= body.clientHeight + 2) btn.style.display = 'none';
});
</script>
  </main>
</div>
</body>
</html>
<?php
}

// ── Main ─────────────────────────────────────────────────────────────────────

$feeds = read_opml(OPML_FILE);
if (!defined('FEED_TITLE')) define('FEED_TITLE', FEED_TITLE_DEFAULT);
$items = collect_all($feeds);

if (($_GET['output'] ?? '') === 'rss') {
    output_rss($items);
} else {
    output_html($items, $feeds);
}
