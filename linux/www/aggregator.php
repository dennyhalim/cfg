<?php
/**
 * Simple RSS Aggregator
 * - Reads an OPML file
 * - Displays all feed content
 * - Outputs an aggregated RSS feed
 *
 * Usage:
 *   Browser view : aggregator.php
 *   RSS output   : aggregator.php?output=rss
 */

// ─── CONFIG ──────────────────────────────────────────────────────────────────
define('OPML_FILE',   'feeds.opml');   // path to your OPML file
define('CACHE_DIR',   'cache/');       // cache directory (must be writable)
define('CACHE_TTL',   1800);           // cache lifetime in seconds (30 min)
define('MAX_ITEMS',   10);             // max items fetched per feed
define('FEED_TITLE',  'My Aggregator');
define('FEED_LINK',   'http://' . ($_SERVER['HTTP_HOST'] ?? 'localhost') . $_SERVER['REQUEST_URI']);
define('FEED_DESC',   'Aggregated RSS feed');
// ─────────────────────────────────────────────────────────────────────────────

// ── Helpers ──────────────────────────────────────────────────────────────────

function read_opml(string $file): array {
    if (!file_exists($file)) die("OPML file not found: $file");
    $xml   = simplexml_load_file($file);
    $feeds = [];
    foreach ($xml->xpath('//outline[@type="rss"]') as $o) {
        $feeds[] = [
            'title'   => (string)($o['title'] ?? $o['text'] ?? 'Untitled'),
            'url'     => (string) $o['xmlUrl'],
            'htmlUrl' => (string)($o['htmlUrl'] ?? ''),
        ];
    }
    return $feeds;
}

function fetch_feed(string $url): ?SimpleXMLElement {
    if (!is_dir(CACHE_DIR)) mkdir(CACHE_DIR, 0755, true);
    $key  = CACHE_DIR . md5($url) . '.xml';
    $fresh = file_exists($key) && (time() - filemtime($key) < CACHE_TTL);

    if (!$fresh) {
        $ctx = stream_context_create(['http' => [
            'timeout'          => 8,
            'follow_location'  => true,
            'user_agent'       => 'SimpleAggregator/1.0',
        ]]);
        $raw = @file_get_contents($url, false, $ctx);
        if ($raw === false) return null;
        file_put_contents($key, $raw);
    }

    libxml_use_internal_errors(true);
    return simplexml_load_file($key) ?: null;
}

function parse_items(SimpleXMLElement $xml, string $source): array {
    $items = [];
    $nodes = $xml->channel->item ?? $xml->entry ?? [];   // RSS 2.0 + Atom

    foreach ($nodes as $node) {
        // Atom uses <link href="…"/>, RSS uses <link>text</link>
        $link = isset($node->link['href'])
            ? (string)$node->link['href']
            : (string)$node->link;

        // Prefer <content:encoded> over <description> / <summary>
        $ns   = $node->children('content', true);
        $body = (string)($ns->encoded ?? $node->description ?? $node->summary ?? '');

        $date = (string)($node->pubDate ?? $node->updated ?? $node->published ?? '');

        $items[] = [
            'title'  => html_entity_decode(strip_tags((string)$node->title), ENT_QUOTES, 'UTF-8'),
            'link'   => $link,
            'body'   => $body,
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
    echo '<title>' . htmlspecialchars(FEED_TITLE) . '</title>';
    echo '<link>'  . htmlspecialchars(FEED_LINK)  . '</link>';
    echo '<description>' . htmlspecialchars(FEED_DESC) . '</description>';

    foreach ($items as $item) {
        $pub = $item['date'] ? date(DATE_RSS, $item['date']) : date(DATE_RSS);
        echo '<item>';
        echo '<title>'       . htmlspecialchars($item['title'])  . '</title>';
        echo '<link>'        . htmlspecialchars($item['link'])   . '</link>';
        echo '<description>' . htmlspecialchars(strip_tags($item['body'])) . '</description>';
        echo '<category>'    . htmlspecialchars($item['source']) . '</category>';
        echo '<pubDate>'     . $pub . '</pubDate>';
        echo '<guid isPermaLink="true">' . htmlspecialchars($item['link']) . '</guid>';
        echo '</item>';
    }
    echo '</channel></rss>';
}

function output_html(array $items, array $feeds): void {
    $rss_url = htmlspecialchars(strtok(FEED_LINK, '?') . '?output=rss');
?><!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= FEED_TITLE ?></title>
<link rel="alternate" type="application/rss+xml" title="<?= FEED_TITLE ?>" href="<?= $rss_url ?>">
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
  .body.expanded { max-height: none;
               -webkit-mask-image: none;
                        mask-image: none; }
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
          <a href="<?= htmlspecialchars($f['htmlUrl']) ?>" target="_blank" rel="noopener"><?= htmlspecialchars($f['title']) ?></a>
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
      <h2><a href="<?= htmlspecialchars($item['link']) ?>" target="_blank" rel="noopener">
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
// Hide toggle button for short articles that don't need it
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
$items = collect_all($feeds);

if (($_GET['output'] ?? '') === 'rss') {
    output_rss($items);
} else {
    output_html($items, $feeds);
}
