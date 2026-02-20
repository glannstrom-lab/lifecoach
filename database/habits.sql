-- ============================================================
-- Comdira Vanor - Databasschema
-- Komplett databasstruktur för vanor med AI-integration
-- ============================================================

-- ============================================================
-- HUVUDTABELL: habits
-- ============================================================
CREATE TABLE habits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    -- Grundinformation
    title VARCHAR(255) NOT NULL,
    description TEXT,
    habit_type ENUM('binary', 'numeric', 'timed', 'contextual') DEFAULT 'binary',
    
    -- Dimension koppling (Wellness Hexagonen)
    dimension ENUM('existential', 'emotional', 'subjective', 'occupational', 'social', 'practical') NULL,
    
    -- Mål-koppling (frivilligt)
    linked_goal_id INT NULL,
    
    -- Numeriska värden
    target_value DECIMAL(10,2) DEFAULT 1,
    unit VARCHAR(50) DEFAULT 'st',
    
    -- Schema (JSON array [1,1,1,1,1,0,0] för mån-sön)
    schedule JSON NOT NULL,
    frequency_type ENUM('daily', 'weekdays', 'weekends', 'custom') DEFAULT 'daily',
    
    -- Flexibilitet
    flexibility_mode ENUM('strict', 'flexible', 'compassion') DEFAULT 'flexible',
    minimum_success_rate DECIMAL(5,2) DEFAULT 80.00, -- För flexible mode
    
    -- Keystone habit flag
    is_keystone BOOLEAN DEFAULT FALSE,
    keystone_trigger_for JSON NULL, -- Array av habit IDs som denna triggerar
    
    -- Rutin-koppling
    routine_id INT NULL,
    routine_order INT DEFAULT 0, -- Ordning inom rutin
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    archived_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (linked_goal_id) REFERENCES goals(id) ON DELETE SET NULL,
    INDEX idx_user_active (user_id, archived_at),
    INDEX idx_dimension (dimension),
    INDEX idx_goal (linked_goal_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DAGLIG LOGG: habit_logs
-- ============================================================
CREATE TABLE habit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    habit_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Datum
    log_date DATE NOT NULL,
    
    -- Status
    status ENUM('completed', 'partial', 'skipped', 'missed') DEFAULT 'missed',
    
    -- Värden för numeriska/tids-vanor
    current_value DECIMAL(10,2) NULL,
    target_value_at_log DECIMAL(10,2) NULL, -- Kan ändras över tid
    
    -- Kontext vid loggning (från check-in)
    mood_at_log INT NULL, -- 1-10 från check-in
    energy_at_log INT NULL, -- 1-10 från check-in
    checkin_id INT NULL,
    
    -- Noteringar
    note TEXT,
    
    -- Rutin-kontext
    was_part_of_routine BOOLEAN DEFAULT FALSE,
    routine_id INT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (checkin_id) REFERENCES daily_checkins(id) ON DELETE SET NULL,
    UNIQUE KEY unique_habit_date (habit_id, log_date),
    INDEX idx_user_date (user_id, log_date),
    INDEX idx_date_range (log_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- STREAK-HISTORIK: habit_streaks
-- ============================================================
CREATE TABLE habit_streaks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    habit_id INT NOT NULL,
    
    -- Streak-information
    streak_start DATE NOT NULL,
    streak_end DATE NULL, -- NULL = pågående
    streak_length INT NOT NULL DEFAULT 0,
    
    -- Typ
    streak_type ENUM('current', 'longest', 'compassion') DEFAULT 'current',
    -- compassion = streak där skippade dagar räknades med compassion
    
    -- Om det var en "perfect" streak (inga skips)
    was_perfect BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    INDEX idx_habit_dates (habit_id, streak_start, streak_end)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- RUTINER: routines
-- ============================================================
CREATE TABLE routines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Trigger för rutinen
    trigger_event VARCHAR(255) NULL, -- "Efter jag vaknar", "Före lunch"
    trigger_time TIME NULL,
    
    -- Färgtema
    color_theme ENUM('morning', 'evening', 'work', 'custom') DEFAULT 'custom',
    
    -- Metadata
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_active (user_id, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- RUTIN-SESSIONER: routine_sessions
-- ============================================================
CREATE TABLE routine_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    routine_id INT NOT NULL,
    user_id INT NOT NULL,
    
    session_date DATE NOT NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    -- Progress
    total_habits INT NOT NULL,
    completed_habits INT DEFAULT 0,
    
    -- Status
    status ENUM('in_progress', 'completed', 'abandoned') DEFAULT 'in_progress',
    
    FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, session_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI-INSIKTER: habit_ai_insights
-- ============================================================
CREATE TABLE habit_ai_insights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    habit_id INT NULL, -- NULL = generell insikt
    
    insight_type ENUM('keystone', 'timing', 'pattern', 'correlation', 'failure_prediction', 'celebration'),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    
    -- Data som stöder insikten
    supporting_data JSON,
    confidence_score DECIMAL(5,2), -- 0-100%
    
    -- Rekommendation
    suggested_action TEXT,
    action_taken BOOLEAN DEFAULT NULL,
    
    -- Feedback
    was_helpful BOOLEAN DEFAULT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    INDEX idx_user_active (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- KEYSTONE-HABIT KOPPLINGAR: habit_keystone_links
-- ============================================================
CREATE TABLE habit_keystone_links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    keystone_habit_id INT NOT NULL,
    triggered_habit_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Korrelations-data
    correlation_strength DECIMAL(5,2), -- 0-100%
    sample_size INT DEFAULT 0, -- Antal observationer
    
    -- Om länken är aktiv/verifierad
    is_verified BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (keystone_habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    FOREIGN KEY (triggered_habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_link (keystone_habit_id, triggered_habit_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- FLEXIBILITET/PAUSER: habit_flexibility_logs
-- ============================================================
CREATE TABLE habit_flexibility_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    habit_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Period
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    
    -- Planerat vs faktiskt
    planned_days INT NOT NULL,
    completed_days INT DEFAULT 0,
    skipped_compassion_days INT DEFAULT 0, -- "Guilt-free" skips
    
    -- Resultat
    actual_success_rate DECIMAL(5,2),
    target_success_rate DECIMAL(5,2),
    
    -- Compassion message som visades
    compassion_message TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_habit_week (habit_id, week_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VIEWS FÖR ANALYTICS
-- ============================================================

-- Aktuell streak för varje vana
CREATE VIEW v_habit_current_streaks AS
SELECT 
    h.id as habit_id,
    h.user_id,
    h.title,
    hs.streak_length,
    hs.streak_start,
    DATEDIFF(CURDATE(), hs.streak_start) + 1 as days_in_streak
FROM habits h
LEFT JOIN habit_streaks hs ON h.id = hs.habit_id 
    AND hs.streak_end IS NULL 
    AND hs.streak_type = 'current'
WHERE h.archived_at IS NULL;

-- Veckovis compliance per vana
CREATE VIEW v_habit_weekly_compliance AS
SELECT 
    hl.habit_id,
    h.user_id,
    h.title,
    YEARWEEK(hl.log_date) as year_week,
    COUNT(*) as total_days,
    SUM(CASE WHEN hl.status = 'completed' THEN 1 ELSE 0 END) as completed_days,
    SUM(CASE WHEN hl.status = 'skipped' THEN 1 ELSE 0 END) as skipped_days,
    ROUND(
        SUM(CASE WHEN hl.status = 'completed' THEN 1 ELSE 0 END) / COUNT(*) * 100, 
        2
    ) as compliance_rate
FROM habit_logs hl
JOIN habits h ON hl.habit_id = h.id
GROUP BY hl.habit_id, YEARWEEK(hl.log_date);

-- Keystone habit analys
CREATE VIEW v_keystone_analysis AS
SELECT 
    hkl.keystone_habit_id,
    kh.title as keystone_title,
    hkl.triggered_habit_id,
    th.title as triggered_title,
    hkl.correlation_strength,
    hkl.sample_size,
    (
        SELECT COUNT(*)
        FROM habit_logs hl1
        JOIN habit_logs hl2 ON hl1.log_date = hl2.log_date 
            AND hl1.user_id = hl2.user_id
        WHERE hl1.habit_id = hkl.keystone_habit_id 
            AND hl2.habit_id = hkl.triggered_habit_id
            AND hl1.status = 'completed'
            AND hl2.status = 'completed'
    ) as co_occurrence_count
FROM habit_keystone_links hkl
JOIN habits kh ON hkl.keystone_habit_id = kh.id
JOIN habits th ON hkl.triggered_habit_id = th.id
WHERE hkl.is_verified = TRUE;

-- Optimal timing per vana
CREATE VIEW v_habit_optimal_timing AS
SELECT 
    hl.habit_id,
    h.title,
    HOUR(hl.created_at) as hour_of_day,
    COUNT(*) as total_logs,
    SUM(CASE WHEN hl.status = 'completed' THEN 1 ELSE 0 END) as completions,
    ROUND(
        SUM(CASE WHEN hl.status = 'completed' THEN 1 ELSE 0 END) / COUNT(*) * 100,
        2
    ) as success_rate_at_hour
FROM habit_logs hl
JOIN habits h ON hl.habit_id = h.id
GROUP BY hl.habit_id, HOUR(hl.created_at)
HAVING success_rate_at_hour > 70 AND total_logs >= 5
ORDER BY hl.habit_id, success_rate_at_hour DESC;

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER //

-- Uppdatera streak när log skapas/uppdateras
CREATE TRIGGER trg_update_streak
AFTER INSERT ON habit_logs
FOR EACH ROW
BEGIN
    DECLARE last_streak_end DATE;
    DECLARE current_streak_id INT;
    
    IF NEW.status = 'completed' THEN
        -- Kolla om det finns en pågående streak
        SELECT id, streak_start INTO current_streak_id, last_streak_end
        FROM habit_streaks
        WHERE habit_id = NEW.habit_id 
            AND streak_end IS NULL 
            AND streak_type = 'current'
        ORDER BY streak_start DESC
        LIMIT 1;
        
        IF current_streak_id IS NOT NULL THEN
            -- Uppdatera befintlig streak
            UPDATE habit_streaks
            SET streak_length = streak_length + 1
            WHERE id = current_streak_id;
        ELSE
            -- Skapa ny streak
            INSERT INTO habit_streaks (
                habit_id, streak_start, streak_length, streak_type, was_perfect
            ) VALUES (
                NEW.habit_id, NEW.log_date, 1, 'current', TRUE
            );
        END IF;
    END IF;
END//

-- Hantera "missed" - avsluta streak
CREATE TRIGGER trg_end_streak_on_miss
AFTER UPDATE ON habit_logs
FOR EACH ROW
BEGIN
    IF OLD.status != 'missed' AND NEW.status = 'missed' THEN
        UPDATE habit_streaks
        SET streak_end = DATE_SUB(NEW.log_date, INTERVAL 1 DAY)
        WHERE habit_id = NEW.habit_id 
            AND streak_end IS NULL 
            AND streak_type = 'current';
    END IF;
END//

-- Auto-skapa AI-insikt vid milestone (7, 30, 52, 100 dagar)
CREATE TRIGGER trg_milestone_celebration
AFTER UPDATE ON habit_streaks
FOR EACH ROW
BEGIN
    IF NEW.streak_length IN (7, 30, 52, 100) AND OLD.streak_length < NEW.streak_length THEN
        INSERT INTO habit_ai_insights (
            user_id, 
            habit_id, 
            insight_type, 
            title, 
            description,
            confidence_score
        )
        SELECT 
            h.user_id,
            h.id,
            'celebration',
            CONCAT('🎉 ', NEW.streak_length, ' dagar av ', h.title, '!'),
            CONCAT('Du har nått ', NEW.streak_length, ' dagar i din streak. Detta är en fantastisk prestation som visar din commitment och disciplin.'),
            100.00
        FROM habits h
        WHERE h.id = NEW.habit_id;
    END IF;
END//

DELIMITER ;

-- ============================================================
-- EXEMPEL-DATA (för utveckling)
-- ============================================================

-- Notera: user_id = 1 antas existera

-- INSERT INTO habits (
--     user_id, title, habit_type, dimension,
--     target_value, unit, schedule, frequency_type,
--     flexibility_mode, is_keystone
-- ) VALUES (
--     1, 'Morgonmeditation', 'timed', 'emotional',
--     10, 'min', '[1,1,1,1,1,1,0]', 'custom',
--     'flexible', TRUE
-- );

-- INSERT INTO habits (
--     user_id, title, habit_type, dimension,
--     target_value, unit, schedule, frequency_type
-- ) VALUES (
--     1, 'Dricka vatten', 'numeric', 'practical',
--     8, 'glas', '[1,1,1,1,1,1,1]', 'daily'
-- );
