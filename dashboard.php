<?php
/**
 * Comdira Lifecoach - Dashboard
 */
require_once 'includes/config.php';
requireAuth(); // Kräv inloggning

$user = getCurrentUser();
$today = date('Y-m-d');

// Hämta dagens check-in (om det finns)
$db = getDB();
$stmt = $db->prepare("SELECT * FROM checkins WHERE user_id = ? AND checkin_date = ?");
$stmt->execute([$_SESSION['user_id'], $today]);
$todayCheckin = $stmt->fetch();

// Hämta aktiva vanor
$stmt = $db->prepare("SELECT * FROM habits WHERE user_id = ? AND is_active = TRUE ORDER BY created_at DESC LIMIT 4");
$stmt->execute([$_SESSION['user_id']]);
$habits = $stmt->fetchAll();

// Hämta aktiva mål
$stmt = $db->prepare("SELECT * FROM goals WHERE user_id = ? AND status = 'active' ORDER BY priority DESC LIMIT 3");
$stmt->execute([$_SESSION['user_id']]);
$goals = $stmt->fetchAll();

// Hämta dagens uppgifter
$stmt = $db->prepare("SELECT * FROM tasks WHERE user_id = ? AND status != 'done' AND (due_date = ? OR due_date IS NULL) ORDER BY priority DESC LIMIT 5");
$stmt->execute([$_SESSION['user_id'], $today]);
$tasks = $stmt->fetchAll();

// Beräkna statistik
$stmt = $db->prepare("SELECT 
    COUNT(*) as total_checkins,
    AVG(mood_score) as avg_mood,
    AVG(energy_score) as avg_energy
FROM checkins WHERE user_id = ? AND checkin_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)");
$stmt->execute([$_SESSION['user_id']]);
$stats = $stmt->fetch();
?>
<!DOCTYPE html>
<html lang="sv">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Comdira Lifecoach</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        /* Dashboard-specifika stilar */
        .welcome-banner {
            background: linear-gradient(135deg, var(--primary-light), var(--accent-light));
            border-radius: var(--radius-lg);
            padding: var(--space-xl);
            margin-bottom: var(--space-xl);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .welcome-text h2 {
            font-size: 1.5rem;
            color: var(--text-primary);
            margin-bottom: var(--space-xs);
        }
        
        .welcome-text p {
            color: var(--text-secondary);
        }
        
        .welcome-date {
            text-align: right;
        }
        
        .welcome-date .day {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-dark);
        }
        
        .welcome-date .month {
            color: var(--text-secondary);
            text-transform: capitalize;
        }
        
        /* Check-in sektion */
        .checkin-section {
            margin-bottom: var(--space-xl);
        }
        
        .checkin-card {
            background: var(--bg-surface);
            border-radius: var(--radius-lg);
            padding: var(--space-xl);
            border: 2px dashed var(--primary-light);
            text-align: center;
        }
        
        .checkin-card.completed {
            border-style: solid;
            border-color: var(--primary);
            background: linear-gradient(135deg, var(--bg-surface), var(--primary-light));
        }
        
        .checkin-title {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: var(--space-md);
        }
        
        .mood-selector {
            display: flex;
            justify-content: center;
            gap: var(--space-md);
            margin: var(--space-lg) 0;
        }
        
        .mood-btn {
            width: 48px;
            height: 48px;
            border-radius: var(--radius-full);
            border: 2px solid var(--primary-light);
            background: var(--bg-surface);
            cursor: pointer;
            transition: all var(--transition-fast);
            font-size: 1.5rem;
        }
        
        .mood-btn:hover {
            transform: scale(1.1);
            border-color: var(--primary);
        }
        
        .mood-btn.selected {
            background: var(--primary);
            border-color: var(--primary);
        }
        
        /* Vanor grid */
        .habits-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--space-lg);
        }
        
        .habit-item {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            padding: var(--space-md);
            background: var(--bg-card);
            border-radius: var(--radius-md);
            border: 1px solid var(--primary-light);
        }
        
        .habit-checkbox {
            width: 28px;
            height: 28px;
            border-radius: var(--radius-sm);
            border: 2px solid var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all var(--transition-fast);
        }
        
        .habit-checkbox.checked {
            background: var(--primary);
        }
        
        .habit-checkbox svg {
            width: 16px;
            height: 16px;
            color: white;
            opacity: 0;
        }
        
        .habit-checkbox.checked svg {
            opacity: 1;
        }
        
        .habit-info {
            flex: 1;
        }
        
        .habit-name {
            font-weight: 600;
            color: var(--text-primary);
            font-size: 0.9rem;
        }
        
        .habit-streak {
            font-size: 0.75rem;
            color: var(--text-light);
        }
        
        /* Snabba uppgifter */
        .task-list {
            list-style: none;
        }
        
        .task-item {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            padding: var(--space-md);
            border-bottom: 1px solid var(--primary-light);
            transition: background var(--transition-fast);
        }
        
        .task-item:last-child {
            border-bottom: none;
        }
        
        .task-item:hover {
            background: var(--primary-light);
            border-radius: var(--radius-md);
        }
        
        .task-priority {
            width: 8px;
            height: 8px;
            border-radius: var(--radius-full);
        }
        
        .task-priority.high { background: var(--error); }
        .task-priority.medium { background: var(--warning); }
        .task-priority.low { background: var(--success); }
        
        .task-title {
            flex: 1;
            color: var(--text-primary);
        }
        
        /* Kalender widget */
        .calendar-widget {
            text-align: center;
        }
        
        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-md);
        }
        
        .calendar-title {
            font-weight: 600;
            color: var(--text-primary);
        }
        
        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: var(--space-xs);
        }
        
        .calendar-day {
            aspect-ratio: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.875rem;
            border-radius: var(--radius-sm);
            color: var(--text-secondary);
        }
        
        .calendar-day.today {
            background: var(--primary);
            color: white;
            font-weight: 600;
        }
        
        .calendar-day.has-data {
            position: relative;
        }
        
        .calendar-day.has-data::after {
            content: '';
            position: absolute;
            bottom: 2px;
            width: 4px;
            height: 4px;
            background: var(--primary-dark);
            border-radius: var(--radius-full);
        }
        
        /* Progress ring stor */
        .progress-large {
            width: 120px;
            height: 120px;
            margin: 0 auto;
        }
        
        .progress-large .progress-text {
            font-size: 2rem;
        }
    </style>
</head>
<body>
    <div class="app-container">
        <!-- Sidomeny -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo">
                    <div class="logo-icon">C</div>
                    <span class="logo-text">Comdira</span>
                </div>
            </div>
            
            <nav class="nav-menu">
                <a href="dashboard.php" class="nav-item active">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                    <span>Dashboard</span>
                </a>
                <a href="#" class="nav-item">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                    <span>Dagens Check-in</span>
                </a>
                <a href="#" class="nav-item">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                    <span>Mina Mål</span>
                </a>
                <a href="#" class="nav-item">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    <span>Vanor</span>
                </a>
                <a href="#" class="nav-item">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                    <span>Journal</span>
                </a>
                <a href="#" class="nav-item">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                    <span>Coach</span>
                </a>
                <a href="#" class="nav-item">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                    <span>Uppgifter</span>
                </a>
            </nav>
            
            <div class="sidebar-footer">
                <a href="#" class="nav-item">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
                    <span>Inställningar</span>
                </a>
                <div class="user-menu">
                    <div class="user-avatar"><?= strtoupper(substr($user['first_name'], 0, 1)) ?></div>
                    <div class="user-info">
                        <div class="user-name"><?= htmlspecialchars($user['first_name'] . ' ' . $user['last_name']) ?></div>
                        <div class="user-role">Medlem</div>
                    </div>
                </div>
            </div>
        </aside>
        
        <!-- Huvudinnehåll -->
        <main class="main-content">
            <!-- Välkomstbanner -->
            <div class="welcome-banner">
                <div class="welcome-text">
                    <h2>Hej, <?= htmlspecialchars($user['first_name']) ?>! 👋</h2>
                    <p>Vad vill du fokusera på idag?</p>
                </div>
                <div class="welcome-date">
                    <div class="day"><?= date('j') ?></div>
                    <div class="month"><?= date('F Y') ?></div>
                </div>
            </div>
            
            <!-- Dashboard Grid -->
            <div class="dashboard-grid">
                <!-- Check-in kort -->
                <div class="card checkin-section">
                    <div class="card-header">
                        <h3 class="card-title">Dagens Check-in</h3>
                        <span class="stat-trend up">+12% från igår</span>
                    </div>
                    <div class="checkin-card <?= $todayCheckin ? 'completed' : '' ?>">
                        <?php if ($todayCheckin): ?>
                            <div class="checkin-title">✓ Dagens check-in gjord!</div>
                            <p>Humör: <?= $todayCheckin['mood_score'] ?>/10 | Energi: <?= $todayCheckin['energy_score'] ?>/10</p>
                        <?php else: ?>
                            <div class="checkin-title">Hur mår du idag?</div>
                            <div class="mood-selector">
                                <button class="mood-btn" title="Mycket dåligt">😔</button>
                                <button class="mood-btn" title="Dåligt">😕</button>
                                <button class="mood-btn" title="Okej">😐</button>
                                <button class="mood-btn" title="Bra">🙂</button>
                                <button class="mood-btn" title="Mycket bra">😊</button>
                            </div>
                            <button class="btn btn-primary">Spara Check-in</button>
                        <?php endif; ?>
                    </div>
                </div>
                
                <!-- Veckostatistik -->
                <div class="card stat-card">
                    <div class="stat-header">
                        <div class="stat-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                        </div>
                        <span class="stat-trend up">+8%</span>
                    </div>
                    <div class="stat-value"><?= number_format($stats['avg_mood'] ?? 0, 1) ?></div>
                    <div class="stat-label">Genomsnittligt humör (7 dagar)</div>
                </div>
                
                <!-- Vanor -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Dina Vanor</h3>
                        <a href="#" class="btn btn-ghost">Se alla</a>
                    </div>
                    <div class="habits-grid">
                        <?php foreach ($habits as $habit): ?>
                        <div class="habit-item">
                            <div class="habit-checkbox">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                            </div>
                            <div class="habit-info">
                                <div class="habit-name"><?= htmlspecialchars($habit['title']) ?></div>
                                <div class="habit-streak">🔥 5 dagar i rad</div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                        <?php if (empty($habits)): ?>
                        <p style="color: var(--text-light); text-align: center;">Inga vanor än. <a href="#">Skapa din första vana</a></p>
                        <?php endif; ?>
                    </div>
                </div>
                
                <!-- Kalender -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Kalender</h3>
                    </div>
                    <div class="calendar-widget">
                        <div class="calendar-header">
                            <button class="btn btn-ghost">←</button>
                            <span class="calendar-title"><?= date('F Y') ?></span>
                            <button class="btn btn-ghost">→</button>
                        </div>
                        <div class="calendar-grid">
                            <div class="calendar-day">M</div>
                            <div class="calendar-day">T</div>
                            <div class="calendar-day">O</div>
                            <div class="calendar-day">T</div>
                            <div class="calendar-day">F</div>
                            <div class="calendar-day">L</div>
                            <div class="calendar-day">S</div>
                            <?php
                            // Enkel kalender för denna månad
                            $daysInMonth = date('t');
                            $firstDay = date('N', strtotime(date('Y-m-01')));
                            
                            // Tomma dagar i början
                            for ($i = 1; $i < $firstDay; $i++) {
                                echo '<div class="calendar-day"></div>';
                            }
                            
                            // Dagar
                            for ($day = 1; $day <= $daysInMonth; $day++) {
                                $class = 'calendar-day';
                                if ($day == date('j')) $class .= ' today';
                                echo "<div class=\"$class\">$day</div>";
                            }
                            ?>
                        </div>
                    </div>
                </div>
                
                <!-- Aktiva mål -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Aktiva Mål</h3>
                        <a href="#" class="btn btn-ghost">+ Nytt</a>
                    </div>
                    <?php if (empty($goals)): ?>
                    <p style="color: var(--text-light);">Inga aktiva mål. <a href="#">Skapa ett mål</a> för att komma igång!</p>
                    <?php else: ?>
                    <?php foreach ($goals as $goal): ?>
                    <div style="margin-bottom: var(--space-lg);">
                        <div style="display: flex; justify-content: space-between; margin-bottom: var(--space-sm);">
                            <span style="font-weight: 500;"><?= htmlspecialchars($goal['title']) ?></span>
                            <span style="color: var(--text-light);"><?= $goal['progress_percent'] ?>%</span>
                        </div>
                        <div style="background: var(--primary-light); height: 8px; border-radius: var(--radius-full); overflow: hidden;">
                            <div style="background: linear-gradient(90deg, var(--primary), var(--accent)); height: 100%; width: <?= $goal['progress_percent'] ?>%; border-radius: var(--radius-full); transition: width 0.5s ease;"></div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                    <?php endif; ?>
                </div>
                
                <!-- Dagens uppgifter -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Dagens Uppgifter</h3>
                        <span class="stat-trend" style="background: var(--primary-light); color: var(--text-secondary);"><?= count($tasks) ?> kvar</span>
                    </div>
                    <ul class="task-list">
                        <?php foreach ($tasks as $task): ?>
                        <li class="task-item">
                            <span class="task-priority <?= $task['priority'] ?>"></span>
                            <span class="task-title"><?= htmlspecialchars($task['title']) ?></span>
                        </li>
                        <?php endforeach; ?>
                        <?php if (empty($tasks)): ?>
                        <li style="color: var(--text-light); text-align: center; padding: var(--space-lg);">🎉 Alla uppgifter klara för idag!</li>
                        <?php endif; ?>
                    </ul>
                </div>
                
                <!-- Veckans framsteg -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Veckans Framsteg</h3>
                    </div>
                    <div class="progress-ring progress-large">
                        <svg width="120" height="120">
                            <circle class="progress-ring-bg" cx="60" cy="60" r="52"/>
                            <circle class="progress-ring-fill" cx="60" cy="60" r="52" 
                                    stroke-dasharray="326.73" 
                                    stroke-dashoffset="98.02"/>
                        </svg>
                        <div class="progress-text">70%</div>
                    </div>
                    <p style="text-align: center; color: var(--text-secondary); margin-top: var(--space-md);">Bra jobbat! Du är på rätt väg.</p>
                </div>
            </div>
        </main>
    </div>
    
    <script src="assets/js/app.js"></script>
</body>
</html>
