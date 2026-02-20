html = open('index.html', 'r', encoding='utf-8').read()

# CSS styles for psychology widgets
css_styles = """
        /* === INTENT IMPLEMENTATION WIDGET === */
        .intent-widget {
            background: linear-gradient(135deg, #FEF5E7 0%, #FAD7A0 100%);
            border: 2px solid #E67E22;
        }
        .time-slots {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }
        .time-slot {
            padding: 12px 16px;
            background: white;
            border: 2px solid rgba(230, 126, 34, 0.2);
            border-radius: 12px;
            font-size: 14px;
            font-weight: 600;
            color: #935116;
            cursor: pointer;
            transition: all 0.2s;
        }
        .time-slot:hover {
            border-color: #E67E22;
            transform: translateY(-2px);
        }
        .time-slot.selected {
            background: #E67E22;
            color: white;
            border-color: #E67E22;
        }

        /* === IMPLEMENTATION INTENTIONS WIDGET === */
        .implementation-widget {
            background: linear-gradient(135deg, #F5EEF8 0%, #D7BDE2 100%);
            border: 2px solid #9B59B6;
        }
        .implementation-form {
            background: white;
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 16px;
        }
        .implementation-row {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
        }
        .implementation-row:last-child {
            margin-bottom: 0;
        }
        .implementation-label {
            font-weight: 700;
            color: #9B59B6;
            font-size: 14px;
            min-width: 70px;
        }
        .implementation-select {
            flex: 1;
            padding: 12px;
            border: 2px solid rgba(155, 89, 182, 0.2);
            border-radius: 10px;
            font-size: 14px;
            color: #5B2C6F;
            background: white;
            cursor: pointer;
        }
        .implementation-select:focus {
            outline: none;
            border-color: #9B59B6;
        }
        .implementation-save {
            width: 100%;
            padding: 14px;
            background: #9B59B6;
            color: white;
            border: none;
            border-radius: 12px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .implementation-save:hover {
            background: #7D3C98;
            transform: translateY(-2px);
        }

        /* === HABIT STACKING WIDGET === */
        .habit-stack-widget {
            background: linear-gradient(135deg, #EBF5FB 0%, #AED6F1 100%);
            border: 2px solid #3498DB;
        }
        .habit-stack-visual {
            background: white;
            border-radius: 16px;
            padding: 20px;
            margin-bottom: 16px;
            text-align: center;
        }
        .habit-stack-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px;
            border-radius: 12px;
            margin-bottom: 8px;
        }
        .habit-stack-item.existing {
            background: rgba(52, 152, 219, 0.1);
            border: 2px solid rgba(52, 152, 219, 0.3);
        }
        .habit-stack-item.new {
            background: rgba(46, 204, 113, 0.1);
            border: 2px solid rgba(46, 204, 113, 0.3);
        }
        .habit-stack-icon {
            font-size: 24px;
        }
        .habit-stack-text {
            font-size: 14px;
            font-weight: 600;
            color: #1A5276;
        }
        .habit-stack-arrow {
            font-size: 20px;
            margin: 8px 0;
            color: #5DADE2;
        }
        .habit-stack-builder {
            background: white;
            border-radius: 16px;
            padding: 16px;
        }
        .habit-stack-select {
            width: 100%;
            padding: 12px;
            margin-bottom: 10px;
            border: 2px solid rgba(52, 152, 219, 0.2);
            border-radius: 10px;
            font-size: 14px;
            color: #1A5276;
            background: white;
            cursor: pointer;
        }
        .habit-stack-save {
            width: 100%;
            padding: 12px;
            background: #3498DB;
            color: white;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .habit-stack-save:hover {
            background: #2980B9;
            transform: translateY(-2px);
        }

        /* === MOOD-PRIMING WIDGET === */
        .mood-prime-widget {
            background: linear-gradient(135deg, #FADBD8 0%, #F5B7B1 100%);
            border: 2px solid #E74C3C;
        }
        .mood-options {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }
        .mood-option {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
            padding: 16px 8px;
            background: white;
            border: 2px solid rgba(231, 76, 60, 0.2);
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .mood-option:hover {
            border-color: #E74C3C;
            transform: scale(1.05);
        }
        .mood-option.selected {
            background: #E74C3C;
            border-color: #E74C3C;
        }
        .mood-option.selected .mood-emoji,
        .mood-option.selected .mood-label {
            color: white;
        }
        .mood-emoji {
            font-size: 28px;
        }
        .mood-label {
            font-size: 12px;
            font-weight: 600;
            color: #922B21;
        }
        .mood-suggestion {
            animation: fadeInUp 0.3s ease;
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* === GRATITUDE NUDGE WIDGET === */
        .gratitude-nudge-widget {
            background: linear-gradient(135deg, #D5F5E3 0%, #A9DFBF 100%);
            border: 2px solid #27AE60;
        }
        .gratitude-icon {
            font-size: 48px;
            margin-bottom: 12px;
            animation: gentlePulse 3s ease-in-out infinite;
        }
        @keyframes gentlePulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }
        .gratitude-quick-options {
            display: flex;
            gap: 8px;
            justify-content: center;
            margin-bottom: 12px;
        }
        .gratitude-quick {
            padding: 8px 14px;
            background: white;
            border: 2px solid rgba(39, 174, 96, 0.3);
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            color: #1E8449;
            cursor: pointer;
            transition: all 0.2s;
        }
        .gratitude-quick:hover {
            background: #27AE60;
            color: white;
            border-color: #27AE60;
        }
        .gratitude-quick.selected {
            background: #27AE60;
            color: white;
            border-color: #27AE60;
        }
        .gratitude-write {
            width: 100%;
            padding: 12px;
            background: transparent;
            border: 2px dashed rgba(39, 174, 96, 0.4);
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            color: #27AE60;
            cursor: pointer;
            transition: all 0.2s;
            margin-bottom: 12px;
        }
        .gratitude-write:hover {
            background: rgba(39, 174, 96, 0.1);
        }
        .gratitude-streak {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px;
            background: rgba(230, 126, 34, 0.1);
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            color: #E67E22;
        }
"""

# Find the last style tag before responsive section
style_end = html.rfind('@media (max-width: 768px)')
new_html = html[:style_end] + css_styles + '\n        ' + html[style_end:]

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(new_html)

print('CSS added!')
