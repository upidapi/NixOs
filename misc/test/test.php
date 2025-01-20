<?php

$path = rtrim($_GET["path"], "/");

if ($path === "") {
    $path = "/";
}

chdir("/");

if (is_dir($path)) {
    foreach (scandir($path) as $file) {
        echo "<a href='" . (($path === "/") ? $file : "/$path/$file") . "'>$file</a><br>";
    }
    die;
}

$content = @file_get_contents($path);

if ($content === false) {
    echo "Cannot open file $path";
    die;
}

if (strpos($content, "SSM") !== false) {
    http_response_code(403);
    echo "Redacted";
    die;
} else {
    header("Content-Type: text/plain");
    echo $content;
}
