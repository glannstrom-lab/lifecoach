-- Välmåendehexagonen - Databasschema
-- Modul för att mäta välmående över 6 dimensioner

-- Tabell för välmåendebedömningar
CREATE TABLE wellness_assessments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    assessment_date DATE NOT NULL,
    
    -- Sex dimensioner (snitt av 5 frågor var), skala 1-5
    existential_score DECIMAL(3,1) NOT NULL COMMENT 'Existentiellt välmående',
    emotional_score DECIMAL(3,1) NOT NULL COMMENT 'Emotionellt välmående',
    subjective_score DECIMAL(3,1) NOT NULL COMMENT 'Subjektivt välmående',
    occupational_score DECIMAL(3,1) NOT NULL COMMENT 'Yrkesmässigt välmående',
    social_score DECIMAL(3,1) NOT NULL COMMENT 'Socialt välmående',
    practical_score DECIMAL(3,1) NOT NULL COMMENT 'Vardagligt välmående',
    
    -- Total snitt (genomsnitt av alla 6)
    overall_score DECIMAL(3,1) NOT NULL,
    
    -- Rådata - alla 30 svar som JSON
    -- Format: {"q1": 4, "q2": 3, ...}
    raw_responses JSON NOT NULL,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_monthly_assessment (user_id, assessment_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Välmåendehexagonen bedömningar';

-- Index för snabb hämtning av historik
CREATE INDEX idx_wellness_user_date ON wellness_assessments(user_id, assessment_date);
CREATE INDEX idx_wellness_overall ON wellness_assessments(overall_score);

-- Frågebibliotek för Välmåendehexagonen
-- Detta gör det möjligt att uppdatera frågor utan kodändring
CREATE TABLE wellness_questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dimension VARCHAR(20) NOT NULL COMMENT 'existential, emotional, subjective, occupational, social, practical',
    question_key VARCHAR(30) NOT NULL COMMENT 'Unik nyckel, t.ex. exist_1, emot_2',
    question_text TEXT NOT NULL COMMENT 'Frågan som visas för användaren',
    reverse_scored BOOLEAN DEFAULT FALSE COMMENT 'TRUE om lågt värde = bra',
    sort_order INT NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_question_key (question_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Infoga de 30 frågorna (alla positivt formulerade, 5-gradig skala)
-- 1 = Instämmer inte alls, 5 = Instämmer helt

-- EXISTENTIELLT (5 frågor)
INSERT INTO wellness_questions (dimension, question_key, question_text, reverse_scored, sort_order) VALUES
('existential', 'exist_1', 'Jag känner att mitt liv har en mening och ett syfte', FALSE, 1),
('existential', 'exist_2', 'Jag är nöjd med mitt liv som det är just nu', FALSE, 2),
('existential', 'exist_3', 'Jag känner mig del av något större än mig själv', FALSE, 3),
('existential', 'existential', 'Jag har en klar uppfattning om vad som är viktigt i mitt liv', FALSE, 4),
('existential', 'exist_5', 'Jag känner mig nöjd med min roll i samhället', FALSE, 5);

-- EMOTIONELLT (5 frågor)
INSERT INTO wellness_questions (dimension, question_key, question_text, reverse_scored, sort_order) VALUES
('emotional', 'emot_1', 'Jag mår bra just nu', FALSE, 1),
('emotional', 'emot_2', 'Jag kan hantera mina känslor på ett konstruktivt sätt', FALSE, 2),
('emotional', 'emot_3', 'Jag känner mig lugn och avslappnad i vardagen', FALSE, 3),
('emotional', 'emot_4', 'Jag tycker om mig själv och den jag är', FALSE, 4),
('emotional', 'emot_5', 'Jag har ett bra självförtroende och tror på mig själv', FALSE, 5);

-- SUBJEKTIVT (5 frågor)
INSERT INTO wellness_questions (dimension, question_key, question_text, reverse_scored, sort_order) VALUES
('subjective', 'subj_1', 'Jag känner mig nöjd med mitt liv', FALSE, 1),
('subjective', 'subj_2', 'Jag upplever att jag har kontroll över mitt liv', FALSE, 2),
('subjective', 'subj_3', 'Jag känner mig energisk och livskraftig', FALSE, 3),
('subjective', 'subj_4', 'Jag är nöjd med min nuvarande partnerstatus', FALSE, 4),
('subjective', 'subj_5', 'Jag har lätt för att anpassa mig till nya situationer', FALSE, 5);

-- YRKESMÄSSIGT (5 frågor)
INSERT INTO wellness_questions (dimension, question_key, question_text, reverse_scored, sort_order) VALUES
('occupational', 'occup_1', 'Jag trivs bra med min nuvarande sysselsättning', FALSE, 1),
('occupational', 'occup_2', 'Jag känner mig tillfreds med mitt arbete/sysselsättning', FALSE, 2),
('occupational', 'occup_3', 'Jag har en bra balans mellan arbete och fritid', FALSE, 3),
('occupational', 'occup_4', 'Jag känner mig kompetent i det jag gör', FALSE, 4),
('occupational', 'occup_5', 'Jag ser en framtid för mig själv inom mitt område', FALSE, 5);

-- SOCIALT (5 frågor)
INSERT INTO wellness_questions (dimension, question_key, question_text, reverse_scored, sort_order) VALUES
('social', 'social_1', 'Jag är nöjd med relationen till mina vänner', FALSE, 1),
('social', 'social_2', 'Jag har nära relationer som ger mig stöd', FALSE, 2),
('social', 'social_3', 'Jag är nöjd med den relation jag har med min familj', FALSE, 3),
('social', 'social_4', 'Jag känner mig bekväm i sociala sammanhang', FALSE, 4),
('social', 'social_5', 'Jag har människor jag kan lita på', FALSE, 5);

-- VARDAGSLIGT (5 frågor)
INSERT INTO wellness_questions (dimension, question_key, question_text, reverse_scored, sort_order) VALUES
('practical', 'pract_1', 'Jag klarar av mina vardagliga sysslor och uppgifter', FALSE, 1),
('practical', 'pract_2', 'Jag känner mig trygg med min ekonomi', FALSE, 2),
('practical', 'pract_3', 'Jag har bra rutiner och struktur i vardagen', FALSE, 3),
('practical', 'pract_4', 'Fritiden räcker till för det jag vill göra', FALSE, 4),
('practical', 'pract_5', 'Jag kan organisera mina uppgifter på ett bra sätt', FALSE, 5);

-- Tabell för åtgärdsförslag vid låga scores
CREATE TABLE wellness_actions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dimension VARCHAR(20) NOT NULL,
    score_threshold DECIMAL(3,1) NOT NULL COMMENT 'Visa om score är <= detta värde',
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    action_type ENUM('article', 'exercise', 'resource', 'professional') NOT NULL,
    link VARCHAR(500),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Exempel på åtgärder för låga scores
INSERT INTO wellness_actions (dimension, score_threshold, title, description, action_type) VALUES
('existential', 2.5, 'Hitta mening i vardagen', 'Små övningar för att upptäcka vad som ger ditt liv mening', 'exercise'),
('emotional', 2.5, 'Hantera svåra känslor', 'Tekniker för att hantera känslomässiga svängningar', 'exercise'),
('social', 2.5, 'Stärka relationer', 'Tips för att bygga och bibehålla meningsfulla relationer', 'article'),
('occupational', 2.5, 'Arbetslivsbalans', 'Strategier för att hitta balans mellan arbete och fritid', 'article'),
('practical', 2.5, 'Struktur i vardagen', 'Verktyg för att organisera din vardag', 'exercise'),
('subjective', 2.5, 'Självmedkänsla', 'Övningar för att stärka din relation till dig själv', 'exercise');
