
<?php

header('Content-Type: text/html; charset=utf-8');

$requestHeaders  = getallheaders();
$responseHeaders = headers_list();

echo '<h2>Client headers</h2>';
echo '<table border="1" cellpadding="6">';
echo '<tr><th>Header</th><th>Value</th></tr>';

foreach ($requestHeaders as $name => $value) {
    echo '<tr>';
    echo '<td>' . htmlspecialchars($name) . '</td>';
    echo '<td>' . htmlspecialchars($value) . '</td>';
    echo '</tr>';
}

echo '</table>';

echo '<h2>Response headers</h2>';
echo '<table border="1" cellpadding="6">';
echo '<tr><th>Header</th><th>Value</th></tr>';

foreach ($responseHeaders as $header) {
    [$name, $value] = explode(':', $header, 2);
    echo '<tr>';
    echo '<td>' . htmlspecialchars(trim($name)) . '</td>';
    echo '<td>' . htmlspecialchars(trim($value)) . '</td>';
    echo '</tr>';
}

echo '</table>';
