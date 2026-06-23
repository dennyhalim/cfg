<?php
$CX = 'YOUR_CX_ID';

// 1. Get query from ?q= or URL path
$q = $_GET['q'] ?? '';
if (!$q) {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    $q = $path;
}

// 2. Clean query: remove .php .html .htm + separators
$q = preg_replace('/\.(php|html?|asp|jsp)$/i', '', $q);
$q = str_replace(['/', '-', '_'], ' ', $q);
$q = trim(preg_replace('/\s+/', ' ', $q));

// 3. Fallback if empty
if (!$q) {
    $q = 'site:' . $_SERVER['HTTP_HOST'];
}

$encoded_q = urlencode($q);
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title><?=htmlspecialchars($q)?> - Search</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
body{font:16px/1.6 system-ui,-apple-system,Segoe UI,Roboto,sans-serif;max-width:800px;margin:48px auto;padding:0 20px;color:#202124}
h1{font-size:28px;margin:0 0 16px}
input{width:100%;padding:12px;border:1px solid #dadce0;border-radius:8px;font-size:16px;margin-bottom:24px}
input:focus{outline:none;border-color:#1a73e8;box-shadow:0 0 0 2px #1a73e822}
.muted{color:#70757a;font-size:14px;margin:-16px 0 16px}
.gsc-control-cse{padding:0!important;border:0!important}
</style>
</head>
<body id="denny.wordpress.com">
<h1>Page not found</h1>
<form method="get" action="">
<input name="q" value="<?=htmlspecialchars($q)?>" placeholder="Search this site..." autofocus>
</form>
<p class="muted">Showing results for: <b><?=htmlspecialchars($q)?></b></p>

<!-- Google CSE iframe -->
<div class="gcse-searchresults-only" data-queryParameterName="q"></div>
<script async src="https://cse.google.com/cse.js?cx=<?=htmlspecialchars($CX)?>"></script>
<script>
// Auto-trigger search on load with cleaned query
window.onload = function() {
    if (window.google && google.search) {
        var element = google.search.cse.element.getElement('searchresults-only0');
        if (element) element.execute('<?=addslashes($q)?>');
    }
}
</script>
</body>
</html>
