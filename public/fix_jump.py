$content = Get-Content index.html -Raw

# Fix 1: Change align-items: start to stretch for more stable layout
$content = $content -replace 'align-items: start;', 'align-items: stretch;'

# Fix 2: Remove or reduce animations that could cause jumping
$content = $content -replace 'animation: fadeIn 0.2s ease;', 'animation: none;'

# Fix 3: Ensure widgets have stable sizing
$content = $content -replace 'grid-auto-rows: minmax\(180px, auto\);', 'grid-auto-rows: minmax(200px, auto);'

$content | Set-Content index.html -Encoding UTF8
Write-Host "Fixed layout issues"
