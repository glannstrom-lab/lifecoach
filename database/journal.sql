-- ============================================================
-- Comdira Journal - Databasschema
-- Komplett databasstruktur för intelligent journalföring
-- ============================================================

-- ============================================================
-- HUVUDTABELL: journal_entries
-- ============================================================
CREATE TABLE journal_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    -- Typ av inlägg
    entry_type ENUM('morning', 'evening', 'micro', 'goal', 'free', 'session') DEFAULT 'free',
    
    -- Innehåll
    title VARCHAR(255) NULL,
    content TEXT NOT NULL,
    
    -- Sentiment-analys
    sentiment ENUM('very_positive', 'positive', 'neutral', 'negative', 'very_negative') NULL,
    sentiment_score DECIMAL(4,3) NULL, -- -1.0 till 1.0
    mood_score INT NULL, -- 1-10 från användaren eller AI
    
    -- AI-genererad data
    ai_summary TEXT NULL, -- Sammanfattning av inlägget
    ai_insights JSON NULL, -- Array av insikter
    
    -- Länkar till andra moduler
    checkin_id INT NULL, -- Koppling till dagens check-in
    
    -- Metadata
    entry_date DATE NOT NULL,
    entry_time TIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (checkin_id) REFERENCES daily_checkins(id) ON DELETE SET NULL,
    INDEX idx_user_date (user_id, entry_date),
    INDEX idx_sentiment (sentiment),
    INDEX idx_type (entry_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TAGGAR: journal_tags
-- ============================================================
CREATE TABLE journal_tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entry_id INT NOT NULL,
    
    -- Tag-information
    tag_type ENUM('goal', 'habit', 'dimension', 'emotion', 'person', 'place', 'custom'),
    tag_value VARCHAR(100) NOT NULL,
    
    -- AI-konfidens
    ai_confidence DECIMAL(5,2) DEFAULT 100.00, -- 0-100%
    is_ai_generated BOOLEAN DEFAULT FALSE,
    
    -- Normaliserad tagg för sökning
    normalized_tag VARCHAR(100) NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
    INDEX idx_entry (entry_id),
    INDEX idx_tag_search (tag_type, normalized_tag),
    INDEX idx_value (tag_value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- LÄNKAR TILL ANDRA MODULER: journal_links
-- ============================================================
CREATE TABLE journal_links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entry_id INT NOT NULL,
    
    link_type ENUM('goal', 'habit', 'checkin', 'wellness_assessment'),
    linked_id INT NOT NULL,
    
    -- Kontext för länken
    link_context TEXT NULL, -- Varför är detta relaterat?
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
    INDEX idx_entry_links (entry_id, link_type),
    INDEX idx_linked (link_type, linked_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- MEDIA: journal_media
-- ============================================================
CREATE TABLE journal_media (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entry_id INT NOT NULL,
    
    media_type ENUM('image', 'audio', 'file') DEFAULT 'image',
    file_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500) NULL,
    
    -- Metadata
    caption TEXT NULL,
    file_size INT NULL, -- bytes
    
    -- AI-analys av media
    ai_description TEXT NULL, -- Auto-genererad beskrivning
    ai_tags JSON NULL, -- Taggning av innehållet
    
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
    INDEX idx_entry (entry_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AI-INSIKTER: journal_ai_insights
-- ============================================================
CREATE TABLE journal_ai_insights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entry_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Insikt
    insight_type ENUM('pattern', 'correlation', 'milestone', 'gratitude', 'concern', 'celebration'),
    insight_title VARCHAR(255) NOT NULL,
    insight_text TEXT NOT NULL,
    
    -- Data som stöder insikten
    supporting_data JSON NULL,
    confidence_score DECIMAL(5,2), -- 0-100%
    
    -- Kopplingar
    related_entry_id INT NULL, -- Kopplat till tidigare inlägg
    
    -- Feedback
    was_helpful BOOLEAN DEFAULT NULL,
    user_feedback TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (related_entry_id) REFERENCES journal_entries(id) ON DELETE SET NULL,
    INDEX idx_user_insights (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SMARTA PROMPTS: journal_prompts
-- ============================================================
CREATE TABLE journal_prompts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    -- Prompt-data
    prompt_type ENUM('gratitude', 'reflection', 'goal', 'challenge', 'milestone', 'pattern'),
    prompt_text TEXT NOT NULL,
    
    -- Kontext för prompten
    trigger_context TEXT NULL, -- Vad triggrade denna prompt?
    related_data JSON NULL, -- Vilken data låg bakom?
    
    -- Användning
    was_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    resulting_entry_id INT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (resulting_entry_id) REFERENCES journal_entries(id) ON DELETE SET NULL,
    INDEX idx_user_prompts (user_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TEMAN/ÄMNEN: journal_themes
-- ============================================================
CREATE TABLE journal_themes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    -- Tema-information
    theme_name VARCHAR(100) NOT NULL,
    theme_icon VARCHAR(10) DEFAULT '💭',
    theme_color VARCHAR(7) DEFAULT '#90EE90',
    
    -- Statistik
    entry_count INT DEFAULT 0,
    first_mentioned DATE NULL,
    last_mentioned DATE NULL,
    
    -- Trend
    trend_direction ENUM('up', 'down', 'stable') DEFAULT 'stable',
    trend_percentage DECIMAL(5,2) DEFAULT 0.00,
    
    -- AI-analys
    ai_description TEXT NULL,
    sentiment_average DECIMAL(4,3) NULL, -- Genomsnittligt sentiment för detta tema
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_theme (user_id, theme_name),
    INDEX idx_themes (user_id, entry_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TEMA-KOPPLINGAR: journal_entry_themes
-- ============================================================
CREATE TABLE journal_entry_themes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entry_id INT NOT NULL,
    theme_id INT NOT NULL,
    
    relevance_score DECIMAL(5,2) DEFAULT 100.00, -- Hur relevant är temat för inlägget
    
    FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
    FOREIGN KEY (theme_id) REFERENCES journal_themes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_entry_theme (entry_id, theme_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- MOOD-HISTORIK: journal_mood_history
-- ============================================================
CREATE TABLE journal_mood_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    record_date DATE NOT NULL,
    
    -- Humör-data
    morning_mood INT NULL,
    evening_mood INT NULL,
    average_mood DECIMAL(3,1) NULL,
    
    -- Kopplingar
    morning_entry_id INT NULL,
    evening_entry_id INT NULL,
    checkin_id INT NULL,
    
    -- AI-analys för dagen
    day_summary TEXT NULL,
    contributing_factors JSON NULL, -- Vad påverkade humöret?
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (morning_entry_id) REFERENCES journal_entries(id) ON DELETE SET NULL,
    FOREIGN KEY (evening_entry_id) REFERENCES journal_entries(id) ON DELETE SET NULL,
    FOREIGN KEY (checkin_id) REFERENCES daily_checkins(id) ON DELETE SET NULL,
    UNIQUE KEY unique_user_date (user_id, record_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- FRAMSTEGS-SPÅRNING: journal_progress_tracking
-- ============================================================
CREATE TABLE journal_progress_tracking (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    
    -- Vad spåras
    tracking_type ENUM('sentiment', 'theme_growth', 'gratitude', 'self_awareness'),
    
    -- Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    
    -- Mätningar
    baseline_value DECIMAL(5,2) NULL,
    current_value DECIMAL(5,2) NULL,
    change_percentage DECIMAL(5,2) NULL,
    
    -- AI-analys
    analysis_text TEXT NULL,
    recommendations JSON NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_period (user_id, period_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- VIEWS FÖR ANALYTICS
-- ============================================================

-- Sentiment-trend över tid
CREATE VIEW v_journal_sentiment_trend AS
SELECT 
    user_id,
    YEAR(entry_date) as year,
    MONTH(entry_date) as month,
    sentiment,
    COUNT(*) as entry_count,
    AVG(mood_score) as avg_mood
FROM journal_entries
GROUP BY user_id, YEAR(entry_date), MONTH(entry_date), sentiment;

-- Tema-aktivitet
CREATE VIEW v_journal_theme_activity AS
SELECT 
    jt.user_id,
    jt.theme_name,
    jt.theme_icon,
    jt.entry_count,
    jt.trend_direction,
    jt.trend_percentage,
    COUNT(jet.entry_id) as actual_entries,
    AVG(je.sentiment_score) as avg_sentiment
FROM journal_themes jt
LEFT JOIN journal_entry_themes jet ON jt.id = jet.theme_id
LEFT JOIN journal_entries je ON jet.entry_id = je.id
GROUP BY jt.id;

-- Entry med alla taggar (concatenated)
CREATE VIEW v_journal_entries_with_tags AS
SELECT 
    je.*,
    GROUP_CONCAT(DISTINCT jt.tag_value) as all_tags,
    GROUP_CONCAT(DISTINCT CONCAT(jt.tag_type, ':', jt.tag_value)) as typed_tags
FROM journal_entries je
LEFT JOIN journal_tags jt ON je.id = jt.entry_id
GROUP BY je.id;

-- ============================================================
-- TRIGGERS
-- ============================================================

DELIMITER //

-- Auto-uppdatera teman när nytt inlägg skapas
CREATE TRIGGER trg_update_themes_on_entry
AFTER INSERT ON journal_entry_themes
FOR EACH ROW
BEGIN
    UPDATE journal_themes
    SET 
        entry_count = entry_count + 1,
        last_mentioned = CURDATE()
    WHERE id = NEW.theme_id;
END//

-- Skapa mood-historik när journalinlägg skapas
CREATE TRIGGER trg_create_mood_history
AFTER INSERT ON journal_entries
FOR EACH ROW
BEGIN
    DECLARE existing_record INT;
    
    -- Kolla om det redan finns en post för denna dag
    SELECT id INTO existing_record
    FROM journal_mood_history
    WHERE user_id = NEW.user_id AND record_date = NEW.entry_date
    LIMIT 1;
    
    IF existing_record IS NULL THEN
        INSERT INTO journal_mood_history (
            user_id, record_date, 
            morning_mood, evening_mood, average_mood,
            morning_entry_id, evening_entry_id
        ) VALUES (
            NEW.user_id, NEW.entry_date,
            CASE WHEN NEW.entry_type = 'morning' THEN NEW.mood_score ELSE NULL END,
            CASE WHEN NEW.entry_type = 'evening' THEN NEW.mood_score ELSE NULL END,
            NEW.mood_score,
            CASE WHEN NEW.entry_type = 'morning' THEN NEW.id ELSE NULL END,
            CASE WHEN NEW.entry_type = 'evening' THEN NEW.id ELSE NULL END
        );
    ELSE
        -- Uppdatera befintlig post
        IF NEW.entry_type = 'morning' THEN
            UPDATE journal_mood_history
            SET morning_mood = NEW.mood_score,
                morning_entry_id = NEW.id,
                average_mood = (morning_mood + evening_mood) / 2
            WHERE id = existing_record;
        ELSEIF NEW.entry_type = 'evening' THEN
            UPDATE journal_mood_history
            SET evening_mood = NEW.mood_score,
                evening_entry_id = NEW.id,
                average_mood = (morning_mood + evening_mood) / 2
            WHERE id = existing_record;
        END IF;
    END IF;
END//

-- Logga när gratitude detekteras
CREATE TRIGGER trg_log_gratitude
AFTER INSERT ON journal_tags
FOR EACH ROW
BEGIN
    IF NEW.tag_value LIKE '%tacksam%' OR NEW.tag_value LIKE '%tacksamhet%' THEN
        INSERT INTO journal_ai_insights (
            entry_id, user_id, insight_type, 
            insight_title, insight_text
        ) VALUES (
            NEW.entry_id, 
            (SELECT user_id FROM journal_entries WHERE id = NEW.entry_id),
            'gratitude',
            'Tacksamhet noterad',
            'Du har uttryckt tacksamhet i detta inlägg. Forskningsstudier visar att regelbunden tacksamhet ökar välbefinnande.',
            90.00
        );
    END IF;
END//

DELIMITER ;

-- ============================================================
-- EXEMPEL-DATA (för utveckling)
-- ============================================================

-- Notera: user_id = 1 antas existera

-- INSERT INTO journal_entries (
--     user_id, entry_type, title, content,
--     sentiment, sentiment_score, mood_score,
--     ai_summary, entry_date
-- ) VALUES (
--     1, 'evening', NULL, 'Idag kändes det tufft på jobbet...',
--     'mixed', 0.2, 4,
--     'Användaren upplevde arbetsrelaterad stress men hanterade det genom träning.',
--     '2026-02-20'
-- );
