<?php
/**
 * Comdira Configuration
 * Databas och applikationsinställningar
 */

// Databasinställningar (anpassa efter ditt webbhotell)
define('DB_HOST', 'localhost');
define('DB_NAME', 'comdira_db');
define('DB_USER', 'comdira_user');
define('DB_PASS', 'your_password_here');

// Applikationsinställningar
define('APP_NAME', 'Comdira Lifecoach');
define('APP_URL', 'https://comdira.com'); // Ändra till din domän

// Sessionssäkerhet
session_start();

// Anslut till databasen
function getDB() {
    static $db = null;
    if ($db === null) {
        try {
            $db = new PDO(
                "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
                DB_USER,
                DB_PASS,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        } catch (PDOException $e) {
            die("Database connection failed: " . $e->getMessage());
        }
    }
    return $db;
}

// Hjälpfunktion: Kolla om användare är inloggad
function isLoggedIn() {
    return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
}

// Hjälpfunktion: Omdirigera om inte inloggad
function requireAuth() {
    if (!isLoggedIn()) {
        header('Location: index.php');
        exit;
    }
}

// Hjälpfunktion: Hämta inloggad användare
function getCurrentUser() {
    if (!isLoggedIn()) return null;
    $db = getDB();
    $stmt = $db->prepare("SELECT * FROM users WHERE id = ?");
    $stmt->execute([$_SESSION['user_id']]);
    return $stmt->fetch();
}
?>
