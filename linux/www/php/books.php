<?php
$ua       = $_SERVER['HTTP_USER_AGENT'] ?? '';
$keywords = ['bot', 'crawl', 'spider', 'slurp', 'scrap', 'chrom', 'edg', 'browser'];

foreach ($keywords as $keyword) {
    if (str_contains(strtolower($ua), $keyword)) {
        header('Location: https://yesustuhan.wordpress.com/?utm_source=alkitabiah.org');
        exit;
    }
}

require 'vendor/autoload.php';

use PhpOffice\PhpSpreadsheet\IOFactory;

$category = $_GET['cat']?? null;
$tag = $_GET['tag']?? null;
$query = trim($_GET['q']?? '');
$sheet_filter = $_GET['sheet']?? null;
$noCache = isset($_GET['nocache']);

define('FEED_TITLE', getenv('FEED_TITLE')?: 'My Book Catalog');
define('FEED_AUTHOR', getenv('FEED_AUTHOR')?: 'denny.wordpress.com');
define('XLSX_URL', getenv('DATA_URL')?: 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTTcNN6fmETWj5DDNC-FGSkdmD-8jCspO1dbMTweH4OjUM8ofBCuUR0NA7VfyLJG8ho-hPp6aT_AJbb/pub?output=xlsx');
define('MAIN_SHEET', getenv('MAIN_SHEET')?: 'main');
define('CACHE_DIR', __DIR__. '/cache');
define('XLSX_CACHE', CACHE_DIR. '/books.xlsx');
define('DATA_CACHE', CACHE_DIR. '/opds_data.json');
define('META_CACHE', CACHE_DIR. '/meta.json');
define('CACHE_TTL', 3600);

$BASE_URL = (isset($_SERVER['HTTPS'])? 'https' : 'http'). '://'. $_SERVER['HTTP_HOST'];
$SCRIPT_PATH = $_SERVER['SCRIPT_NAME'];

downloadXlsxIfNeeded();
$data = loadDataCache();
if (!$data) {
    $data = parseXlsx();
    saveDataCache($data);
}

$books = $data['books'];
$opdsLinks = $data['opdsLinks'];
$allTags = $data['allTags'];
$sheetNames = $data['sheetNames'];

// === FILTER ===
$filteredBooks = [];
$filteredOpdsLinks = $opdsLinks;
$feedTitle = FEED_TITLE;
$isRoot =!$category &&!$tag &&!$query &&!$sheet_filter;

if ($isRoot) {
    $filteredBooks = array_filter($books, fn($b) => strcasecmp($b['sheet'], MAIN_SHEET) === 0);
    $feedTitle = FEED_TITLE;
} elseif ($sheet_filter) {
    $filteredBooks = array_filter($books, fn($b) => strcasecmp($b['sheet'], $sheet_filter) === 0);
    $feedTitle = FEED_TITLE. ' - Sheet: '. $sheet_filter;
} elseif ($category) {
    $c = strtolower($category);
    $filteredBooks = array_filter($books, fn($b) => strtolower($b['category']) === $c);
    $filteredOpdsLinks = array_filter($opdsLinks, fn($l) => strtolower($l['category']) === $c);
    $feedTitle = FEED_TITLE. ' - '. $category;
} elseif ($tag) {
    $filteredBooks = array_filter($books, fn($b) => in_array($tag, $b['tags']));
    $filteredOpdsLinks = array_filter($opdsLinks, fn($l) => in_array($tag, $l['tags']));
    $feedTitle = FEED_TITLE. ' - Tag: '. $tag;
} elseif ($query) {
    $q = strtolower($query);
    $match = fn($b) => str_contains(strtolower($b['title'].' '.$b['author'].' '.$b['summary'].' '.implode(' ', $b['tags']).' '.$b['sheet']), $q);
    $filteredBooks = array_filter($books, $match);
    $filteredOpdsLinks = array_filter($opdsLinks, $match);
    $feedTitle = FEED_TITLE. ' - Search: '. $query;
}

// === BUILD OPDS XML ===
$updated = date('c');
$params = array_filter(['cat' => $category, 'tag' => $tag, 'q' => $query, 'sheet' => $sheet_filter]);
$selfUrl = $BASE_URL. $SCRIPT_PATH. ($params? '?'. http_build_query($params) : '');

header('Content-Type: application/atom+xml; charset=utf-8');
header('Cache-Control: '. ($noCache? 'no-cache' : 'public, max-age=300'));
header('X-Cache: '. ($data['from_cache']? 'HIT' : 'MISS'));

echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:dc="http://purl.org/dc/terms/" xmlns:opds="http://opds-spec.org/2010/catalog">
  <id><?= esc($selfUrl)?></id>
  <title><?= esc($feedTitle)?></title>
  <updated><?= $updated?></updated>
  <author><name><?= esc(FEED_AUTHOR)?></name></author>
  <link href="<?= esc($selfUrl)?>" rel="self" type="application/atom+xml;profile=opds-catalog;kind=acquisition"/>
  <link href="<?= $BASE_URL. $SCRIPT_PATH?>" rel="start" type="application/atom+xml;profile=opds-catalog;kind=acquisition"/>
  <link href="<?= $BASE_URL. $SCRIPT_PATH?>?q={searchTerms}" rel="search" type="application/atom+xml;profile=opds-catalog;kind=acquisition"/>
<?php if ($isRoot):?>
<?php
// SHEET LAIN JADI FOLDER. MAIN_SHEET SKIP
foreach ($sheetNames as $s):
    if (strcasecmp($s, MAIN_SHEET) === 0) continue;
    $count = count(array_filter($books, fn($b) => strcasecmp($b['sheet'], $s) === 0));
    if ($count === 0) continue;
?>
  <entry>
    <id>urn:sheet:<?= md5($s)?></id>
    <title>ðŸ“‚ <?= esc($s)?></title>
    <updated><?= $updated?></updated>
    <link href="<?= $BASE_URL. $SCRIPT_PATH?>?sheet=<?= urlencode($s)?>" rel="subsection" type="application/atom+xml;profile=opds-catalog;kind=acquisition"/>
    <content><?= $count?> books</content>
  </entry>
<?php endforeach;?>

<?php foreach (array_slice(array_keys($allTags), 0, 20) as $t):?>
  <link href="<?= $BASE_URL. $SCRIPT_PATH?>?tag=<?= urlencode($t)?>" rel="http://opds-spec.org/facet" opds:facetGroup="Tags" title="<?= esc($t)?>"/>
<?php endforeach;?>
<?php endif;?>

<?php if (($query || $category || $tag || $sheet_filter) && empty($filteredBooks) && empty($filteredOpdsLinks)):?>
  <entry><id>urn:no-results</id><title>No results found</title><updated><?= $updated?></updated></entry>
<?php endif;?>

<?php foreach ($filteredBooks as $book):?>
  <entry>
    <id>urn:uuid:<?= esc($book['id']?: uniqid())?></id>
    <title><?= esc($book['title']?: 'Untitled')?></title>
    <updated><?= $updated?></updated>
    <author><name><?= esc($book['author']?: 'Unknown')?></name></author>
    <?php if ($book['language']):?><dc:language><?= esc($book['language'])?></dc:language><?php endif;?>
    <?php if ($book['published']):?><dc:issued><?= esc($book['published'])?></dc:issued><?php endif;?>
    <category term="<?= esc($book['category'])?>" label="<?= esc($book['category'])?>"/>
    <category term="<?= esc($book['sheet'])?>" label="Sheet: <?= esc($book['sheet'])?>"/>
    <?php foreach ($book['tags'] as $t):?><category term="<?= esc($t)?>" label="<?= esc($t)?>"/><?php endforeach;?>
    <?php if ($book['summary']):?><summary><?= esc($book['summary'])?></summary><?php endif;?>
    <?php if ($book['cover_url']):?>
    <link href="<?= esc($book['cover_url'])?>" rel="http://opds-spec.org/image" type="image/jpeg"/>
    <link href="<?= esc($book['cover_url'])?>" rel="http://opds-spec.org/image/thumbnail" type="image/jpeg"/>
    <?php endif;?>
    <?php if ($book['download_url']):?><link href="<?= esc($book['download_url'])?>" rel="http://opds-spec.org/acquisition" type="<?= getMime($book['download_url'])?>"/><?php endif;?>
  </entry>
<?php endforeach;?>

<?php if ($isRoot):?>
<?php foreach ($filteredOpdsLinks as $link):?>
  <entry>
    <id>urn:external:<?= md5($link['opds_url'])?></id>
    <title>ðŸ“š <?= esc($link['title'])?></title>
    <updated><?= $updated?></updated>
    <?php if ($link['author']):?><author><name><?= esc($link['author'])?></name></author><?php endif;?>
    <?php if ($link['summary']):?><summary><?= esc($link['summary'])?></summary><?php endif;?>
    <link href="<?= esc($link['opds_url'])?>" rel="subsection" type="application/atom+xml;profile=opds-catalog"/>
  </entry>
<?php endforeach;?>
<?php endif;?>
</feed>
<?php
// === FUNCTIONS ===
function downloadXlsxIfNeeded() {
    global $noCache;
    if (!is_dir(CACHE_DIR)) mkdir(CACHE_DIR, 0755, true);
    $meta = file_exists(META_CACHE)? json_decode(file_get_contents(META_CACHE), true) : [];
    $needDownload = $noCache ||!file_exists(XLSX_CACHE) || (time() - ($meta['checked_at']?? 0) > CACHE_TTL);
    if (!$needDownload) return;
    $headers = [];
    if (!empty($meta['etag'])) $headers[] = 'If-None-Match: '. $meta['etag'];
    if (!empty($meta['last_modified'])) $headers[] = 'If-Modified-Since: '. $meta['last_modified'];
    $ch = curl_init(XLSX_URL);
    curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_FOLLOWLOCATION => true, CURLOPT_HTTPHEADER => $headers, CURLOPT_HEADER => true, CURLOPT_TIMEOUT => 30, CURLOPT_USERAGENT => 'PHP-OPDS/1.0']);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    curl_close($ch);
    if ($httpCode === 304) {
        $meta['checked_at'] = time();
        file_put_contents(META_CACHE, json_encode($meta));
        return;
    }
    if ($httpCode === 200) {
        $header = substr($response, 0, $headerSize);
        $body = substr($response, $headerSize);
        file_put_contents(XLSX_CACHE, $body);
        preg_match('/ETag: (.+)/i', $header, $etag);
        preg_match('/Last-Modified: (.+)/i', $header, $lastMod);
        $meta = ['etag' => trim($etag[1]?? ''), 'last_modified' => trim($lastMod[1]?? ''), 'downloaded_at' => time(), 'checked_at' => time()];
        file_put_contents(META_CACHE, json_encode($meta));
        if (file_exists(DATA_CACHE)) unlink(DATA_CACHE);
    } else {
        throw new Exception("Failed to download XLSX: HTTP $httpCode");
    }
}
function loadDataCache() {
    global $noCache;
    if ($noCache ||!file_exists(DATA_CACHE) ||!file_exists(XLSX_CACHE)) return null;
    if (filemtime(XLSX_CACHE) > filemtime(DATA_CACHE)) return null;
    $data = json_decode(file_get_contents(DATA_CACHE), true);
    if ($data) $data['from_cache'] = true;
    return $data;
}
function saveDataCache($data) {
    $data['cached_at'] = time();
    file_put_contents(DATA_CACHE, json_encode($data, JSON_UNESCAPED_UNICODE));
}
function parseXlsx() {
    if (!file_exists(XLSX_CACHE)) throw new Exception('XLSX cache not found');
    $spreadsheet = IOFactory::load(XLSX_CACHE);
    $sheetNames = $spreadsheet->getSheetNames();
    $books = $opdsLinks = $allTags = [];
    foreach ($sheetNames as $sheetName) {
        $rows = $spreadsheet->getSheetByName($sheetName)->toArray(null, true, true, true);
        if (count($rows) < 2) continue;
        $headers = array_map('trim', array_shift($rows));
        foreach ($rows as $row) {
            $item = array_combine($headers, array_map('trim', $row));
            if (empty($item['id']) && empty($item['title'])) continue;
            $item['tags'] =!empty($item['tags'])? array_filter(array_map('trim', explode(',', $item['tags']))) : [];
            $item['sheet'] = $sheetName;
            $item['opds_url'] = trim($item['opds_url']?? '');
            if (!empty($item['opds_url'])) {
                $item['category'] = '_OPDS_LINKS';
                $opdsLinks[] = $item;
            } else {
                $item['category'] = trim($item['category']?: $sheetName?: 'Uncategorized');
                $books[] = $item;
                foreach ($item['tags'] as $t) $allTags[$t] = true;
            }
        }
    }
    return ['books' => $books, 'opdsLinks' => $opdsLinks, 'allTags' => $allTags, 'sheetNames' => $sheetNames, 'from_cache' => false];
}
function esc($str) { return htmlspecialchars($str, ENT_XML1 | ENT_COMPAT, 'UTF-8'); }
function getMime($url) {
    $path = parse_url($url, PHP_URL_PATH);
    $query = parse_url($url, PHP_URL_QUERY);
    parse_str($query, $params);
    
    // 1. Cek query param Google: format=xxx
    if (isset($params['format'])) {
        return [
            'pdf' => 'application/pdf',
            'epub' => 'application/epub+zip',
            'mobi' => 'application/x-mobipocket-ebook',
            'azw3' => 'application/vnd.amazon.ebook',
            'txt' => 'text/plain',
            'rtf' => 'application/rtf',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'doc' => 'application/msword',
            'md' => 'text/markdown',
            'html' => 'text/html',
            'odt' => 'application/vnd.oasis.opendocument.text',
            'fb2' => 'application/x-fictionbook+xml',
            'cbz' => 'application/vnd.comicbook+zip',
            'cbr' => 'application/vnd.comicbook-rar'
        ][$params['format']] ?? 'application/octet-stream';
    }
    
    // 2. Cek query param output=pdf
    if (isset($params['output']) && $params['output'] === 'pdf') {
        return 'application/pdf';
    }
    
    // 3. Cek ekstensi file biasa
    $ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
    return [
        // Ebook
        'pdf' => 'application/pdf',
        'epub' => 'application/epub+zip',
        'mobi' => 'application/x-mobipocket-ebook',
        'azw3' => 'application/vnd.amazon.ebook',
        'azw' => 'application/vnd.amazon.ebook',
        'fb2' => 'application/x-fictionbook+xml',
        'kfx' => 'application/vnd.amazon.ebook',
        
        // Document
        'txt' => 'text/plain',
        'md' => 'text/plain',
        'markdown' => 'text/markdown',
        'rtf' => 'application/rtf',
        'doc' => 'application/msword',
        'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'odt' => 'application/vnd.oasis.opendocument.text',
        'html' => 'text/html',
        'htm' => 'text/html',
        
        // Comic
        'cbz' => 'application/vnd.comicbook+zip',
        'cbr' => 'application/vnd.comicbook-rar',
        'cbt' => 'application/x-cbt',
        'cb7' => 'application/x-cb7',
        
        // Archive
        'zip' => 'application/zip',
        'rar' => 'application/vnd.rar',
        '7z' => 'application/x-7z-compressed'
    ][$ext] ?? 'application/octet-stream';
}
?>
