-- ============================================================
-- Comdira Mina Mål - Databasschema
-- Komplett databasstruktur för målhantering med AI-integration
-- ============================================================

-- ============================================================
-- HUVUDTABELL: goals
-- ============================================================
CREATE TABLE goals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    -- Grundinformation
    title VARCHAR(255) NOT NULL,
    description TEXT,
    goal_type ENUM('smart', 'value_based', 'energy_based', 'process') DEFAULT 'smart',
    
    -- Dimension koppling (Wellness Hexagonen)
    dimension ENUM('existential', 'emotional', 'subjective', 'occupational', 'social', 'practical') NULL,
    
    -- Mätbara värden
    target_value DECIMAL(10,2) NOT NULL,
    current_value DECIMAL(10,2) DEFAULT 0,
    unit VARCHAR(50) NOT NULL,
    
    -- Tidsaspekter
    start_date DATE NOT NULL,
    deadline DATE,
    
    -- Energipåverkan
    energy_impact ENUM('boost', 'maintain', 'drain') DEFAULT 'maintain',
    
    -- SMART kriterier
    is_specific BOOLEAN DEFAULT FALSE,
    is_measurable BOOLEAN DEFAULT FALSE,
    is_achievable BOOLEAN DEFAULT FALSE,
    is_relevant BOOLEAN DEFAULT FALSE,
    is_timebound BOOLEAN DEFAULT FALSE,
    
    -- Status
    status ENUM('active', 'completed', 'paused', 'abandoned') DEFAULT 'active',
    
    -- Streak tracking
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    last_checkin_date DATE,
    
    -- AI & Analytics
    ai_suggestion TEXT,
    success_probability DECIMAL(5,2), -- 0-100%
    predicted_completion_date DATE,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_status (user_id, status),
    INDEX idx_deadline (deadline),
    INDEX idx_dimension (dimension)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- MILESTOLPAR: goal_milestones
-- ============================================================
CREATE TABLE goal_milestones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    goal_id INT NOT NULL,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    target_value DECIMAL(10,2) NOT NULL,
    
    -- Status
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    
    -- Celebration
    celebration_note TEXT,
    
    -- Ordning
    sort_order INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    INDEX idx_goal_order (goal_id, sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PROGRESS-LOGG: goal_progress_log
-- ============================================================
CREATE TABLE goal_progress_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    goal_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Progress-data
    old_value DECIMAL(10,2),
    new_value DECIMAL(10,2),
    change_amount DECIMAL(10,2),
    
    -- Kontext
    note TEXT,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Koppling till check-in
    checkin_id INT NULL,
    
    -- Energi vid loggning (från dagens check-in)
    mood_at_log INT NULL,
    energy_at_log INT NULL,
    
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (checkin_id) REFERENCES daily_checkins(id) ON DELETE SET NULL,
    INDEX idx_goal_date (goal_id, logged_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VINNARE / ACHIEVEMENTS: goal_wins
-- ============================================================
CREATE TABLE goal_wins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    goal_id INT NULL, -- NULL för icke-mål-relaterade vinster
    
    -- Vinst-information
    win_type ENUM('milestone', 'goal_completed', 'streak', 'personal_best', 'consistency', 'comeback'),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    emoji VARCHAR(10) DEFAULT '🏆',
    
    -- Datum
    achieved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Delning
    is_shared_with_buddy BOOLEAN DEFAULT FALSE,
    buddy_message TEXT,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE SET NULL,
    INDEX idx_user_date (user_id, achieved_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- MÅL-KOMPISAR: goal_buddies
-- ============================================================
CREATE TABLE goal_buddies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    buddy_user_id INT NOT NULL,
    
    -- Status
    status ENUM('pending', 'active', 'ended') DEFAULT 'pending',
    
    -- Delade mål
    shared_goal_id INT NULL,
    
    -- Metadata
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (buddy_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_goal_id) REFERENCES goals(id) ON DELETE SET NULL,
    UNIQUE KEY unique_buddy_pair (user_id, buddy_user_id),
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- BUDDY-MEDDELANDEN: buddy_messages
-- ============================================================
CREATE TABLE buddy_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    buddy_relationship_id INT NOT NULL,
    sender_id INT NOT NULL,
    
    message TEXT NOT NULL,
    
    -- Typ av meddelande
    message_type ENUM('encouragement', 'milestone_celebration', 'check_in', 'goal_suggestion') DEFAULT 'encouragement',
    
    -- Läst-status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (buddy_relationship_id) REFERENCES goal_buddies(id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_relationship (buddy_relationship_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI-INSIKTER: goal_ai_insights
-- ============================================================
CREATE TABLE goal_ai_insights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    goal_id INT NULL,
    
    -- Insikt
    insight_type ENUM('pattern', 'suggestion', 'prediction', 'correlation', 'celebration'),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    
    -- Data som stöder insikten
    supporting_data JSON,
    
    -- Åtgärd
    suggested_action TEXT,
    action_taken BOOLEAN DEFAULT NULL, -- NULL = inte än, TRUE = ja, FALSE = nej
    
    -- Feedback
    was_helpful BOOLEAN DEFAULT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL, -- Vissa insikter blir irrelevanta över tid
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    INDEX idx_user_active (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PAUSER / COMPASSION BREAKS: goal_pauses
-- ============================================================
CREATE TABLE goal_pauses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    goal_id INT NOT NULL,
    
    -- Paus-information
    reason TEXT,
    is_compassion_break BOOLEAN DEFAULT TRUE, -- Ingen skuld-paus
    
    -- Tider
    paused_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resumed_at TIMESTAMP NULL,
    planned_resume_date DATE NULL,
    
    -- Status vid paus
    streak_at_pause INT DEFAULT 0,
    progress_at_pause DECIMAL(5,2) DEFAULT 0,
    
    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    INDEX idx_goal_dates (goal_id, paused_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VIEWS FÖR ANALYTICS
-- ============================================================

-- Aktiva mål med full info
CREATE VIEW v_active_goals AS
SELECT 
    g.*,
    DATEDIFF(g.deadline, CURDATE()) as days_remaining,
    (g.current_value / g.target_value * 100) as actual_progress,
    COUNT(DISTINCT gm.id) as total_milestones,
    SUM(CASE WHEN gm.is_completed THEN 1 ELSE 0 END) as completed_milestones
FROM goals g
LEFT JOIN goal_milestones gm ON g.id = gm.goal_id
WHERE g.status = 'active'
GROUP BY g.id;

-- Mål-success-rate per dimension
CREATE VIEW v_goal_success_by_dimension AS
SELECT 
    dimension,
    COUNT(*) as total_goals,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_goals,
    AVG(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) * 100 as success_rate,
    AVG(current_value / target_value * 100) as avg_progress
FROM goals
GROUP BY dimension;

-- Veckovis aktivitet för heatmap
CREATE VIEW v_weekly_goal_activity AS
SELECT 
    user_id,
    YEAR(logged_at) as year,
    WEEK(logged_at) as week,
    COUNT(*) as activity_count,
    AVG(change_amount) as avg_progress_change
FROM goal_progress_log
GROUP BY user_id, YEAR(logged_at), WEEK(logged_at);

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Uppdatera updated_at vid ändring
DELIMITER //

CREATE TRIGGER trg_goals_updated
BEFORE UPDATE ON goals
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
    
    -- Om målet blir completed
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        SET NEW.completed_at = CURRENT_TIMESTAMP;
        
        -- Lägg till win
        INSERT INTO goal_wins (user_id, goal_id, win_type, title, emoji, achieved_at)
        VALUES (NEW.user_id, NEW.id, 'goal_completed', CONCAT('Avklarat: ', NEW.title), '🎯', CURRENT_TIMESTAMP);
    END IF;
END//

-- Logga progress automatiskt
CREATE TRIGGER trg_progress_logged
AFTER UPDATE ON goals
FOR EACH ROW
BEGIN
    IF NEW.current_value != OLD.current_value THEN
        INSERT INTO goal_progress_log (
            goal_id, user_id, old_value, new_value, 
            change_amount, logged_at
        ) VALUES (
            NEW.id, NEW.user_id, OLD.current_value, NEW.current_value,
            NEW.current_value - OLD.current_value, CURRENT_TIMESTAMP
        );
    END IF;
END//

-- Milestone completion
CREATE TRIGGER trg_milestone_completed
AFTER UPDATE ON goal_milestones
FOR EACH ROW
BEGIN
    IF NEW.is_completed = TRUE AND OLD.is_completed = FALSE THEN
        -- Lägg till win för milestone
        INSERT INTO goal_wins (user_id, goal_id, win_type, title, emoji, achieved_at)
        SELECT 
            g.user_id, g.id, 'milestone', 
            CONCAT('Milstolpe: ', NEW.title), 
            '⭐', 
            CURRENT_TIMESTAMP
        FROM goals g
        WHERE g.id = NEW.goal_id;
    END IF;
END//

DELIMITER ;

-- ============================================================
-- EXEMPEL-DATA (för utveckling)
-- ============================================================

-- Notera: user_id = 1 antas existera

-- INSERT INTO goals (
--     user_id, title, description, dimension,
--     target_value, current_value, unit,
--     start_date, deadline,
--     energy_impact,
--     is_specific, is_measurable, is_achievable, is_relevant, is_timebound,
--     current_streak, longest_streak, last_checkin_date
-- ) VALUES (
--     1, 'Springa 5km', 'Bygga kondition för bättre hälsa', 'practical',
--     5.0, 3.75, 'km',
--     '2026-01-01', '2026-04-15',
--     'boost',
--     TRUE, TRUE, TRUE, TRUE, TRUE,
--     12, 15, '2026-02-19'
-- );
