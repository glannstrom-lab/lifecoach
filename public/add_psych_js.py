html = open('index.html', 'r', encoding='utf-8').read()

# JavaScript functions for psychology widgets
js_funcs = """
        // Intent Implementation - select time slot
        function selectTimeSlot(btn) {
            document.querySelectorAll('.time-slot').forEach(slot => slot.classList.remove('selected'));
            btn.classList.add('selected');
            document.getElementById('intentConfirmation').style.display = 'block';
            setTimeout(() => {
                showNotification('Intention sparad! Vi påminner dig 🔔');
            }, 300);
        }

        // Implementation Intentions - save
        function saveImplementation() {
            showNotification('Implementation intention sparad! 🧠✨');
        }

        // Habit Stacking - save
        function saveHabitStack() {
            const existing = document.getElementById('existingHabit').value;
            const newHabit = document.getElementById('newHabit').value;
            showNotification('Habit stack skapad! Du kommer att älska detta! 🥞✨');
        }

        // Mood Priming - select mood
        const moodSuggestions = {
            energized: 'Gå en 20-minuters promenad i solen! ☀️',
            calm: 'Gör 5 minuter av djupandning nu 🧘',
            focused: 'Använd Pomodoro-tekniken för nästa uppgift 🍅',
            happy: 'Skriv ner 3 saker du är tacksam för 🙏'
        };

        function selectMood(btn, mood) {
            document.querySelectorAll('.mood-option').forEach(opt => opt.classList.remove('selected'));
            btn.classList.add('selected');
            document.getElementById('suggestionText').textContent = moodSuggestions[mood];
            document.getElementById('moodSuggestion').style.display = 'block';
        }

        // Gratitude Nudge - quick gratitude
        function quickGratitude(btn) {
            document.querySelectorAll('.gratitude-quick').forEach(g => g.classList.remove('selected'));
            btn.classList.add('selected');
            showNotification('Tack för att du delade! Din tacksamhet är sparad 🙏💚');
        }

        // Write custom gratitude
        function writeGratitude() {
            const entry = prompt('Vad är du tacksam för just nu?');
            if (entry) {
                showNotification('Tacksamhet sparad till journalen! 📔✨');
            }
        }

        // Notification helper
        function showNotification(message) {
            const notif = document.createElement('div');
            notif.style.cssText = 'position: fixed; bottom: 100px; left: 50%; transform: translateX(-50%); background: #27AE60; color: white; padding: 16px 32px; border-radius: 30px; font-weight: 600; box-shadow: 0 10px 30px rgba(39, 174, 96, 0.3); z-index: 1000; animation: slideUp 0.3s ease;';
            notif.textContent = message;
            document.body.appendChild(notif);
            setTimeout(() => notif.remove(), 3000);
        }
"""

# Find last </script> and add before it
script_end = html.rfind('</script>')
new_html = html[:script_end] + js_funcs + html[script_end:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print('JavaScript added!')
