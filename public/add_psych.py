html = open('index.html', 'r', encoding='utf-8').read()

# Find position after the widget-grid opening div
grid_start = html.find('<div class="widget-grid" id="widgetGrid">')
insert_pos = html.find('>', grid_start) + 1

# New psychology-based widgets HTML
psych_widgets = """
                    <!-- Intent Implementation Widget - 1x2 -->
                    <div class="widget size-1x2 intent-widget" data-id="intent" data-module="intent" data-size="1x2">
                        <div class="widget-header" style="border-color: rgba(230, 126, 34, 0.3);">
                            <div class="widget-title"><span class="widget-icon">⏰</span> När ska du träna?</div>
                            <div class="widget-controls">
                                <button class="widget-btn" onclick="toggleCollapse(this)">−</button>
                            </div>
                        </div>
                        <div class="widget-content">
                            <p style="font-size: 14px; color: var(--text-secondary); margin-bottom: 16px;">
                                Att välja en specifik tid ökar sannolikheten för att du genomför det med <strong>90%</strong>!
                            </p>
                            <div class="time-slots">
                                <button class="time-slot" onclick="selectTimeSlot(this)">🌅 06:00</button>
                                <button class="time-slot" onclick="selectTimeSlot(this)">☕ 08:00</button>
                                <button class="time-slot selected" onclick="selectTimeSlot(this)">🌞 12:00</button>
                                <button class="time-slot" onclick="selectTimeSlot(this)">🌆 17:00</button>
                                <button class="time-slot" onclick="selectTimeSlot(this)">🌙 20:00</button>
                            </div>
                            <div class="intent-confirmation" id="intentConfirmation" style="display: none; margin-top: 16px; padding: 12px; background: rgba(39, 174, 96, 0.1); border-radius: 12px; text-align: center;">
                                <span style="font-size: 24px;">✅</span>
                                <p style="margin: 8px 0 0; font-weight: 600; color: #27AE60;">Perfekt! Vi påminner dig 11:45</p>
                            </div>
                        </div>
                    </div>

                    <!-- Implementation Intentions Widget - 2x1 -->
                    <div class="widget size-2x1 implementation-widget" data-id="implementation" data-module="implementation" data-size="2x1">
                        <div class="widget-header" style="border-color: rgba(155, 89, 182, 0.3);">
                            <div class="widget-title"><span class="widget-icon">🧠</span> Implementation Intention</div>
                            <div class="widget-controls">
                                <button class="widget-btn" onclick="toggleCollapse(this)">−</button>
                            </div>
                        </div>
                        <div class="widget-content">
                            <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 16px;">
                                Formulera en plan: <em>"Om X händer, då ska jag göra Y"</em> - Detta ökar chansen att du följer igenom med 200-300%!
                            </p>
                            <div class="implementation-form">
                                <div class="implementation-row">
                                    <span class="implementation-label">Om</span>
                                    <select class="implementation-select">
                                        <option>jag sätter mig i soffan efter jobbet</option>
                                        <option>jag vaknar på morgonen</option>
                                        <option>jag äter lunch</option>
                                        <option>jag kommer hem</option>
                                    </select>
                                </div>
                                <div class="implementation-row">
                                    <span class="implementation-label">då ska jag</span>
                                    <select class="implementation-select">
                                        <option>göra 10 squats direkt</option>
                                        <option>meditera i 5 minuter</option>
                                        <option>skriva i journalen</option>
                                        <option>dricka ett glas vatten</option>
                                    </select>
                                </div>
                            </div>
                            <button class="implementation-save" onclick="saveImplementation()">💾 Spara min intention</button>
                        </div>
                    </div>

                    <!-- Habit Stacking Widget - 1x2 -->
                    <div class="widget size-1x2 habit-stack-widget" data-id="habitstack" data-module="habitstack" data-size="1x2">
                        <div class="widget-header" style="border-color: rgba(52, 152, 219, 0.3);">
                            <div class="widget-title"><span class="widget-icon">🥞</span> Habit Stacking</div>
                            <div class="widget-controls">
                                <button class="widget-btn" onclick="toggleCollapse(this)">−</button>
                            </div>
                        </div>
                        <div class="widget-content">
                            <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 16px;">
                                Baserat på <strong>BJ Fogg's Tiny Habits</strong>: Fäst en ny vana vid en befintlig!
                            </p>
                            <div class="habit-stack-visual">
                                <div class="habit-stack-item existing">
                                    <div class="habit-stack-icon">☕</div>
                                    <div class="habit-stack-text">Efter jag har druckit mitt morgonkaffe</div>
                                </div>
                                <div class="habit-stack-arrow">⬇️</div>
                                <div class="habit-stack-item new">
                                    <div class="habit-stack-icon">🧘</div>
                                    <div class="habit-stack-text">ska jag meditera i 2 minuter</div>
                                </div>
                            </div>
                            <div class="habit-stack-builder">
                                <p style="font-size: 12px; font-weight: 600; color: var(--text-primary); margin-bottom: 8px;">Bygg din egen stack:</p>
                                <select class="habit-stack-select" id="existingHabit">
                                    <option value="coffee">☕ Efter mitt morgonkaffe</option>
                                    <option value="brush">🪥 Efter jag borstat tänderna</option>
                                    <option value="shower">🚿 Efter min dusch</option>
                                    <option value="lunch">🍽️ Efter lunch</option>
                                </select>
                                <select class="habit-stack-select" id="newHabit">
                                    <option value="meditate">🧘 ska jag meditera 2 min</option>
                                    <option value="stretch">🤸 ska jag stretcha</option>
                                    <option value="journal">✍️ ska jag skriva 3 rader</option>
                                    <option value="water">💧 ska jag dricka vatten</option>
                                </select>
                                <button class="habit-stack-save" onclick="saveHabitStack()">✨ Skapa stack</button>
                            </div>
                        </div>
                    </div>

                    <!-- Mood-Priming Widget - 1x1 -->
                    <div class="widget size-1x1 mood-prime-widget" data-id="moodprime" data-module="moodprime" data-size="1x1">
                        <div class="widget-content" style="padding: 24px; text-align: center;">
                            <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin-bottom: 16px;">
                                Hur vill du känna idag?
                            </h3>
                            <div class="mood-options">
                                <button class="mood-option" onclick="selectMood(this, 'energized')">
                                    <span class="mood-emoji">⚡</span>
                                    <span class="mood-label">Energisk</span>
                                </button>
                                <button class="mood-option" onclick="selectMood(this, 'calm')">
                                    <span class="mood-emoji">🧘</span>
                                    <span class="mood-label">Lugn</span>
                                </button>
                                <button class="mood-option" onclick="selectMood(this, 'focused')">
                                    <span class="mood-emoji">🎯</span>
                                    <span class="mood-label">Fokuserad</span>
                                </button>
                                <button class="mood-option" onclick="selectMood(this, 'happy')">
                                    <span class="mood-emoji">😊</span>
                                    <span class="mood-label">Glad</span>
                                </button>
                            </div>
                            <div class="mood-suggestion" id="moodSuggestion" style="display: none; margin-top: 16px; padding: 12px; background: linear-gradient(135deg, #667eea, #764ba2); border-radius: 12px; color: white;">
                                <p style="margin: 0; font-size: 13px;">💡 <strong>Förslag:</strong> <span id="suggestionText">Gå en 20-minuters promenad i solen!</span></p>
                            </div>
                        </div>
                    </div>

                    <!-- Gratitude Nudge Widget - 1x1 -->
                    <div class="widget size-1x1 gratitude-nudge-widget" data-id="gratitude" data-module="gratitude" data-size="1x1">
                        <div class="widget-content" style="padding: 24px; text-align: center;">
                            <div class="gratitude-icon">🙏</div>
                            <h3 style="font-size: 15px; font-weight: 600; color: #27AE60; margin-bottom: 12px;">
                                Vad är du tacksam för just nu?
                            </h3>
                            <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 16px;">
                                Att uttrycka tacksamhet dagligen ökar ditt välmående med 25%
                            </p>
                            <div class="gratitude-quick-options">
                                <button class="gratitude-quick" onclick="quickGratitude(this)">❤️ Familj</button>
                                <button class="gratitude-quick" onclick="quickGratitude(this)">☀️ Solen</button>
                                <button class="gratitude-quick" onclick="quickGratitude(this)">💪 Hälsa</button>
                            </div>
                            <button class="gratitude-write" onclick="writeGratitude()">✍️ Skriv eget...</button>
                            <div class="gratitude-streak" id="gratitudeStreak">
                                <span>🔥</span>
                                <span>5 dagar i rad!</span>
                            </div>
                        </div>
                    </div>
"""

new_html = html[:insert_pos] + psych_widgets + html[insert_pos:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print('Psychology widgets added!')
