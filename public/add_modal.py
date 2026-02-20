html = open('index.html', 'r', encoding='utf-8').read()

share_modal = """<!-- Share Modal -->
<div class="share-modal-overlay" id="shareModal" onclick="closeShareModal(event)">
    <div class="share-modal" onclick="event.stopPropagation()">
        <h3 style="text-align: center; margin-bottom: 20px; color: var(--text-primary);">Dela din framsteg! 🎉</h3>
        <div class="share-preview">
            <div class="share-preview-content">
                <div class="share-preview-logo">COMDIRA</div>
                <div class="share-preview-stat">23</div>
                <div class="share-preview-label">dagar i rad! 🔥</div>
                <div class="share-preview-streak">
                    <span>🔥</span>
                    <span>Meditation</span>
                </div>
                <div class="share-preview-hashtags">#Comdira #Streak #SelfImprovement</div>
            </div>
        </div>
        <div class="share-options">
            <div class="share-option" onclick="shareTo('instagram')">
                <div class="share-option-icon">📸</div>
                <div class="share-option-label">Instagram</div>
            </div>
            <div class="share-option" onclick="shareTo('twitter')">
                <div class="share-option-icon">🐦</div>
                <div class="share-option-label">Twitter</div>
            </div>
            <div class="share-option" onclick="shareTo('facebook')">
                <div class="share-option-icon">📘</div>
                <div class="share-option-label">Facebook</div>
            </div>
            <div class="share-option" onclick="shareTo('copy')">
                <div class="share-option-icon">📋</div>
                <div class="share-option-label">Kopiera</div>
            </div>
        </div>
        <button class="share-close" onclick="closeShareModal()">Stäng</button>
    </div>
</div>"""

body_end = html.find('</body>')
new_html = html[:body_end] + share_modal + html[body_end:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print('Share modal added!')
