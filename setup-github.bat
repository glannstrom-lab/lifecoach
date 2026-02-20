@echo off
chcp 65001 >nul
echo.
echo ================================================
echo   Comdira GitHub Setup - Automatisk
echo ================================================
echo.
echo Detta script kommer:
echo 1. Kontrollera om Git ar installerat
echo 2. Ladda upp all kod till GitHub
echo 3. Forbereda for GitHub Pages
echo.
pause
echo.

:: Kontrollera om Git ar installerat
git --version >nul 2>&1
if errorlevel 1 (
    echo [FEL] Git ar inte installerat!
    echo.
    echo Installera Git fran: https://git-scm.com/download/win
    echo Klicka "Next" pa allt, sedan kor detta script igen.
    echo.
    pause
    exit /b 1
)

echo [OK] Git ar installerat
git --version
echo.

:: Ga till ratt mapp
cd /d "C:\Users\Mikael\Desktop\AI\lifecoach\comdira"
if errorlevel 1 (
    echo [FEL] Hittade inte mappen!
    echo Kontrollera sokvagen: C:\Users\Mikael\Desktop\AI\lifecoach\comdira
    pause
    exit /b 1
)

echo [OK] Ar i ratt mapp: %cd%
echo.

:: Initiera Git (om inte redan gjort)
if not exist ".git" (
    echo [1/5] Initierar Git...
    git init
    if errorlevel 1 (
        echo [FEL] Kunde inte initiera Git
        pause
        exit /b 1
    )
) else (
    echo [1/5] Git ar redan initierat
)
echo.

:: Lagg till alla filer
echo [2/5] Lagger till filer...
git add .
if errorlevel 1 (
    echo [FEL] Kunde inte lagga till filer
    pause
    exit /b 1
)
echo [OK] Filer tillagda
echo.

:: Commit
echo [3/5] Sparar version (commit)...
git commit -m "Initial commit: Comdira Lifecoach MVP - Auto-deploy setup"
if errorlevel 1 (
    echo [INFO] Inga nya andringar att commita (kan vara OK)
)
echo.

:: Koppla till GitHub
echo [4/5] Kopplar till GitHub...
git remote remove origin 2>nul
git remote add origin https://github.com/glannstrom-lab/lifecoach.git
if errorlevel 1 (
    echo [FEL] Kunde inte koppla till GitHub
    pause
    exit /b 1
)
echo [OK] Kopplad till GitHub
echo.

:: Pusha
echo [5/5] Laddar upp till GitHub...
echo.
echo ================================================
echo VIKTIGT: Du kommer att fa logga in pa GitHub
echo ================================================
echo.
echo Anvandarnamn: glannstrom-lab
echo Losenord: Ditt GitHub-losenord ELLER Personal Access Token
echo.
echo Om du inte har ett token:
echo 1. Ga till https://github.com/settings/tokens
echo 2. Generate new token (classic)
echo 3. Markera "repo" och skapa
echo 4. Kopiera token och anvand som losenord
echo.
pause
echo.

git push -u origin main
if errorlevel 1 (
    echo.
    echo [FORSOK MED MASTER ISTALLET...]
    git push -u origin master
)

if errorlevel 1 (
    echo.
    echo [FEL] Kunde inte pusha till GitHub
    echo Vanliga orsaker:
    echo - Fel anvandarnamn/losenord
    echo - Repo finns inte (skapa pa github.com forst)
    echo - Natverksproblem
    echo.
    pause
    exit /b 1
)

echo.
echo ================================================
echo [OK] KODEN AR UPPE PA GITHUB!
echo ================================================
echo.
echo Nasta steg (gor detta manuellt):
echo.
echo 1. Ga till: https://github.com/glannstrom-lab/lifecoach/settings/pages
echo 2. Under "Build and deployment"
echo 3. Andra Source till "GitHub Actions"
echo 4. Klicka Save
echo 5. Vanta 2 minuter
echo 6. Besok: https://glannstrom-lab.github.io/lifecoach
echo.
echo Vill du oppna webblasaren nu? (j/n)
set /p openbrowser=
if /i "%openbrowser%"=="j" (
    start https://github.com/glannstrom-lab/lifecoach/settings/pages
)

echo.
pause
