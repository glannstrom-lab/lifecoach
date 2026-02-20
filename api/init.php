<?php
/**
 * Comdira Lifecoach - Database Initialization
 * Run this once to set up the database tables
 */

header('Content-Type: application/json');

require_once '../config/database.php';

try {
    initDatabase();
    
    echo json_encode([
        'success' => true,
        'message' => 'Database initialized successfully',
        'tables_created' => [
            'users',
            'checkins',
            'habits',
            'habit_completions',
            'goals',
            'wellness_scores',
            'journal_entries'
        ]
    ]);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to initialize database',
        'message' => $e->getMessage()
    ]);
}
