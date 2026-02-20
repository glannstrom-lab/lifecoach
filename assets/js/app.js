/**
 * Comdira Lifecoach - Main JavaScript
 * Interaktivitet för dashboard och komponenter
 */

document.addEventListener('DOMContentLoaded', function() {
    
    // === MOBIL MENY ===
    const mobileMenuBtn = document.querySelector('.mobile-menu-btn');
    const sidebar = document.querySelector('.sidebar');
    
    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', () => {
            sidebar.classList.toggle('open');
        });
    }
    
    // Stäng sidebar när man klickar utanför på mobil
    document.addEventListener('click', (e) => {
        if (window.innerWidth <= 768 && sidebar && sidebar.classList.contains('open')) {
            if (!sidebar.contains(e.target) && !mobileMenuBtn.contains(e.target)) {
                sidebar.classList.remove('open');
            }
        }
    });
    
    // === HUMÖR VÄLJARE ===
    const moodButtons = document.querySelectorAll('.mood-btn');
    let selectedMood = null;
    
    moodButtons.forEach(btn => {
        btn.addEventListener('click', function() {
            // Ta bort selected från alla
            moodButtons.forEach(b => b.classList.remove('selected'));
            // Lägg till på klickad
            this.classList.add('selected');
            selectedMood = this.getAttribute('title');
            
            // Spara till localStorage tillfälligt
            localStorage.setItem('comdira_mood', selectedMood);
        });
    });
    
    // === VANA CHECKBOXAR ===
    const habitCheckboxes = document.querySelectorAll('.habit-checkbox');
    
    habitCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('click', function() {
            this.classList.toggle('checked');
            
            // Animera
            this.style.transform = 'scale(0.9)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 150);
            
            // TODO: Spara till databas via AJAX
            const habitId = this.closest('.habit-item').dataset.habitId;
            const isChecked = this.classList.contains('checked');
            
            console.log('Habit', habitId, isChecked ? 'completed' : 'uncompleted');
        });
    });
    
    // === PROGRESS RINGAR ===
    function updateProgressRings() {
        const progressRings = document.querySelectorAll('.progress-ring-fill');
        
        progressRings.forEach(ring => {
            const circumference = 2 * Math.PI * 52; // r = 52
            const percent = ring.parentElement.nextElementSibling?.textContent || '0%';
            const value = parseInt(percent) || 0;
            const offset = circumference - (value / 100) * circumference;
            
            ring.style.strokeDasharray = `${circumference} ${circumference}`;
            ring.style.strokeDashoffset = offset;
        });
    }
    
    updateProgressRings();
    
    // === ANIMERA KORT VID SCROLL ===
    const cards = document.querySelectorAll('.card');
    
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };
    
    const cardObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    cards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.5s ease, transform 0.5s ease, box-shadow 0.3s ease';
        cardObserver.observe(card);
    });
    
    // === SÖKFUNKTION ===
    const searchInput = document.querySelector('.search-box input');
    
    if (searchInput) {
        searchInput.addEventListener('focus', function() {
            this.parentElement.style.transform = 'scale(1.02)';
        });
        
        searchInput.addEventListener('blur', function() {
            this.parentElement.style.transform = 'scale(1)';
        });
    }
    
    // === KLOCKA OCH DATUM ===
    function updateDateTime() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('sv-SE', { 
            hour: '2-digit', 
            minute: '2-digit' 
        });
        
        // Om vi har en klocka på sidan, uppdatera den
        const clockElement = document.querySelector('.live-clock');
        if (clockElement) {
            clockElement.textContent = timeString;
        }
    }
    
    setInterval(updateDateTime, 1000);
    updateDateTime();
    
    // === SMOOTH SCROLL ===
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // === TOOLTIPS ===
    const tooltipTriggers = document.querySelectorAll('[data-tooltip]');
    
    tooltipTriggers.forEach(trigger => {
        trigger.addEventListener('mouseenter', function() {
            const tooltip = document.createElement('div');
            tooltip.className = 'tooltip';
            tooltip.textContent = this.getAttribute('data-tooltip');
            tooltip.style.cssText = `
                position: absolute;
                background: var(--text-primary);
                color: white;
                padding: 0.5rem 1rem;
                border-radius: var(--radius-sm);
                font-size: 0.75rem;
                z-index: 1000;
                pointer-events: none;
                opacity: 0;
                transition: opacity 0.3s ease;
            `;
            
            document.body.appendChild(tooltip);
            
            const rect = this.getBoundingClientRect();
            tooltip.style.left = rect.left + (rect.width / 2) - (tooltip.offsetWidth / 2) + 'px';
            tooltip.style.top = rect.top - tooltip.offsetHeight - 8 + 'px';
            
            requestAnimationFrame(() => {
                tooltip.style.opacity = '1';
            });
            
            this._tooltip = tooltip;
        });
        
        trigger.addEventListener('mouseleave', function() {
            if (this._tooltip) {
                this._tooltip.remove();
                this._tooltip = null;
            }
        });
    });
    
    // === KORT HOVER EFFEKT ===
    cards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-4px)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });
    
    // === FORMULÄR VALIDERING ===
    const forms = document.querySelectorAll('form');
    
    forms.forEach(form => {
        form.addEventListener('submit', function(e) {
            const requiredFields = form.querySelectorAll('[required]');
            let isValid = true;
            
            requiredFields.forEach(field => {
                if (!field.value.trim()) {
                    isValid = false;
                    field.style.borderColor = 'var(--error)';
                    
                    // Skaka animation
                    field.style.animation = 'shake 0.5s ease';
                    setTimeout(() => {
                        field.style.animation = '';
                    }, 500);
                } else {
                    field.style.borderColor = '';
                }
            });
            
            if (!isValid) {
                e.preventDefault();
            }
        });
    });
    
    // === NOTIS SYSTEM (Toast) ===
    window.showToast = function(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.textContent = message;
        toast.style.cssText = `
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            padding: 1rem 1.5rem;
            border-radius: var(--radius-md);
            background: var(--primary);
            color: var(--text-primary);
            font-weight: 500;
            box-shadow: var(--shadow-lg);
            z-index: 9999;
            transform: translateX(100%);
            opacity: 0;
            transition: all 0.3s ease;
        `;
        
        if (type === 'error') {
            toast.style.background = 'var(--error)';
            toast.style.color = 'white';
        } else if (type === 'success') {
            toast.style.background = 'var(--success)';
            toast.style.color = 'white';
        }
        
        document.body.appendChild(toast);
        
        requestAnimationFrame(() => {
            toast.style.transform = 'translateX(0)';
            toast.style.opacity = '1';
        });
        
        setTimeout(() => {
            toast.style.transform = 'translateX(100%)';
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 300);
        }, 4000);
    };
    
    // === OFFLINE DETECTION ===
    window.addEventListener('online', () => {
        showToast('Du är online igen!', 'success');
    });
    
    window.addEventListener('offline', () => {
        showToast('Du är offline. Data sparas lokalt.', 'error');
    });
    
    // === PWA SUPPORT ===
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('/service-worker.js')
            .then(registration => {
                console.log('ServiceWorker registered:', registration);
            })
            .catch(error => {
                console.log('ServiceWorker registration failed:', error);
            });
    }
    
    console.log('🌱 Comdira Lifecoach loaded successfully!');
});

// === CSS ANIMATIONS ===
const style = document.createElement('style');
style.textContent = `
    @keyframes shake {
        0%, 100% { transform: translateX(0); }
        25% { transform: translateX(-5px); }
        75% { transform: translateX(5px); }
    }
`;
document.head.appendChild(style);
