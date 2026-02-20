<?php
/**
 * Comdira Lifecoach - JWT Authentication
 * Simple JWT implementation for API authentication
 */

// JWT Secret - CHANGE THIS TO A STRONG RANDOM STRING
define('JWT_SECRET', 'your-super-secret-jwt-key-change-this-in-production');
define('JWT_ISSUER', 'comdira-lifecoach');
define('JWT_AUDIENCE', 'comdira-users');
define('JWT_EXPIRATION', 86400 * 7); // 7 days

/**
 * Generate JWT token
 * @param array $payload User data to encode
 * @return string JWT token
 */
function generateJWT($payload) {
    $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
    
    $time = time();
    $payload['iat'] = $time;
    $payload['exp'] = $time + JWT_EXPIRATION;
    $payload['iss'] = JWT_ISSUER;
    $payload['aud'] = JWT_AUDIENCE;
    
    $payload = json_encode($payload);
    
    $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
    
    $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, JWT_SECRET, true);
    $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
    
    return $base64Header . "." . $base64Payload . "." . $base64Signature;
}

/**
 * Validate and decode JWT token
 * @param string $token JWT token
 * @return array|false Decoded payload or false if invalid
 */
function validateJWT($token) {
    $parts = explode('.', $token);
    
    if (count($parts) !== 3) {
        return false;
    }
    
    list($base64Header, $base64Payload, $base64Signature) = $parts;
    
    // Verify signature
    $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, JWT_SECRET, true);
    $validSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
    
    if (!hash_equals($validSignature, $base64Signature)) {
        return false;
    }
    
    // Decode payload
    $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $base64Payload)), true);
    
    if (!$payload) {
        return false;
    }
    
    // Check expiration
    if (isset($payload['exp']) && $payload['exp'] < time()) {
        return false;
    }
    
    // Check issuer and audience
    if (isset($payload['iss']) && $payload['iss'] !== JWT_ISSUER) {
        return false;
    }
    
    if (isset($payload['aud']) && $payload['aud'] !== JWT_AUDIENCE) {
        return false;
    }
    
    return $payload;
}

/**
 * Get Authorization header
 * @return string|null
 */
function getAuthorizationHeader() {
    $headers = null;
    
    if (isset($_SERVER['Authorization'])) {
        $headers = trim($_SERVER['Authorization']);
    } elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $headers = trim($_SERVER['HTTP_AUTHORIZATION']);
    } elseif (function_exists('apache_request_headers')) {
        $requestHeaders = apache_request_headers();
        if (isset($requestHeaders['Authorization'])) {
            $headers = trim($requestHeaders['Authorization']);
        }
    }
    
    return $headers;
}

/**
 * Get Bearer token from request
 * @return string|false
 */
function getBearerToken() {
    $headers = getAuthorizationHeader();
    
    if (!empty($headers)) {
        if (preg_match('/Bearer\s+(\S+)/', $headers, $matches)) {
            return $matches[1];
        }
    }
    
    return false;
}

/**
 * Authenticate request
 * @return array|false User data or false if not authenticated
 */
function authenticate() {
    $token = getBearerToken();
    
    if (!$token) {
        // Also check POST/GET for token (for form submissions)
        if (isset($_POST['token'])) {
            $token = $_POST['token'];
        } elseif (isset($_GET['token'])) {
            $token = $_GET['token'];
        }
    }
    
    if (!$token) {
        return false;
    }
    
    return validateJWT($token);
}

/**
 * Require authentication
 * Sends 401 response if not authenticated
 * @return array User data
 */
function requireAuth() {
    $user = authenticate();
    
    if (!$user) {
        http_response_code(401);
        echo json_encode(['error' => 'Unauthorized', 'message' => 'Invalid or expired token']);
        exit;
    }
    
    return $user;
}
