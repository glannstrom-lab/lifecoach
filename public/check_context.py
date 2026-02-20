#!/usr/bin/env python3

with open('index.html', 'rb') as f:
    data = f.read()

pos = 42159
print('Context:', data[pos-20:pos+20])

# Check for specific patterns
print()
print('Checking broken patterns...')
if b'\xc3\x83\xe2\x80\x9e' in data:
    print('Found: C3 83 + E2 80 9E (likely ä)')
if b'\xc3\x83\xe2\x80\xa6' in data:
    print('Found: C3 83 + E2 80 A6 (likely å)')
if b'\xc3\x83\xe2\x80\x93' in data:
    print('Found: C3 83 + E2 80 93 (likely ö)')
