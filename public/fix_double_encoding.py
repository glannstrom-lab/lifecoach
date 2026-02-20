#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import codecs

# Read file as binary
with open('index.html', 'rb') as f:
    content = f.read()

# Common double-encoded UTF-8 patterns
# These occur when UTF-8 is interpreted as Latin-1 and then re-encoded as UTF-8
double_encoded = {
    b'\xc3\x83\xc2\xa5': b'\xc3\xa5',  # å
    b'\xc3\x83\xc2\xa4': b'\xc3\xa4',  # ä
    b'\xc3\x83\xc2\xb6': b'\xc3\xb6',  # ö
    b'\xc3\x83\xe2\x80\xa6': b'\xc3\x85',  # Å
    b'\xc3\x83\xe2\x80\xa1': b'\xc3\x84',  # Ä
    b'\xc3\x83\xe2\x80\xb0': b'\xc3\x96',  # Ö
    b'\xc3\x83\xc2\xa4': b'\xc3\xa4',  # ä
    b'\xc3\x83\xc2\xa5': b'\xc3\xa5',  # å
}

# Fix double encoding
fixed = content
for broken, correct in double_encoded.items():
    if broken in fixed:
        print(f"Fixing: {broken} -> {correct}")
        fixed = fixed.replace(broken, correct)

# Also try single replacement character fixes
# ö is \xc3\xb6 but if double encoded it becomes \xc3\x83\xc2\xb6
fixed = fixed.replace(b'\xc3\x83\xc2\xb6', b'\xc3\xb6')
fixed = fixed.replace(b'\xc3\x83\xc2\xa4', b'\xc3\xa4')
fixed = fixed.replace(b'\xc3\x83\xc2\xa5', b'\xc3\xa5')

# Write back
with open('index.html', 'wb') as f:
    f.write(fixed)

print("Fixed double encoding issues!")
