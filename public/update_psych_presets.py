html = open('index.html', 'r', encoding='utf-8').read()

# Update preset selector
old_select = """<option value="social">Socialt (Community + Vänner)</option>
                            <option value="overview">Full översikt</option>"""

new_select = """<option value="social">Socialt (Community + Vänner)</option>
                            <option value="psychology">Betéendepsykologi (Habits + Intentions)</option>
                            <option value="overview">Full översikt</option>"""

html = html.replace(old_select, new_select)

# Update presets object to include psychology preset
old_presets = """social: {
                    socialproof: '1x1',
                    challenge: '1x2',
                    community: '2x1',
                    friends: '1x2'
                },"""

new_presets = """social: {
                    socialproof: '1x1',
                    challenge: '1x2',
                    community: '2x1',
                    friends: '1x2'
                },
                psychology: {
                    intent: '1x2',
                    implementation: '2x1',
                    habitstack: '1x2',
                    moodprime: '1x1',
                    gratitude: '1x1'
                },"""

html = html.replace(old_presets, new_presets)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('Presets updated!')
