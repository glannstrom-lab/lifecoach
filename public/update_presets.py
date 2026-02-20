html = open('index.html', 'r', encoding='utf-8').read()

# Update preset selector
old_select = """<select class="preset-selector" id="presetSelector" onchange="applyPreset(this.value)">
                            <option value="custom">Anpassad</option>
                            <option value="focus">Fokusläge (Mål + Vanor)</option>
                            <option value="reflection">Reflektionsläge (Journal + Välmående)</option>
                            <option value="productivity">Produktivitetsläge (Uppgifter + Kalender)</option>
                            <option value="overview">Full översikt</option>
                        </select>"""

new_select = """<select class="preset-selector" id="presetSelector" onchange="applyPreset(this.value)">
                            <option value="custom">Anpassad</option>
                            <option value="focus">Fokusläge (Mål + Vanor)</option>
                            <option value="reflection">Reflektionsläge (Journal + Välmående)</option>
                            <option value="productivity">Produktivitetsläge (Uppgifter + Kalender)</option>
                            <option value="social">Socialt (Community + Vänner)</option>
                            <option value="overview">Full översikt</option>
                        </select>"""

html = html.replace(old_select, new_select)

# Update presets object
old_presets = """const presets = {
                focus: {
                    goals: '2x1',
                    habits: '1x2',
                    wellness: '1x1',
                    checkin: '1x1'
                },
                reflection: {
                    wellness: '2x2',
                    journal: '1x2',
                    checkin: '1x1'
                },
                productivity: {
                    tasks: '1x2',
                    calendar: '1x1',
                    goals: '2x1',
                    habits: '1x1'
                },
                overview: {
                    wellness: '2x2',
                    habits: '1x2',
                    goals: '2x1',
                    checkin: '1x1',
                    journal: '1x1',
                    calendar: '1x1'
                }
            };"""

new_presets = """const presets = {
                social: {
                    socialproof: '1x1',
                    challenge: '1x2',
                    community: '2x1',
                    friends: '1x2'
                },
                focus: {
                    goals: '2x1',
                    habits: '1x2',
                    wellness: '1x1',
                    checkin: '1x1'
                },
                reflection: {
                    wellness: '2x2',
                    journal: '1x2',
                    checkin: '1x1'
                },
                productivity: {
                    tasks: '1x2',
                    calendar: '1x1',
                    goals: '2x1',
                    habits: '1x1'
                },
                overview: {
                    wellness: '2x2',
                    habits: '1x2',
                    goals: '2x1',
                    checkin: '1x1',
                    journal: '1x1',
                    calendar: '1x1'
                }
            };"""

html = html.replace(old_presets, new_presets)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('Presets updated!')
