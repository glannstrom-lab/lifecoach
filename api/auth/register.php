<?php
/**
 * Comdira Lifecoach - Register API
 * POST /api/auth/register
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../config/database.php';
require_once '../../config/jwt.php';

// Only allow POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

// Get input data
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    $input = $_POST;
}

$name = isset($input['name']) ? trim($input['name']) : '';
$email = isset($input['email']) ? trim($input['email']) : '';
$password = isset($input['password']) ? $input['password'] : '';

// Validate input
if (empty($name) || empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['error' => 'Name, email and password are required']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid email format']);
    exit;
}

if (strlen($password) < 8) {
    http_response_code(400);
    echo json_encode(['error' => 'Password must be at least 8 characters']);
    exit;
}

if (strlen($name) < 2 || strlen($name) > 100) {
    http_response_code(400);
    echo json_encode(['error' => 'Name must be between 2 and 100 characters']);
    exit;
}

try {
    $db = getDB();
    
    // Check if email already exists
    $stmt = $db->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['error' => 'Email already registered']);
        exit;
    }
    
    // Hash password
    $passwordHash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    
    // Create user
    $stmt = $db->prepare("INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)");
    $stmt->execute([$name, $email, $passwordHash]);
    
    $userId = $db->lastInsertId();
    
    // Generate JWT token
    $token = generateJWT([
        'user_id' => $userId,
        'email' => $email,
        'name' => $name
    ]);
    
    // Create default habits for new user
    $defaultHabits = [
        ['name' => 'Morgonmeditation', 'icon' => '🧘', 'description' => 'Starta dagen med 5 minuter meditation'],
        ['name' => 'Dricka vatten', 'icon' => '💧', 'description' => 'Drick minst 8 glas vatten'],
        ['name' => 'Daglig promenad', 'icon' => '🚶', 'description' => 'Gå minst 30 minuter'],
    ];
    
    $stmt = $db->prepare("INSERT INTO habits (user_id, name, icon, description) VALUES (?, ?, ?, ?)");
    foreach ($defaultHabits as $habit) {
        $stmt->execute([$userId, $habit['name'], $habit['icon'], $habit['description']]);
    }
    
    // Return success response
    echo json_encode([
        'success' => true,
        'message' => 'Registration successful',
        'token' => $token,
        'user' => [
            'id' => $userId,
            'email' => $email,
            'name' => $name
        ]
    ]);
    
} catch (PDOException $e) {
    error_log("Registration error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Database error occurred']);
}
