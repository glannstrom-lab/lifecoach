<?php
/**
 * Comdira Lifecoach - Login Page
 */
require_once 'includes/config.php';

// Om redan inloggad, gå till dashboard
if (isLoggedIn()) {
    header('Location: dashboard.php');
    exit;
}

$error = '';

// Hantera login
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL);
    $password = $_POST['password'] ?? '';
    $remember = isset($_POST['remember']);
    
    if ($email && $password) {
        $db = getDB();
        $stmt = $db->prepare("SELECT id, email, password_hash, first_name, last_name, is_active FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch();
        
        if ($user && password_verify($password, $user['password_hash'])) {
            if (!$user['is_active']) {
                $error = 'Ditt konto är inaktiverat. Kontakta support.';
            } else {
                // Sätt sessionsvariabler
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['user_email'] = $user['email'];
                $_SESSION['user_name'] = $user['first_name'] . ' ' . $user['last_name'];
                
                // Uppdatera senaste inloggning
                $db->prepare("UPDATE users SET last_login = NOW() WHERE id = ?")
                   ->execute([$user['id']]);
                
                // Om "remember me" är vald
                if ($remember) {
                    $token = bin2hex(random_bytes(32));
                    $expires = date('Y-m-d H:i:s', strtotime('+30 days'));
                    $db->prepare("INSERT INTO user_sessions (user_id, session_token, expires_at) VALUES (?, ?, ?)")
                       ->execute([$user['id'], $token, $expires]);
                    setcookie('comdira_session', $token, time() + (86400 * 30), '/', '', false, true);
                }
                
                header('Location: dashboard.php');
                exit;
            }
        } else {
            $error = 'Felaktig e-post eller lösenord.';
        }
    } else {
        $error = 'Vänligen fyll i alla fält.';
    }
}
?>
<!DOCTYPE html>
<html lang="sv">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Logga in - Comdira Lifecoach</title>
    <link rel="stylesheet" href="assets/css/style.css">
    <style>
        /* Extra styling för login-sidan */
        .login-page {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--bg-main) 0%, var(--primary-light) 50%, var(--accent-light) 100%);
            padding: var(--space-lg);
            position: relative;
            overflow: hidden;
        }
        
        .login-page::before {
            content: '';
            position: absolute;
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, var(--primary) 0%, transparent 70%);
            opacity: 0.3;
            border-radius: 50%;
            top: -200px;
            right: -200px;
        }
        
        .login-page::after {
            content: '';
            position: absolute;
            width: 400px;
            height: 400px;
            background: radial-gradient(circle, var(--accent) 0%, transparent 70%);
            opacity: 0.2;
            border-radius: 50%;
            bottom: -100px;
            left: -100px;
        }
        
        .login-card {
            background: var(--bg-surface);
            border-radius: var(--radius-xl);
            padding: var(--space-xxl);
            width: 100%;
            max-width: 420px;
            box-shadow: var(--shadow-lg);
            text-align: center;
            position: relative;
            z-index: 1;
        }
        
        .login-logo {
            margin-bottom: var(--space-xl);
        }
        
        .login-logo .logo-icon {
            width: 72px;
            height: 72px;
            font-size: 2rem;
            margin: 0 auto var(--space-md);
            background: linear-gradient(135deg, var(--primary), var(--accent));
            border-radius: var(--radius-lg);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
        }
        
        .login-title {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: var(--space-xs);
        }
        
        .login-subtitle {
            color: var(--text-secondary);
            margin-bottom: var(--space-xl);
            font-size: 0.95rem;
        }
        
        .login-form {
            text-align: left;
        }
        
        .form-group {
            margin-bottom: var(--space-lg);
        }
        
        .form-label {
            display: block;
            margin-bottom: var(--space-sm);
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text-primary);
        }
        
        .form-input {
            width: 100%;
            padding: var(--space-md);
            border: 2px solid var(--primary-light);
            border-radius: var(--radius-md);
            background: var(--bg-surface);
            color: var(--text-primary);
            font-size: 1rem;
            transition: all var(--transition-fast);
        }
        
        .form-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 4px var(--primary-light);
        }
        
        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-xl);
            font-size: 0.875rem;
        }
        
        .checkbox-label {
            display: flex;
            align-items: center;
            gap: var(--space-sm);
            color: var(--text-secondary);
            cursor: pointer;
        }
        
        .checkbox-label input[type="checkbox"] {
            width: 18px;
            height: 18px;
            accent-color: var(--primary);
        }
        
        .forgot-link {
            color: var(--primary-dark);
            font-weight: 500;
        }
        
        .forgot-link:hover {
            color: var(--text-primary);
        }
        
        .btn-login {
            width: 100%;
            padding: var(--space-md);
            background: linear-gradient(135deg, var(--primary), var(--accent));
            color: white;
            border: none;
            border-radius: var(--radius-md);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all var(--transition-fast);
            margin-bottom: var(--space-lg);
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
        }
        
        .error-message {
            background: var(--error);
            color: white;
            padding: var(--space-md);
            border-radius: var(--radius-md);
            margin-bottom: var(--space-lg);
            font-size: 0.875rem;
        }
        
        .register-link {
            text-align: center;
            color: var(--text-secondary);
            font-size: 0.875rem;
        }
        
        .register-link a {
            color: var(--primary-dark);
            font-weight: 600;
        }
        
        /* Dekorativa element */
        .feature-badges {
            display: flex;
            justify-content: center;
            gap: var(--space-md);
            margin-top: var(--space-xl);
            flex-wrap: wrap;
        }
        
        .feature-badge {
            display: flex;
            align-items: center;
            gap: var(--space-xs);
            padding: var(--space-sm) var(--space-md);
            background: var(--primary-light);
            border-radius: var(--radius-lg);
            font-size: 0.75rem;
            color: var(--text-secondary);
            font-weight: 500;
        }
        
        .feature-badge svg {
            width: 16px;
            height: 16px;
            color: var(--primary-dark);
        }
        
        @media (max-width: 480px) {
            .login-card {
                padding: var(--space-xl);
            }
            
            .login-title {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="login-page">
        <div class="login-card fade-in">
            <div class="login-logo">
                <div class="logo-icon">C</div>
                <h1 class="login-title">Välkommen till Comdira</h1>
                <p class="login-subtitle">Din personliga livscoach för balans och utveckling</p>
            </div>
            
            <?php if ($error): ?>
                <div class="error-message">
                    <?= htmlspecialchars($error) ?>
                </div>
            <?php endif; ?>
            
            <form class="login-form" method="POST" action="">
                <div class="form-group">
                    <label class="form-label" for="email">E-post</label>
                    <input 
                        type="email" 
                        id="email" 
                        name="email" 
                        class="form-input" 
                        placeholder="din@email.com"
                        required
                        autofocus
                    >
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="password">Lösenord</label>
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        class="form-input" 
                        placeholder="••••••••"
                        required
                    >
                </div>
                
                <div class="form-options">
                    <label class="checkbox-label">
                        <input type="checkbox" name="remember" id="remember">
                        <span>Kom ihåg mig</span>
                    </label>
                    <a href="#" class="forgot-link">Glömt lösenord?</a>
                </div>
                
                <button type="submit" class="btn-login">
                    Logga in
                </button>
            </form>
            
            <p class="register-link">
                Har du inget konto? <a href="#">Skapa konto</a>
            </p>
            
            <div class="feature-badges">
                <div class="feature-badge">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    Säkert
                </div>
                <div class="feature-badge">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                    Personligt
                </div>
                <div class="feature-badge">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                    24/7
                </div>
            </div>
        </div>
    </div>
</body>
</html>
