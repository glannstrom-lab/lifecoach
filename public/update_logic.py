html = open('index.html', 'r', encoding='utf-8').read()

# Update preset logic
old_logic = """if (presets[preset]) {
                widgets.forEach(widget => {
                    const id = widget.dataset.id;
                    if (presets[preset][id]) {
                        widget.classList.remove('size-1x1', 'size-1x2', 'size-2x1', 'size-2x2');
                        widget.classList.add(`size-${presets[preset][id]}`);
                        widget.dataset.size = presets[preset][id];
                        widget.classList.remove('collapsed');
                        const collapseBtn = widget.querySelector('.widget-btn:nth-child(2)');
                        if (collapseBtn) collapseBtn.textContent = '−';
                    } else if (preset !== 'overview') {
                        widget.classList.add('collapsed');
                        const collapseBtn = widget.querySelector('.widget-btn:nth-child(2)');
                        if (collapseBtn) collapseBtn.textContent = '+';
                    }
                });
                saveLayout();
            }"""

new_logic = """if (presets[preset]) {
                widgets.forEach(widget => {
                    const id = widget.dataset.id;
                    if (presets[preset][id]) {
                        widget.classList.remove('size-1x1', 'size-1x2', 'size-2x1', 'size-2x2');
                        widget.classList.add(`size-${presets[preset][id]}`);
                        widget.dataset.size = presets[preset][id];
                        widget.classList.remove('collapsed');
                        const collapseBtn = widget.querySelector('.widget-btn:nth-child(2)');
                        if (collapseBtn) collapseBtn.textContent = '−';
                        widget.style.display = '';
                    } else if (preset !== 'overview' && preset !== 'social') {
                        widget.classList.add('collapsed');
                        const collapseBtn = widget.querySelector('.widget-btn:nth-child(2)');
                        if (collapseBtn) collapseBtn.textContent = '+';
                    } else if (preset === 'social') {
                        widget.style.display = 'none';
                    }
                });
                document.querySelectorAll('.filter-chip input').forEach(checkbox => {
                    const chip = checkbox.closest('.filter-chip');
                    const module = checkbox.dataset.module;
                    if (presets[preset][module]) {
                        checkbox.checked = true;
                        chip.classList.add('active');
                    } else if (preset === 'social') {
                        checkbox.checked = false;
                        chip.classList.remove('active');
                    }
                });
                saveLayout();
            }"""

html = html.replace(old_logic, new_logic)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('Preset logic updated!')
