#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Read file as binary
with open('index.html', 'rb') as f:
    content = f.read()

# Fix all double-encoded UTF-8 patterns
# These occur when UTF-8 is interpreted as Latin-1 and then re-encoded as UTF-8

# First pass - common patterns
content = content.replace(b'\xc3\x83\xc2\xa5', b'\xc3\xa5')  # å
content = content.replace(b'\xc3\x83\xc2\xa4', b'\xc3\xa4')  # ä  
content = content.replace(b'\xc3\x83\xc2\xb6', b'\xc3\xb6')  # ö
content = content.replace(b'\xc3\x83\xc2\x85', b'\xc3\x85')  # Å
content = content.replace(b'\xc3\x83\xc2\x84', b'\xc3\x84')  # Ä
content = content.replace(b'\xc3\x83\xc2\x96', b'\xc3\x96')  # Ö

# Second pass - other variants
content = content.replace(b'\xc3\x83\xe2\x80\xa6', b'\xc3\x85')  # Å (smart quote variant)
content = content.replace(b'\xc3\x83\xe2\x80\xa1', b'\xc3\x84')  # Ä (smart quote variant)
content = content.replace(b'\xc3\x83\xe2\x80\xb0', b'\xc3\x96')  # Ö (smart quote variant)
content = content.replace(b'\xc3\x83\xe2\x80\x93', b'\xc3\x96')  # Ö (en-dash variant)

# Third pass - single C3 83 followed by UTF-8 sequence
# This is the pattern: original char was 2-byte UTF-8, interpreted as 2 latin-1 chars
import re

# Pattern: C3 83 followed by C2 xx (where xx is the second byte of original UTF-8)
content = content.replace(b'\xc3\x83\xc2\xa5', b'\xc3\xa5')  # å
content = content.replace(b'\xc3\x83\xc2\xa4', b'\xc3\xa4')  # ä
content = content.replace(b'\xc3\x83\xc2\xb6', b'\xc3\xb6')  # ö

# Check if there are still issues
if b'\xc3\x83' in content:
    print("Warning: Still found C3 83 patterns:")
    # Show all occurrences
    idx = 0
    while True:
        idx = content.find(b'\xc3\x83', idx)
        if idx == -1:
            break
        print(f"  Position {idx}: {content[max(0,idx-5):idx+8]}")
        idx += 1
else:
    print("All double encoding fixed!")

# Write back
with open('index.html', 'wb') as f:
    f.write(content)

print("Done!")
