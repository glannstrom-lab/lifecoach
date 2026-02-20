<?php
/**
 * Comdira Lifecoach - Dashboard Data API
 * GET /api/user/dashboard
 * Returns all data needed for the dashboard
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once '../../config/database.php';
require_once '../../config/jwt.php';

// Only allow GET requests
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

// Authenticate user
$user = requireAuth();
$userId = $user['user_id'];

try {
    $db = getDB();
    
    // Get today's check-in
    $today = date('Y-m-d');
    $stmt = $db->prepare("SELECT mood, energy, notes FROM checkins WHERE user_id = ? AND date = ?");
    $stmt->execute([$userId, $today]);
    $todayCheckin = $stmt->fetch();
    
    // Get latest check-in (for yesterday's mood)
    $stmt = $db->prepare("SELECT mood FROM checkins WHERE user_id = ? AND date < ? ORDER BY date DESC LIMIT 1");
    $stmt->execute([$userId, $today]);
    $yesterdayMood = $stmt->fetchColumn();
    
    // Get habits with streaks
    $stmt = $db->prepare("
        SELECT 
            h.id,
            h.name,
            h.icon,
            h.description,
            h.color,
            (
                SELECT COUNT(*) 
                FROM habit_completions hc 
                WHERE hc.habit_id = h.id 
                AND hc.completed = 1
            ) as total_completions,
            (
                SELECT COUNT(*) 
                FROM habit_completions hc 
                WHERE hc.habit_id = h.id 
                AND hc.date = ?
                AND hc.completed = 1
            ) as completed_today
        FROM habits h 
        WHERE h.user_id = ? AND h.active = 1
        ORDER BY h.created_at DESC
    ");
    $stmt->execute([$today, $userId]);
    $habits = $stmt->fetchAll();
    
    // Calculate streak for each habit
    foreach ($habits as &$habit) {
        $stmt = $db->prepare("
            SELECT date FROM habit_completions 
            WHERE habit_id = ? AND completed = 1 
            ORDER BY date DESC
        ");
        $stmt->execute([$habit['id']]);
        $dates = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        $streak = 0;
        $checkDate = new DateTime($today);
        
        foreach ($dates as $date) {
            $completionDate = new DateTime($date);
            $diff = $checkDate->diff($completionDate)->days;
            
            if ($diff <= 1) {
                $streak++;
                $checkDate = $completionDate;
            } else {
                break;
            }
        }
        
        $habit['streak'] = $streak;
    }
    
    // Get active goals
    $stmt = $db->prepare("
        SELECT id, title, description, target_value, current_value, unit, deadline
        FROM goals 
        WHERE user_id = ? AND completed = 0
        ORDER BY deadline ASC
        LIMIT 5
    ");
    $stmt->execute([$userId]);
    $goals = $stmt->fetchAll();
    
    // Calculate progress percentage for goals
    foreach ($goals as &$goal) {
        $goal['progress'] = $goal['target_value'] > 0 
            ? round(($goal['current_value'] / $goal['target_value']) * 100) 
            : 0;
    }
    
    // Get wellness scores for hexagon
    $stmt = $db->prepare("
        SELECT dimension, score
        FROM wellness_scores
        WHERE user_id = ?
        ORDER BY date DESC
        LIMIT 6
    ");
    $stmt->execute([$userId]);
    $wellnessScores = $stmt->fetchAll();
    
    // Default wellness scores if none exist
    if (empty($wellnessScores)) {
        $wellnessScores = [
            ['dimension' => 'existentiellt', 'score' => 7],
            ['dimension' => 'emotionellt', 'score' => 8],
            ['dimension' => 'subjektivt', 'score' => 6],
            ['dimension' => 'yrkesmassigt', 'score' => 8],
            ['dimension' => 'socialt', 'score' => 7],
            ['dimension' => 'vardagligt', 'score' => 9],
        ];
    }
    
    // Get journal entry count
    $stmt = $db->prepare("SELECT COUNT(*) FROM journal_entries WHERE user_id = ?");
    $stmt->execute([$userId]);
    $journalCount = $stmt->fetchColumn();
    
    // Get tasks/goals count
    $tasksCount = count($goals);
    
    // Build response
    $dashboard = [
        'user' => [
            'id' => $userId,
            'name' => $user['name'],
            'email' => $user['email']
        ],
        'today' => [
            'date' => $today,
            'checkin' => $todayCheckin,
            'yesterday_mood' => $yesterdayMood ?: null
        ],
        'habits' => [
            'items' => $habits,
            'count' => count($habits),
            'completed_today' => array_sum(array_column($habits, 'completed_today'))
        ],
        'goals' => [
            'items' => $goals,
            'count' => $tasksCount
        ],
        'wellness' => [
            'scores' => $wellnessScores
        ],
        'journal' => [
            'total_entries' => (int)$journalCount
        ],
        'calendar' => [
            'tasks_today' => $tasksCount
        ]
    ];
    
    echo json_encode([
        'success' => true,
        'data' => $dashboard
    ]);
    
} catch (PDOException $e) {
    error_log("Dashboard error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Database error occurred']);
}
