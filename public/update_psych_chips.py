html = open('index.html', 'r', encoding='utf-8').read()

# Update filter chips to include new psychology widgets
old_chips = """<label class="filter-chip"><input type="checkbox" data-module="goals" onchange="toggleModule('goals')"><span>◆ Mål</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="journal" onchange="toggleModule('journal')"><span>📝 Journal</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="calendar" onchange="toggleModule('calendar')"><span>📅 Kalender</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="tasks" onchange="toggleModule('tasks')"><span>📋 Uppgifter</span></label>"""

new_chips = """<label class="filter-chip"><input type="checkbox" data-module="intent" onchange="toggleModule('intent')"><span>⏰ Intent</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="implementation" onchange="toggleModule('implementation')"><span>🧠 Implementation</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="habitstack" onchange="toggleModule('habitstack')"><span>🥞 Stack</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="moodprime" onchange="toggleModule('moodprime')"><span>😊 Mood</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="gratitude" onchange="toggleModule('gratitude')"><span>🙏 Tacksamhet</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="goals" onchange="toggleModule('goals')"><span>◆ Mål</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="journal" onchange="toggleModule('journal')"><span>📝 Journal</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="calendar" onchange="toggleModule('calendar')"><span>📅 Kalender</span></label>
                        <label class="filter-chip"><input type="checkbox" data-module="tasks" onchange="toggleModule('tasks')"><span>📋 Uppgifter</span></label>"""

html = html.replace(old_chips, new_chips)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('Filter chips updated!')
