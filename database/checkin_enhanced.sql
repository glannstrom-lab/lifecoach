-- Förbättrad Check-in modul för Comdira
-- Innehåller: Morgon/Kväll, 5 dimensioner, AI-insikter, Streaks

-- Huvudtabell för Check-ins
CREATE TABLE checkins_enhanced (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    checkin_date DATE NOT NULL,
    checkin_type ENUM('morning', 'evening') NOT NULL DEFAULT 'morning',
    
    -- Fem dimensioner (1-10 skala)
    mood_score INT CHECK (mood_score BETWEEN 1 AND 10),
    energy_score INT CHECK (energy_score BETWEEN 1 AND 10),
    focus_score INT CHECK (focus_score BETWEEN 1 AND 10),
    sleep_score INT CHECK (sleep_score BETWEEN 1 AND 10),
    stress_score INT CHECK (stress_score BETWEEN 1 AND 10),
    
    -- Öppna frågor
    gratitude_text TEXT COMMENT 'Vad är du tacksam för?',
    intention_text TEXT COMMENT 'Dagens intention (morgon)',
    reflection_text TEXT COMMENT 'Dagens reflektion (kväll)',
    energy_drain VARCHAR(255) COMMENT 'Vad tar energi?',
    energy_boost VARCHAR(255) COMMENT 'Vad ger energi?',
    
    -- AI-genererad analys
    ai_insight TEXT COMMENT 'AI-genererad insikt',
    ai_recommendation TEXT COMMENT 'AI-rekommendation',
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_user_date_type (user_id, checkin_date, checkin_type),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Förbättrad Check-in med AI';

-- Streaks tracking
CREATE TABLE checkin_streaks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    current_streak INT DEFAULT 0 COMMENT 'Nuvarande streak',
    longest_streak INT DEFAULT 0 COMMENT 'Längsta streak någonsin',
    last_checkin_date DATE COMMENT 'Senaste check-in datum',
    total_checkins INT DEFAULT 0,
    morning_streak INT DEFAULT 0,
    evening_streak INT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Badges/Achievements
CREATE TABLE checkin_badges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    badge_key VARCHAR(50) NOT NULL COMMENT 'Unik badge-nyckel',
    badge_name VARCHAR(100) NOT NULL,
    badge_description TEXT,
    badge_icon VARCHAR(50) COMMENT 'Emoji eller ikon',
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_badge (user_id, badge_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Predefined badges
-- INSERT INTO checkin_badges (user_id, badge_key, badge_name, badge_description, badge_icon) VALUES
-- (1, 'first_checkin', 'Första steget', 'Gjort din första check-in', '🌱'),
-- (1, 'week_warrior', 'Veckokrigare', '7 dagar i rad med check-in', '🔥'),
-- (1, 'month_master', 'Månadsmästare', '30 dagar i rad med check-in', '⭐'),
-- (1, 'morning_person', 'Morgonmänniska', '10 morgon-checkins', '🌅'),
-- (1, 'evening_reflector', 'Kvällsreflekterare', '10 kvälls-checkins', '🌙'),
-- (1, 'gratitude_guru', 'Tacksamhetsguru', 'Skrivit tacksamhet 20 gånger', '💝'),
-- (1, 'sleep_champion', 'Sömnmästare', '7 dagar med sömn över 8', '😴'),
-- (1, 'stress_manager', 'Stresshanterare', '7 dagar med stress under 4', '🧘');

-- Korrelationsdata för AI-insikter
CREATE TABLE checkin_correlations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    correlation_type VARCHAR(50) NOT NULL COMMENT 'sleep_mood, exercise_energy, etc.',
    correlation_value DECIMAL(4,2) COMMENT 'Korrelationskoefficient -1 till 1',
    insight_text TEXT COMMENT 'Förklaring av korrelationen',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Contextuella påminnelser
CREATE TABLE checkin_reminders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    reminder_type ENUM('time', 'context', 'ai') NOT NULL,
    trigger_condition VARCHAR(255) COMMENT 'Tid, aktivitet, eller AI-trigger',
    message_text TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_triggered TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Wearable data integration
CREATE TABLE checkin_wearable_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    checkin_id INT NOT NULL,
    steps INT,
    sleep_hours DECIMAL(4,1),
    sleep_quality INT CHECK (sleep_quality BETWEEN 1 AND 5),
    heart_rate_avg INT,
    hrv_score INT,
    source VARCHAR(50) COMMENT 'apple_health, google_fit, fitbit, etc.',
    synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (checkin_id) REFERENCES checkins_enhanced(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Community challenges (anonymiserad)
CREATE TABLE checkin_community_stats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    stat_date DATE NOT NULL,
    total_checkins INT DEFAULT 0,
    avg_mood DECIMAL(3,1),
    avg_energy DECIMAL(3,1),
    avg_sleep DECIMAL(3,1),
    active_streaks INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_date (stat_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index för prestanda
CREATE INDEX idx_checkins_user_date ON checkins_enhanced(user_id, checkin_date);
CREATE INDEX idx_checkins_type ON checkins_enhanced(checkin_type);
CREATE INDEX idx_correlations_user ON checkin_correlations(user_id, is_active);
