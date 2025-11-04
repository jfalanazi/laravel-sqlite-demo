<?php
// Simple router for PHP built-in server to make Laravel routes work.

// Decode URI
$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

// Serve existing static files from /public as-is
if ($uri !== '/' && file_exists(__DIR__ . '/public' . $uri)) {
    return false;
}

// Otherwise, hand off to Laravel front controller
require __DIR__ . '/public/index.php';
