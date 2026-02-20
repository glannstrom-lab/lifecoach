html = open('index.html', 'r', encoding='utf-8').read()

# Update filter chips
old_chips = """<div class="filter-chips">
                        <label class="filter-chip"><input type="checkbox" data-module="briefing" onchange="toggleModule('briefing')"><span>☀️ Briefing</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="wellness" onchange="toggleModule('wellness')"><span>⬡ Välmående</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="quote" onchange="toggleModule('quote')"><span>💭 Citat</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="checkin" onchange="toggleModule('checkin')"><span>○ Check-in</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="progress" onchange="toggleModule('progress')"><span>📊 Progress</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="habits" onchange="toggleModule('habits')"><span>✓ Vanor</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="recommendation" onchange="toggleModule('recommendation')"><span>💡 Rekommendation</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="goals" onchange="toggleModule('goals')"><span>◆ Mål</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="journal" onchange="toggleModule('journal')"><span>📝 Journal</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="calendar" onchange="toggleModule('calendar')"><span>📅 Kalender</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="tasks" onchange="toggleModule('tasks')"><span>📋 Uppgifter</span></label>
                    </div>"""

new_chips = """<div class="filter-chips">
                        <label class="filter-chip"><input type="checkbox" data-module="briefing" onchange="toggleModule('briefing')"><span>☀️ Briefing</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="wellness" onchange="toggleModule('wellness')"><span>⬡ Välmående</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="quote" onchange="toggleModule('quote')"><span>💭 Citat</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="checkin" onchange="toggleModule('checkin')"><span>○ Check-in</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="progress" onchange="toggleModule('progress')"><span>📊 Progress</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="habits" onchange="toggleModule('habits')"><span>✓ Vanor</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="recommendation" onchange="toggleModule('recommendation')"><span>💡 Rekommendation</span></label>
                        <label class="filter-chip active"><input type="checkbox" checked data-module="socialproof" onchange="toggleModule('socialproof')"><span>🏆 Social Proof</span></label>
                        <label class="filter-chip active"><input type="checkbox" checked data-module="challenge" onchange="toggleModule('challenge')"><span>🎯 Utmaning</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="friends" onchange="toggleModule('friends')"><span>👥 Vänner</span></label>
                        <label class="filter-chip active"><input type="checkbox" checked data-module="community" onchange="toggleModule('community')"><span>🌍 Community</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="goals" onchange="toggleModule('goals')"><span>◆ Mål</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="journal" onchange="toggleModule('journal')"><span>📝 Journal</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="calendar" onchange="toggleModule('calendar')"><span>📅 Kalender</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="tasks" onchange="toggleModule('tasks')"><span>📋 Uppgifter</span></label>
                    </div>"""

html = html.replace(old_chips, new_chips)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('Filter chips updated!')
