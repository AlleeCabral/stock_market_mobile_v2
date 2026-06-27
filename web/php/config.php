<?php
/**
 * Web App Configuration
 * 
 * API Keys and configuration for the Stock Market web app
 */

// Environment
define('ENV', getenv('ENV') ?: 'development');
define('DEBUG', ENV === 'development');

// API Keys (from mobile app config)
define('MARKETSTACK_API_KEY', '3ddb062d21ac3eb2da536681d7afc0ef');
define('NEWSDATA_API_KEY', 'pub_f63e015c14ae4c019531dddf1771fc23');

// Database (optional - for future portfolio persistence)
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_NAME', getenv('DB_NAME') ?: 'stock_market');

// Session Configuration
ini_set('session.name', 'STOCK_MARKET_SESSION');
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_secure', ENV === 'production');
ini_set('session.cookie_samesite', 'Lax');
session_start();

// CORS Headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Error Reporting
if (DEBUG) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(E_ALL);
    ini_set('display_errors', 0);
}

// Utility Functions
function api_error($message, $code = 400) {
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'error' => $message,
        'timestamp' => date('c')
    ]);
    exit;
}

function api_success($data, $message = null) {
    echo json_encode([
        'success' => true,
        'data' => $data,
        'message' => $message,
        'timestamp' => date('c')
    ]);
    exit;
}

// Database Connection (optional)
function get_db() {
    static $db = null;
    if (!$db) {
        try {
            $db = new PDO(
                "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME,
                DB_USER,
                DB_PASS,
                [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
            );
        } catch (PDOException $e) {
            if (DEBUG) {
                api_error('Database connection failed: ' . $e->getMessage(), 500);
            }
        }
    }
    return $db;
}
