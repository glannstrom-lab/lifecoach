html = open('index.html', 'r', encoding='utf-8').read()

# Add floating button before </main>
floating_btn = """<!-- Floating Share Button -->
<button class="floating-share-btn" onclick="openShareModal()" title="Dela din framsteg!">
    <span>📤</span>
</button>"""

main_end = html.rfind('</main>')
new_html = html[:main_end] + floating_btn + html[main_end:]

# Add JavaScript functions before last </script>
js_functions = """
        // Toggle friend activity (opt-in)
        function toggleFriendActivity() {
            const toggle = document.getElementById('friendToggle');
            const list = document.getElementById('friendActivityList');
            toggle.classList.toggle('off');
            if (toggle.classList.contains('off')) {
                list.style.opacity = '0.3';
            } else {
                list.style.opacity = '1';
            }
        }

        // Share modal functions
        function openShareModal() {
            document.getElementById('shareModal').classList.add('show');
        }

        function closeShareModal(event) {
            if (!event || event.target.id === 'shareModal') {
                document.getElementById('shareModal').classList.remove('show');
            }
        }

        function shareTo(platform) {
            const text = "Jag har nått 23 dagars streak på Comdira! 🔥 #Comdira #Streak #SelfImprovement";
            switch(platform) {
                case 'instagram':
                    alert('Bilden sparad! Öppna Instagram för att dela. 📸');
                    break;
                case 'twitter':
                    window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`, '_blank');
                    break;
                case 'facebook':
                    window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(window.location.href)}`, '_blank');
                    break;
                case 'copy':
                    navigator.clipboard.writeText(text);
                    alert('Kopierat till urklipp! 📋');
                    break;
            }
        }
"""

script_end = new_html.rfind('</script>')
new_html = new_html[:script_end] + js_functions + new_html[script_end:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print('Button and JS added!')
