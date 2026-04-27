<?php
// catalog.php - OPDS v1.2 dengan external OPDS di bawah
// CSV wajib ada kolom: id,title,author,summary,cover_url,download_url,language,published,category,tags,opds_url

// === CONFIG ===
define('SCRIPT_NAME', basename(__FILE__));
define('CSV_URL', 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTTcNN6fmETWj5DDNC-FGSkdmD-8jCspO1dbMTweH4OjUM8ofBCuUR0NA7VfyLJG8ho-hPp6aT_AJbb/pub?gid=0&single=true&output=csv');
define('CSV_LOCAL', __DIR__. '/books.csv');
define('CACHE_DIR', __DIR__. '/opds_cache/');
define('CACHE_TTL', 3600);
define('FEED_TITLE', 'Katalog Buku Alkitabiah.org');
define('FEED_AUTHOR', 'denny.wordpress.com');
define('BASE_URL', (isset($_SERVER['HTTPS'])? 'https' : 'http'). '://'. $_SERVER['HTTP_HOST']. dirname($_SERVER['SCRIPT_NAME']));

if (!is_dir(CACHE_DIR)) mkdir(CACHE_DIR, 0755, true);

// === ROUTING ===
$category = $_GET['cat']?? null;
$tag = $_GET['tag']?? null;
$query = trim($_GET['q']?? '');
$noCache = isset($_GET['nocache']) && $_GET['nocache'] == '1';

$cacheKey = md5(($category?? ''). ($tag?? ''). $query);
$cacheFile = CACHE_DIR. 'opds_'. $cacheKey. '.xml';

// === CACHE CHECK ===
if (!$noCache && file_exists($cacheFile) && time() - filemtime($cacheFile) < CACHE_TTL) {
    header('Content-Type: application/atom+xml; charset=utf-8');
    header('X-OPDS-Cache: HIT');
    readfile($cacheFile);
    exit;
}

if ($noCache) {
    header('X-OPDS-Cache: BYPASS');
    @unlink($cacheFile);
    @unlink(CSV_LOCAL);
}

// === GET CSV ===
$csvData = @file_get_contents(CSV_LOCAL);
if ($csvData === false || $noCache) {
    $csvData = @file_get_contents(CSV_URL);
    if ($csvData === false) {
        http_response_code(500);
        die('Error: Cannot read local books.csv and download failed.');
    }
    file_put_contents(CSV_LOCAL, $csvData);
}

// === PARSE CSV ===
$lines = explode("\n", trim($csvData));
$headers = array_map('trim', str_getcsv(array_shift($lines)));
$headerCount = count($headers);

$books = [];
$opdsLinks = [];
$allCategories = [];
$allTags = [];

foreach ($lines as $lineNum => $line) {
    $line = trim($line);
    if ($line === '') continue;

    $row = str_getcsv($line);
    $row = array_map('trim', $row);

    if (count($row)!== $headerCount) {
        error_log("OPDS: Skip line ".($lineNum+2)." - column mismatch. Got ".count($row).", expected $headerCount");
        continue;
    }
    if (empty($row[0])) continue;

    $item = array_combine($headers, $row);
    $item['category'] = trim($item['category']?? 'Uncategorized');
    $item['tags'] = array_filter(array_map('trim', explode(',', $item['tags']?? '')));
    $item['opds_url'] = trim($item['opds_url']?? '');

    if (!empty($item['opds_url'])) {
        $opdsLinks[] = $item;
    } else {
        $books[] = $item;
        $allCategories[$item['category']] = true;
        foreach ($item['tags'] as $t) $allTags[$t] = true;
    }
}

ksort($allCategories);
ksort($allTags);

// === FILTER ===
if ($category) {
    $books = array_filter($books, fn($b) => strcasecmp($b['category'], $category) === 0);
    $opdsLinks = array_filter($opdsLinks, fn($l) => strcasecmp($l['category'], $category) === 0);
    $feedTitle = FEED_TITLE. ' - '. $category;
} elseif ($tag) {
    $books = array_filter($books, fn($b) => in_array($tag, $b['tags']));
    $opdsLinks = array_filter($opdsLinks, fn($l) => in_array($tag, $l['tags']));
    $feedTitle = FEED_TITLE. ' - Tag: '. $tag;
} elseif ($query) {
    $q = mb_strtolower($query);
    $filterFn = function($b) use ($q) {
        $haystack = mb_strtolower(($b['title']??''). ' '. ($b['author']??''). ' '. ($b['summary']??''). ' '. implode(' ', $b['tags']));
        return str_contains($haystack, $q);
    };
    $books = array_filter($books, $filterFn);
    $opdsLinks = array_filter($opdsLinks, $filterFn);
    $feedTitle = FEED_TITLE. ' - Search: '. htmlspecialchars($query);
} else {
    $feedTitle = FEED_TITLE;
}

// === BUILD OPDS ===
$updated = date('c');
$params = array_filter(['cat' => $category, 'tag' => $tag, 'q' => $query, 'nocache' => $noCache?1:null]);
$selfUrl = BASE_URL. '/'. SCRIPT_NAME. ($params? '?'. http_build_query($params) : '');

$xml = new XMLWriter();
$xml->openMemory();
$xml->setIndent(true);
$xml->startDocument('1.0', 'UTF-8');
$xml->startElement('feed');
$xml->writeAttribute('xmlns', 'http://www.w3.org/2005/Atom');
$xml->writeAttribute('xmlns:dc', 'http://purl.org/dc/terms/');
$xml->writeAttribute('xmlns:opds', 'http://opds-spec.org/2010/catalog');

$xml->writeElement('id', $selfUrl);
$xml->writeElement('title', $feedTitle);
$xml->writeElement('updated', $updated);
$xml->startElement('author'); $xml->writeElement('name', FEED_AUTHOR); $xml->endElement();

$xml->startElement('link'); $xml->writeAttribute('href', $selfUrl); $xml->writeAttribute('rel', 'self');
$xml->writeAttribute('type', 'application/atom+xml;profile=opds-catalog;kind='.($category||$tag||$query?'acquisition':'navigation')); $xml->endElement();

$xml->startElement('link'); $xml->writeAttribute('href', BASE_URL.'/'.SCRIPT_NAME); $xml->writeAttribute('rel', 'start');
$xml->writeAttribute('type', 'application/atom+xml;profile=opds-catalog;kind=navigation'); $xml->endElement();

$xml->startElement('link');
$xml->writeAttribute('href', BASE_URL. '/'. SCRIPT_NAME. '?q={searchTerms}');
$xml->writeAttribute('rel', 'search');
$xml->writeAttribute('type', 'application/atom+xml;profile=opds-catalog;kind=acquisition');
$xml->endElement();

if (!$category &&!$tag &&!$query) {
    // 1. Kategori lokal
    foreach (array_keys($allCategories) as $cat) {
        $count = count(array_filter($books, fn($b)=>$b['category']===$cat));
        $xml->startElement('entry');
        $xml->writeElement('id', 'urn:category:'. md5($cat));
        $xml->writeElement('title', $cat);
        $xml->writeElement('updated', $updated);
        $xml->startElement('link');
        $xml->writeAttribute('href', BASE_URL. '/'. SCRIPT_NAME. '?cat='. urlencode($cat));
        $xml->writeAttribute('rel', 'subsection');
        $xml->writeAttribute('type', 'application/atom+xml;profile=opds-catalog;kind=acquisition');
        $xml->endElement();
        $xml->writeElement('content', $count. ' books');
        $xml->endElement();
    }

    // 2. Tags
    foreach (array_slice(array_keys($allTags), 0, 20) as $t) {
        $xml->startElement('link');
        $xml->writeAttribute('href', BASE_URL. '/'. SCRIPT_NAME. '?tag='. urlencode($t));
        $xml->writeAttribute('rel', 'http://opds-spec.org/facet');
        $xml->writeAttribute('opds:facetGroup', 'Tags');
        $xml->writeAttribute('title', $t);
        $xml->endElement();
    }
}

if (($query || $category || $tag) && empty($books) && empty($opdsLinks)) {
    $xml->startElement('entry');
    $xml->writeElement('id', 'urn:no-results');
    $xml->writeElement('title', 'No results found');
    $xml->writeElement('updated', $updated);
    $xml->endElement();
}

// BOOK ENTRIES DULU
foreach ($books as $book) {
    $id = htmlspecialchars($book['id']?? uniqid());
    $title = htmlspecialchars($book['title']?? 'Untitled');
    $author = htmlspecialchars($book['author']?? 'Unknown');
    $summary = htmlspecialchars($book['summary']?? '');
    $lang = htmlspecialchars($book['language']?? 'en');
    $published = htmlspecialchars($book['published']?? '');
    $cover = htmlspecialchars($book['cover_url']?? '');
    $download = htmlspecialchars($book['download_url']?? '');
    $cat = htmlspecialchars($book['category']);

    $xml->startElement('entry');
    $xml->writeElement('id', 'urn:uuid:'. $id);
    $xml->writeElement('title', $title);
    $xml->writeElement('updated', $updated);
    $xml->startElement('author'); $xml->writeElement('name', $author); $xml->endElement();
    if($lang) $xml->writeElement('dc:language', $lang);
    if($published) $xml->writeElement('dc:issued', $published);
    $xml->startElement('category'); $xml->writeAttribute('term', $cat); $xml->writeAttribute('label', $cat); $xml->endElement();
    foreach ($book['tags'] as $t) {
        $xml->startElement('category'); $xml->writeAttribute('term', $t); $xml->writeAttribute('label', $t); $xml->endElement();
    }
    if($summary) $xml->writeElement('summary', $summary);

    if ($cover) {
        $xml->startElement('link'); $xml->writeAttribute('href', $cover);
        $xml->writeAttribute('rel', 'http://opds-spec.org/image'); $xml->writeAttribute('type', 'image/jpeg'); $xml->endElement();
        $xml->startElement('link'); $xml->writeAttribute('href', $cover);
        $xml->writeAttribute('rel', 'http://opds-spec.org/image/thumbnail'); $xml->writeAttribute('type', 'image/jpeg'); $xml->endElement();
    }

    if ($download) {
        $ext = strtolower(pathinfo(parse_url($download, PHP_URL_PATH), PATHINFO_EXTENSION));
        $type = match($ext) {
            'pdf' => 'application/pdf',
            'mobi' => 'application/x-mobipocket-ebook',
            'azw3' => 'application/vnd.amazon.ebook',
            default => 'application/epub+zip'
        };
        $xml->startElement('link'); $xml->writeAttribute('href', $download);
        $xml->writeAttribute('rel', 'http://opds-spec.org/acquisition'); $xml->writeAttribute('type', $type); $xml->endElement();
    }
    $xml->endElement();
}

// OPDS LINKS PALING BAWAH
foreach ($opdsLinks as $link) {
    $xml->startElement('entry');
    $xml->writeElement('id', 'urn:external:'. md5($link['opds_url']));
    $xml->writeElement('title', '📚 '. htmlspecialchars($link['title']));
    $xml->writeElement('updated', $updated);
    if(!empty($link['author'])) {
        $xml->startElement('author'); $xml->writeElement('name', htmlspecialchars($link['author'])); $xml->endElement();
    }
    if(!empty($link['summary'])) $xml->writeElement('summary', htmlspecialchars($link['summary']));
    $xml->startElement('link');
    $xml->writeAttribute('href', htmlspecialchars($link['opds_url']));
    $xml->writeAttribute('rel', 'subsection');
    $xml->writeAttribute('type', 'application/atom+xml;profile=opds-catalog');
    $xml->endElement();
    $xml->endElement();
}

$xml->endElement();
$output = $xml->outputMemory();

file_put_contents($cacheFile, $output);
header('Content-Type: application/atom+xml; charset=utf-8');
header('X-OPDS-Cache: '. ($noCache? 'MISS' : 'STORED'));
echo $output;
