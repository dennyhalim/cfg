<?php
/**
 * Simple RSS Aggregator — Category edition
 * - Reads an OPML file (category groups supported)
 * - One page per category: aggregator.php?cat=tech
 * - Per-category RSS feed: aggregator.php?cat=tech&output=rss
 * - Aggregated RSS (all): aggregator.php?output=rss
 *
 * Requires: PHP 7.4+, allow_url_fopen = On
 * Optional: composer require ezyang/htmlpurifier
 */

// ─── CONFIG ──────────────────────────────────────────────────────────────────
define('OPML_FILE',          'feeds.opml');
define('CACHE_DIR',          '../cache/');
define('CACHE_TTL',          1800);         // seconds (30 min)
define('MAX_ITEMS',          10);           // max items per feed
define('MAX_FEEDS',          50);           // DoS guard
define('FEED_TITLE_DEFAULT', 'RSS feed aggregator');
define('FEED_DESC',          'denny.wordpress.com');
define('ERROR_LOG',          '../cache/aggregator-errors.log');

$_scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$_host   = $_SERVER['SERVER_NAME'] ?? 'localhost';
$_path   = strtok($_SERVER['REQUEST_URI'] ?? '/', '?');
define('SITE_URL', $_scheme . '://' . $_host . $_path);
unset($_scheme, $_host, $_path);
// ─────────────────────────────────────────────────────────────────────────────

// ── Security headers ──────────────────────────────────────────────────────────
header('X-Frame-Options: SAMEORIGIN');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: no-referrer');
header("Content-Security-Policy: default-src 'self'; style-src 'unsafe-inline'; script-src 'unsafe-inline'; img-src * data:; frame-src 'none'");

// ── Helpers ───────────────────────────────────────────────────────────────────

function log_error(string $msg): void {
    if (file_exists(ERROR_LOG) && filesize(ERROR_LOG) > 1 * 1024 * 1024) return;
    error_log(date('Y-m-d H:i:s') . ' ' . $msg . PHP_EOL, 3, ERROR_LOG);
}

// Convert a category title to a URL-safe slug
function slugify(string $text): string {
    $text = strtolower(trim($text));
    $text = preg_replace('/[^a-z0-9]+/', '-', $text) ?? $text;
    return trim($text, '-') ?: 'uncategorized';
}

function is_safe_url(string $url): bool {
    if (!preg_match('#^https?://#i', $url)) return false;
    $host = parse_url($url, PHP_URL_HOST);
    if (!is_string($host) || $host === '') return false;
    if (filter_var($host, FILTER_VALIDATE_IP) !== false) {
        return filter_var($host, FILTER_VALIDATE_IP,
            FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false;
    }
    $ip = gethostbyname($host);
    if ($ip === $host) return false;
    return filter_var($ip, FILTER_VALIDATE_IP,
        FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false;
}

function safe_url(string $url): string {
    return preg_match('#^https?://#i', $url) ? $url : '#';
}

/**
 * @psalm-suppress UndefinedClass -- HTMLPurifier is an optional dependency
 */
function sanitize_html(string $html): string {
    if (class_exists('HTMLPurifier')) {
        /** @var \HTMLPurifier|null $purifier */
        static $purifier = null;
        if ($purifier === null) {
            $config = HTMLPurifier_Config::createDefault();
            $config->set('HTML.Allowed',
                'p,br,b,strong,i,em,u,a[href|title],ul,ol,li,blockquote,pre,code,h2,h3,h4,img[src|alt|width|height]');
            $config->set('URI.AllowedSchemes', ['http' => true, 'https' => true]);
            $config->set('HTML.TargetBlank', true);
            $purifier = new HTMLPurifier($config);
        }
        return $purifier->purify($html);
    }
    return strip_tags($html,
        '<p><br><b><strong><i><em><u><a><ul><ol><li><blockquote><pre><code><h2><h3><h4><img>');
}

function safe_simplexml(string $path): ?SimpleXMLElement {
    /** @psalm-suppress DeprecatedFunction */
    if (PHP_VERSION_ID < 80000) {
        libxml_disable_entity_loader(true);
    }
    libxml_use_internal_errors(true);
    $xml = simplexml_load_file($path, 'SimpleXMLElement',
        LIBXML_NONET | LIBXML_NOERROR | LIBXML_NOWARNING);
    libxml_clear_errors();
    return $xml ?: null;
}

/**
 * Read OPML and return categories array:
 * [
 *   ['slug' => 'tech', 'title' => 'Tech', 'feeds' => [...]],
 *   ...
 * ]
 * Feeds not inside a category group go into 'Uncategorized'.
 */
function read_opml(string $file): array {
    if (!file_exists($file)) die('OPML file not found.');
    $xml = safe_simplexml($file);
    if (!$xml instanceof SimpleXMLElement) die('Failed to parse OPML file.');

    $title = trim((string)($xml->head->title ?? ''));
    if ($title) define('FEED_TITLE', $title);

    $categories = [];
    $total_feeds = 0;

    foreach ($xml->body->outline as $group) {
        $type = (string)($group['type'] ?? '');

        // Top-level feed (no category wrapper)
        if ($type === 'rss') {
            $cat_slug = 'uncategorized';
            if (!isset($categories[$cat_slug])) {
                $categories[$cat_slug] = ['slug' => $cat_slug, 'title' => 'Uncategorized', 'feeds' => []];
            }
            $url     = (string)($group['xmlUrl']  ?? '');
            $htmlUrl = (string)($group['htmlUrl'] ?? '');
            if ($total_feeds < MAX_FEEDS && is_safe_url($url)) {
                $categories[$cat_slug]['feeds'][] = [
                    'title'   => (string)($group['title'] ?? $group['text'] ?? 'Untitled'),
                    'url'     => $url,
                    'htmlUrl' => is_safe_url($htmlUrl) ? $htmlUrl : '',
                ];
                $total_feeds++;
            }
            continue;
        }

        // Category group — iterate its children
        $cat_title = (string)($group['title'] ?? $group['text'] ?? 'Uncategorized');
        $cat_slug  = slugify($cat_title);

        if (!isset($categories[$cat_slug])) {
            $categories[$cat_slug] = ['slug' => $cat_slug, 'title' => $cat_title, 'feeds' => []];
        }

        foreach ($group->outline as $o) {
            if ($total_feeds >= MAX_FEEDS) break 2;
            $url     = (string)($o['xmlUrl']  ?? '');
            $htmlUrl = (string)($o['htmlUrl'] ?? '');
            if (!is_safe_url($url)) {
                log_error("Skipped unsafe feed URL: $url");
                continue;
            }
            $categories[$cat_slug]['feeds'][] = [
                'title'   => (string)($o['title'] ?? $o['text'] ?? 'Untitled'),
                'url'     => $url,
                'htmlUrl' => is_safe_url($htmlUrl) ? $htmlUrl : '',
            ];
            $total_feeds++;
        }
    }

    return array_values($categories);
}

function ensure_cache_dir(): void {
    if (!is_dir(CACHE_DIR)) mkdir(CACHE_DIR, 0750, true);
    $htaccess = CACHE_DIR . '.htaccess';
    if (!file_exists($htaccess)) {
        file_put_contents($htaccess, "Require all denied\nDeny from all\n");
    }
}

function fetch_feed(string $url): ?SimpleXMLElement {
    $key   = CACHE_DIR . md5($url) . '.xml';
    $fresh = file_exists($key) && (time() - filemtime($key) < CACHE_TTL);

    if (!$fresh) {
        $ctx = stream_context_create(['http' => [
            'timeout'          => 8,
            'follow_location'  => true,
            'max_redirects'    => 3,
            'user_agent'       => 'SimpleAggregator/1.0',
            'protocol_version' => '1.1',
        ]]);
        $raw = file_get_contents($url, false, $ctx);
        if ($raw === false) {
            log_error("Failed to fetch feed: $url");
            return null;
        }
        file_put_contents($key, $raw);
    }

    return safe_simplexml($key);
}

function parse_items(SimpleXMLElement $xml, string $source): array {
    $items = [];
    /** @var iterable<SimpleXMLElement> $nodes */
    $nodes = $xml->channel->item ?? $xml->entry ?? [];

    foreach ($nodes as $node) {
        // Prefer rel="alternate" for Atom/Blogger feeds
        $link = '';
        if (isset($node->link)) {
            foreach ($node->link as $l) {
                $rel  = (string)($l['rel']  ?? 'alternate');
                $href = (string)($l['href'] ?? '');
                if ($rel === 'alternate' && $href !== '') { $link = $href; break; }
            }
            if ($link === '') {
                $link = isset($node->link['href'])
                    ? (string)$node->link['href']
                    : (string)$node->link;
            }
        }

        $ns   = $node->children('content', true);
        $body = (string)($ns->encoded ?? $node->description ?? $node->summary ?? '');
        $date = (string)($node->pubDate ?? $node->updated ?? $node->published ?? '');

        $items[] = [
            'title'  => html_entity_decode(strip_tags((string)$node->title), ENT_QUOTES, 'UTF-8'),
            'link'   => safe_url($link),
            'body'   => sanitize_html($body),
            'date'   => (int)(($date ? strtotime($date) : 0) ?: 0),
            'source' => $source,
        ];
    }
    return array_slice($items, 0, MAX_ITEMS);
}

function collect_items(array $feeds): array {
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

function cat_rss_url(string $slug): string {
    return SITE_URL . '?cat=' . urlencode($slug) . '&output=rss';
}

function cat_page_url(string $slug): string {
    return SITE_URL . '?cat=' . urlencode($slug);
}

function output_rss(array $items, string $cat_title, string $rss_url): void {
    header('Content-Type: application/rss+xml; charset=utf-8');
    $feed_title = FEED_TITLE . ($cat_title ? ' — ' . $cat_title : '');
    echo '<?xml version="1.0" encoding="UTF-8"?>' . "\n";
    echo '<rss version="2.0"><channel>';
    echo '<title>'       . htmlspecialchars($feed_title) . '</title>';
    echo '<link>'        . htmlspecialchars($rss_url)    . '</link>';
    echo '<description>' . htmlspecialchars(FEED_DESC)   . '</description>';
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

function output_html(array $items, array $categories, string $active_slug): void {
    $active_cat  = null;
    foreach ($categories as $c) {
        if ($c['slug'] === $active_slug) { $active_cat = $c; break; }
    }
    $page_title = FEED_TITLE . ($active_cat ? ' — ' . $active_cat['title'] : '');
    $rss_url    = $active_slug
        ? htmlspecialchars(cat_rss_url($active_slug))
        : htmlspecialchars(SITE_URL . '?output=rss');
?><!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= htmlspecialchars($page_title) ?></title>
<link rel="alternate" type="application/rss+xml" title="<?= htmlspecialchars($page_title) ?>" href="<?= $rss_url ?>">
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  body   { font-family: system-ui, sans-serif; background: #f5f5f5; color: #222; line-height: 1.6; }
  header { background: #1a1a2e; color: #eee; padding: 1rem 2rem; display: flex; align-items: center; gap: 1rem; flex-wrap: wrap; }
  header h1  { font-size: 1.3rem; font-weight: 600; }
  header a.rss { color: #f0a500; font-size: .85rem; margin-left: auto; text-decoration: none; }
  header a.rss:hover { text-decoration: underline; }
  nav.cats   { background: #16213e; padding: .5rem 2rem; display: flex; gap: .25rem; flex-wrap: wrap; }
  nav.cats a { color: #aac; font-size: .85rem; text-decoration: none; padding: .3rem .75rem;
               border-radius: 4px; transition: background .15s; }
  nav.cats a:hover    { background: #ffffff18; color: #fff; }
  nav.cats a.active   { background: #e63946; color: #fff; }
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
<body id="denny.wordpress.com">
<header>
  <h1>📰 <?= htmlspecialchars(FEED_TITLE) ?></h1>
  <a class="rss" href="<?= $rss_url ?>">🔗 RSS Feed</a>
</header>

<nav class="cats">
  <?php foreach ($categories as $c): ?>
    <a href="<?= htmlspecialchars(cat_page_url($c['slug'])) ?>"
       class="<?= $c['slug'] === $active_slug ? 'active' : '' ?>">
      <?= htmlspecialchars($c['title']) ?>
    </a>
  <?php endforeach; ?>
</nav>

<div class="layout">
  <aside>
    <?php if ($active_cat): ?>
      <h2>Sources (<?= count($active_cat['feeds']) ?>)</h2>
      <ul>
      <?php foreach ($active_cat['feeds'] as $f): ?>
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
    <?php endif; ?>
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
denny.wordpress.com
</body>
</html>
<?php
}

// ── Main ─────────────────────────────────────────────────────────────────────

ensure_cache_dir();
$categories = read_opml(OPML_FILE);
if (!defined('FEED_TITLE')) define('FEED_TITLE', FEED_TITLE_DEFAULT);

// Resolve active category — default to first one
$requested_slug = trim($_GET['cat'] ?? '');
$active_slug    = '';
foreach ($categories as $c) {
    if ($c['slug'] === $requested_slug) { $active_slug = $c['slug']; break; }
}
if ($active_slug === '' && count($categories) > 0) {
    $active_slug = $categories[0]['slug'];
}

// Collect feeds for the active category only
$active_feeds = [];
foreach ($categories as $c) {
    if ($c['slug'] === $active_slug) { $active_feeds = $c['feeds']; break; }
}
$items = collect_items($active_feeds);

if (($_GET['output'] ?? '') === 'rss') {
    $cat_title = '';
    foreach ($categories as $c) {
        if ($c['slug'] === $active_slug) { $cat_title = $c['title']; break; }
    }
    output_rss($items, $cat_title, cat_rss_url($active_slug));
} else {
    output_html($items, $categories, $active_slug);
}
