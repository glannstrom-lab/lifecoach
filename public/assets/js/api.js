/**
 * Comdira Lifecoach - API Client
 * Handles all communication with the backend
 */

const API_BASE_URL = 'https://comdira.com/api'; // Change this to your API URL

class ComdiraAPI {
    constructor() {
        this.token = localStorage.getItem('auth_token');
    }
    
    /**
     * Make authenticated API request
     */
    async request(endpoint, options = {}) {
        const url = `${API_BASE_URL}${endpoint}`;
        
        const headers = {
            'Content-Type': 'application/json',
            ...options.headers
        };
        
        if (this.token) {
            headers['Authorization'] = `Bearer ${this.token}`;
        }
        
        const config = {
            ...options,
            headers
        };
        
        if (config.body && typeof config.body === 'object') {
            config.body = JSON.stringify(config.body);
        }
        
        try {
            const response = await fetch(url, config);
            const data = await response.json();
            
            if (!response.ok) {
                throw new Error(data.error || 'Request failed');
            }
            
            return data;
        } catch (error) {
            console.error('API Error:', error);
            throw error;
        }
    }
    
    /**
     * Authentication
     */
    async login(email, password) {
        const data = await this.request('/auth/login.php', {
            method: 'POST',
            body: { email, password }
        });
        
        if (data.token) {
            this.token = data.token;
            localStorage.setItem('auth_token', data.token);
            localStorage.setItem('user_email', data.user.email);
            localStorage.setItem('user_name', data.user.name);
        }
        
        return data;
    }
    
    async register(name, email, password) {
        const data = await this.request('/auth/register.php', {
            method: 'POST',
            body: { name, email, password }
        });
        
        if (data.token) {
            this.token = data.token;
            localStorage.setItem('auth_token', data.token);
            localStorage.setItem('user_email', data.user.email);
            localStorage.setItem('user_name', data.user.name);
        }
        
        return data;
    }
    
    logout() {
        this.token = null;
        localStorage.removeItem('auth_token');
        localStorage.removeItem('user_email');
        localStorage.removeItem('user_name');
        window.location.href = 'login.html';
    }
    
    /**
     * Dashboard
     */
    async getDashboard() {
        return this.request('/user/dashboard.php');
    }
    
    /**
     * Check-ins
     */
    async createCheckin(mood, energy, notes = '') {
        return this.request('/user/checkin.php', {
            method: 'POST',
            body: { mood, energy, notes }
        });
    }
    
    /**
     * Habits
     */
    async getHabits() {
        return this.request('/habits/list.php');
    }
    
    async completeHabit(habitId, date = null) {
        return this.request('/habits/complete.php', {
            method: 'POST',
            body: { 
                habit_id: habitId,
                date: date || new Date().toISOString().split('T')[0]
            }
        });
    }
    
    async createHabit(name, icon, description = '') {
        return this.request('/habits/create.php', {
            method: 'POST',
            body: { name, icon, description }
        });
    }
    
    /**
     * Goals
     */
    async getGoals() {
        return this.request('/goals/list.php');
    }
    
    async updateGoalProgress(goalId, progress) {
        return this.request('/goals/progress.php', {
            method: 'POST',
            body: { goal_id: goalId, progress }
        });
    }
    
    /**
     * Journal
     */
    async getJournalEntries(limit = 10) {
        return this.request(`/user/journal.php?limit=${limit}`);
    }
    
    async createJournalEntry(title, content, mood = null) {
        return this.request('/user/journal.php', {
            method: 'POST',
            body: { title, content, mood }
        });
    }
}

// Create global instance
const api = new ComdiraAPI();

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ComdiraAPI;
}
