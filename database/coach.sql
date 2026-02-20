-- ============================================================
-- Comdira Coach - Databasschema
-- Komplett databasstruktur for AI-coaching
-- ============================================================

-- ============================================================
-- HUVUDTABELL: coach_sessions
-- ============================================================
CREATE TABLE coach_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    -- Session-typ
    session_type ENUM('holistic', 'goals', 'habits', 'emotional', 'crisis', 'weekly_review', 'goal_check') 
        DEFAULT 'holistic',
    
    -- Session-data
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    duration_minutes INT NULL,
    
    -- Status
    status ENUM('active', 'completed', 'paused') DEFAULT 'active',
    
    -- Sammanfattning
    summary TEXT NULL,
    key_insights JSON NULL,
    action_items JSON NULL,
    
    -- Anvandar-feedback
    user_rating INT NULL, -- 1-5
    user_feedback TEXT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_sessions (user_id, started_at),
    INDEX idx_active (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- CHAT-MEDDELANDEN: coach_messages
-- ============================================================
CREATE TABLE coach_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    
    -- Avsandare
    sender_type ENUM('coach', 'user') NOT NULL,
    
    -- Innehall
    message_text TEXT NOT NULL,
    message_type ENUM('text', 'insight', 'action_item', 'data_card', 'suggestion') DEFAULT 'text',
    
    -- AI-data (for coach-meddelanden)
    ai_confidence DECIMAL(5,2) NULL, -- 0-100%
    data_sources JSON NULL, -- Vilka data kallor anvandes
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (session_id) REFERENCES coach_sessions(id) ON DELETE CASCADE,
    INDEX idx_session_time (session_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI-INSIKTER: coach_ai_insights
-- ============================================================
CREATE TABLE coach_ai_insights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id INT NULL,
    
    -- Insikt-typ
    insight_type ENUM('keystone', 'pattern', 'correlation', 'concern', 'celebration', 'recommendation'),
    
    -- Innehall
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    supporting_data JSON NULL,
    
    -- Forhallande till anvandarens data
    related_goals JSON NULL,
    related_habits JSON NULL,
    related_journal_entries JSON NULL,
    
    -- Status
    is_acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_at TIMESTAMP NULL,
    
    -- Atgard
    suggested_action TEXT NULL,
    action_taken BOOLEAN DEFAULT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES coach_sessions(id) ON DELETE SET NULL,
    INDEX idx_user_insights (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- ACTION PLANS: coach_action_plans
-- ============================================================
CREATE TABLE coach_action_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id INT NULL,
    
    -- Plan-detaljer
    plan_title VARCHAR(255) NOT NULL,
    plan_description TEXT NULL,
    
    -- Tidsram
    start_date DATE NOT NULL,
    end_date DATE NULL,
    
    -- Kopplingar
    related_goal_id INT NULL,
    related_habit_id INT NULL,
    
    -- Status
    status ENUM('active', 'completed', 'abandoned') DEFAULT 'active',
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES coach_sessions(id) ON DELETE SET NULL,
    FOREIGN KEY (related_goal_id) REFERENCES goals(id) ON DELETE SET NULL,
    FOREIGN KEY (related_habit_id) REFERENCES habits(id) ON DELETE SET NULL,
    INDEX idx_user_active (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- ACTION ITEMS: coach_action_items
-- ============================================================
CREATE TABLE coach_action_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plan_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Item-detaljer
    item_text TEXT NOT NULL,
    priority ENUM('high', 'medium', 'low') DEFAULT 'medium',
    
    -- Status
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    
    -- Meta
    suggested_by_coach BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (plan_id) REFERENCES coach_action_plans(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_plan (plan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- COACHING TEMPLATES: coach_templates
-- ============================================================
CREATE TABLE coach_templates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Mall-typ
    template_type ENUM('weekly_review', 'goal_check', 'habit_analysis', 'crisis_support', 'celebration'),
    template_name VARCHAR(255) NOT NULL,
    
    -- Innehall
    opening_message TEXT NOT NULL,
    questions JSON NOT NULL, -- Array av fragor
    data_points_to_analyze JSON NULL, -- Vilka data ska analyseras
    
    -- Aktivering
    is_active BOOLEAN DEFAULT TRUE,
    trigger_condition VARCHAR(255) NULL, -- Nar ska denna mall anvandas
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- USER PREFERENCES: coach_user_preferences
-- ============================================================
CREATE TABLE coach_user_preferences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    
    -- Preferenser
    preferred_coaching_mode ENUM('holistic', 'goals', 'habits', 'emotional') DEFAULT 'holistic',
    coaching_frequency ENUM('daily', 'weekly', 'on_demand') DEFAULT 'on_demand',
    
    -- Notifikationer
    notify_on_insights BOOLEAN DEFAULT TRUE,
    notify_on_patterns BOOLEAN DEFAULT TRUE,
    
    -- Integritet
    data_sharing_level ENUM('minimal', 'full') DEFAULT 'full',
    
    -- Stil
    coaching_tone ENUM('supportive', 'challenging', 'analytical') DEFAULT 'supportive',
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VIEWS FOR ANALYTICS
-- ============================================================

-- Sessions-statistik per anvandare
CREATE VIEW v_coach_session_stats AS
SELECT 
    user_id,
    COUNT(*) as total_sessions,
    AVG(duration_minutes) as avg_duration,
    AVG(user_rating) as avg_rating,
    COUNT(CASE WHEN session_type = 'crisis' THEN 1 END) as crisis_sessions,
    COUNT(CASE WHEN session_type = 'celebration' THEN 1 END) as celebration_sessions
FROM coach_sessions
GROUP BY user_id;

-- Aktiva action plans
CREATE VIEW v_active_action_plans AS
SELECT 
    cap.*,
    COUNT(cai.id) as total_items,
    SUM(CASE WHEN cai.is_completed THEN 1 ELSE 0 END) as completed_items
FROM coach_action_plans cap
LEFT JOIN coach_action_items cai ON cap.id = cai.plan_id
WHERE cap.status = 'active'
GROUP BY cap.id;

-- Insikter som behover atgard
CREATE VIEW v_pending_insights AS
SELECT 
    cai.*,
    DATEDIFF(CURDATE(), cai.created_at) as days_since_created
FROM coach_ai_insights cai
WHERE cai.is_acknowledged = FALSE
ORDER BY cai.created_at DESC;

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER //

-- Uppdatera session duration nar session avslutas
CREATE TRIGGER trg_update_session_duration
BEFORE UPDATE ON coach_sessions
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        SET NEW.ended_at = CURRENT_TIMESTAMP;
        SET NEW.duration_minutes = TIMESTAMPDIFF(MINUTE, OLD.started_at, CURRENT_TIMESTAMP);
    END IF;
END//

-- Skapa notifikation vid ny insikt
CREATE TRIGGER trg_notify_insight
AFTER INSERT ON coach_ai_insights
FOR EACH ROW
BEGIN
    -- Har skulle vi kunna skapa en notifikation
    -- For nu: logga bara
    INSERT INTO coach_messages (session_id, sender_type, message_text, message_type)
    SELECT 
        (SELECT id FROM coach_sessions 
         WHERE user_id = NEW.user_id AND status = 'active' 
         ORDER BY started_at DESC LIMIT 1),
        'coach',
        CONCAT('Ny insikt upptackt: ', NEW.title),
        'insight'
    FROM coach_sessions
    WHERE user_id = NEW.user_id AND status = 'active'
    LIMIT 1;
END//

DELIMITER ;

-- ============================================================
-- EXEMPEL-DATA
-- ============================================================

-- Mallar
INSERT INTO coach_templates (template_type, template_name, opening_message, questions, data_points_to_analyze) VALUES
('weekly_review', 'Veckoreview', 
 'Lat oss ga igenom din vecka och se vad som fungerade bra och vad vi kan forbattra.',
 '["Vad ar du mest stolt over denna vecka?", "Vad var din storsta utmaning?", "Vad vill du fokusera pa nasta vecka?"]',
 '["checkins", "habits", "goals", "journal"]'),

('goal_check', 'Mal-check',
 'Hur gar det med dina mal? Lat oss analysera din framsteg.',
 '["Hur langt har du kommit?", "Vad har fungerat bra?", "Vilka hinder ser du?"]',
 '["goals", "habits"]'),

('crisis_support', 'Akut stod',
 'Jag ser att du kan behova stod. Jag ar har for att hjalpa.',
 '["Vad kanner du just nu?", "Vad skulle hjalpa dig just nu?", "Vilka resurser har du tillgangliga?"]',
 '["recent_checkins", "journal_entries"]');
