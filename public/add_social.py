html = open('index.html', 'r', encoding='utf-8').read()

# Find the position after the widget-grid opening div
grid_start = html.find('<div class=\"widget-grid\" id=\"widgetGrid\">')
insert_pos = html.find('>', grid_start) + 1

social_widgets = """
                    <!-- Social Proof Widget - 1x1 -->
                    <div class=\"widget size-1x1 social-proof-widget\" data-id=\"socialproof\" data-module=\"socialproof\" data-size=\"1x1\">
                        <div class=\"social-proof-content\">
                            <div class=\"social-proof-avatars\">
                                <div class=\"social-avatar\">👤</div>
                                <div class=\"social-avatar\">👩</div>
                                <div class=\"social-avatar\">👨</div>
                                <div class=\"social-avatar social-avatar-more\">+</div>
                            </div>
                            <div class=\"social-proof-number\">1,247</div>
                            <div class=\"social-proof-text\">personer har checkat in idag</div>
                            <div class=\"social-proof-badge\">
                                <span>🏆</span>
                                <span>Du är i topp 10%!</span>
                            </div>
                        </div>
                    </div>

                    <!-- Challenge Widget - 1x2 -->
                    <div class=\"widget size-1x2 challenge-widget\" data-id=\"challenge\" data-module=\"challenge\" data-size=\"1x2\">
                        <div class=\"widget-header\" style=\"border-color: rgba(39, 174, 96, 0.3);\">
                            <div class=\"widget-title\"><span class=\"widget-icon\">🎯</span> Veckans Utmaning</div>
                            <div class=\"widget-controls\">
                                <button class=\"widget-btn\" onclick=\"toggleCollapse(this)\">−</button>
                            </div>
                        </div>
                        <div class=\"widget-content\">
                            <div class=\"challenge-header\">
                                <div class=\"challenge-icon\">🙏</div>
                                <div class=\"challenge-title-section\">
                                    <div class=\"challenge-title\">7 dagar av tacksamhet</div>
                                    <div class=\"challenge-subtitle\">Skriv 3 saker du är tacksam för</div>
                                </div>
                                <div class=\"challenge-days\">Dag 4/7</div>
                            </div>
                            <div class=\"challenge-progress-container\">
                                <div class=\"challenge-progress-header\">
                                    <span>Din progress</span>
                                    <span>57%</span>
                                </div>
                                <div class=\"challenge-progress-bar\">
                                    <div class=\"challenge-progress-fill\" style=\"width: 57%\"></div>
                                </div>
                                <div class=\"challenge-community\">
                                    <span>👥</span>
                                    <span>Community:</span>
                                    <div class=\"challenge-community-bar\">
                                        <div class=\"challenge-community-fill\" style=\"width: 68%\"></div>
                                    </div>
                                    <span>68%</span>
                                </div>
                            </div>
                            <div class=\"challenge-actions\">
                                <button class=\"challenge-btn challenge-btn-primary\">Checka in idag</button>
                                <button class=\"challenge-btn challenge-btn-secondary\">Se ledartavla</button>
                            </div>
                        </div>
                    </div>

                    <!-- Community Stats Widget - 2x1 -->
                    <div class=\"widget size-2x1 community-stats-widget\" data-id=\"community\" data-module=\"community\" data-size=\"2x1\">
                        <div class=\"widget-header\" style=\"border-color: rgba(52, 152, 219, 0.3);\">
                            <div class=\"widget-title\"><span class=\"widget-icon\">🌍</span> Community</div>
                            <div class=\"widget-controls\">
                                <button class=\"widget-btn\" onclick=\"toggleCollapse(this)\">−</button>
                                <button class=\"widget-btn\" onclick=\"toggleSizeMenu(this)\">⤢</button>
                            </div>
                        </div>
                        <div class=\"size-menu\">
                            <div class=\"size-option active\" data-size=\"2x1\" onclick=\"resizeWidget(this)\"><div class=\"size-preview size-preview-2x1\"><div></div><div></div></div><span>Bred</span></div>
                            <div class=\"size-option\" data-size=\"2x2\" onclick=\"resizeWidget(this)\"><div class=\"size-preview size-preview-2x2\"><div></div><div></div><div></div><div></div></div><span>Stor</span></div>
                        </div>
                        <div class=\"widget-content\">
                            <div class=\"community-stats-header\">
                                <div class=\"community-stats-title\">Tillsammans gör vi skillnad</div>
                                <div class=\"community-stats-subtitle\">12,847 aktiva medlemmar denna vecka</div>
                            </div>
                            <div class=\"community-big-stat\">
                                <div class=\"community-big-number\">5,247</div>
                                <div class=\"community-big-label\">timmar mediterade tillsammans 🧘</div>
                            </div>
                            <div class=\"community-goals\">
                                <div class=\"community-goal\">
                                    <div class=\"community-goal-header\">
                                        <span class=\"community-goal-name\">🎯 Gemensamt mål: 10,000 träningar</span>
                                        <span class=\"community-goal-percent\">73%</span>
                                    </div>
                                    <div class=\"community-goal-bar\">
                                        <div class=\"community-goal-fill\" style=\"width: 73%\"></div>
                                    </div>
                                </div>
                            </div>
                            <div class=\"community-belonging\">
                                <div class=\"community-belonging-text\">\"Du är en del av något större. Tillsammans växer vi.\" 💚</div>
                            </div>
                        </div>
                    </div>

                    <!-- Friend Activity Widget - 1x2 (opt-in) -->
                    <div class=\"widget size-1x2 friend-activity-widget\" data-id=\"friends\" data-module=\"friends\" data-size=\"1x2\">
                        <div class=\"widget-header\" style=\"border-color: rgba(155, 89, 182, 0.3);\">
                            <div class=\"widget-title\"><span class=\"widget-icon\">👥</span> Vänner</div>
                            <div class=\"widget-controls\">
                                <button class=\"widget-btn\" onclick=\"toggleCollapse(this)\">−</button>
                            </div>
                        </div>
                        <div class=\"widget-content\">
                            <div class=\"friend-activity-header\">
                                <span class=\"friend-activity-title\">Vänaktivitet</span>
                                <div class=\"friend-activity-toggle\">
                                    <span>Visa</span>
                                    <div class=\"toggle-switch\" id=\"friendToggle\" onclick=\"toggleFriendActivity()\"></div>
                                </div>
                            </div>
                            <div class=\"friend-activity-list\" id=\"friendActivityList\">
                                <div class=\"friend-activity-item\">
                                    <div class=\"friend-avatar\">👩</div>
                                    <div class=\"friend-activity-content\">
                                        <div class=\"friend-name\">Anna</div>
                                        <div class=\"friend-action\">Checkade just in 🧘</div>
                                    </div>
                                    <div class=\"friend-streak\">
                                        <span>🔥</span>
                                        <span>12</span>
                                    </div>
                                    <div class=\"friend-activity-time\">2m</div>
                                </div>
                                <div class=\"friend-activity-item\">
                                    <div class=\"friend-avatar\">👨</div>
                                    <div class=\"friend-activity-content\">
                                        <div class=\"friend-name\">Marcus</div>
                                        <div class=\"friend-action\">Nådde sitt mål! 🎯</div>
                                    </div>
                                    <div class=\"friend-streak\">
                                        <span>🔥</span>
                                        <span>31</span>
                                    </div>
                                    <div class=\"friend-activity-time\">15m</div>
                                </div>
                                <div class=\"friend-activity-item\">
                                    <div class=\"friend-avatar\">👩</div>
                                    <div class=\"friend-activity-content\">
                                        <div class=\"friend-name\">Lisa</div>
                                        <div class=\"friend-action\">Skrev i journalen ✍️</div>
                                    </div>
                                    <div class=\"friend-streak\">
                                        <span>🔥</span>
                                        <span>8</span>
                                    </div>
                                    <div class=\"friend-activity-time\">1h</div>
                                </div>
                            </div>
                            <div class=\"friend-comparison\">
                                <span class=\"friend-comparison-text\">🏃 Du leder just nu! Bra jobbat!</span>
                                <span class=\"friend-comparison-badge\">#1</span>
                            </div>
                        </div>
                    </div>
"""

new_html = html[:insert_pos] + social_widgets + html[insert_pos:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print('Widgets added!')
