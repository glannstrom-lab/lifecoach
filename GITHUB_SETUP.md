# GitHub Setup Guide för Comdira

## Snabbstart (3 steg)

### Steg 1: Skapa GitHub-repo
1. Gå till [github.com](https://github.com)
2. Klicka på "+" → "New repository"
3. Namn: `comdira`
4. Välj "Public" (eller Private om du har Pro)
5. Klicka "Create repository"

### Steg 2: Ladda upp koden
```bash
# Gå till projektmappen
cd comdira

# Initiera git
git init

# Lägg till alla filer
git add .

# Commit
git commit -m "Initial commit: Comdira MVP"

# Koppla till GitHub (ersätt YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/comdira.git

# Pusha till GitHub
git push -u origin main
```

### Steg 3: Aktivera GitHub Pages
1. I ditt repo på GitHub, gå till "Settings"
2. Scrolla ner till "Pages" (i vänster meny)
3. Under "Source", välj "GitHub Actions"
4. Klart! 🎉

## Vad händer nu?

### Automatisk deploy
Varje gång du pushar till `main`-branchen:
1. GitHub Actions körs automatiskt (tar ~2 minuter)
2. Din kod deployas till GitHub Pages
3. Du ser resultatet på: `https://YOUR_USERNAME.github.io/comdira`

### För att se nya ändringar
```bash
# Gör ändringar i koden
# ...

# Pusha till GitHub
git add .
git commit -m "Beskrivning av ändringar"
git push

# Vänta 2 minuter
# Gå till https://YOUR_USERNAME.github.io/comdira
```

## Filstruktur för GitHub

```
comdira/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Automatisk deploy (redan skapad)
├── public/                      # DETTA syns på webben
│   ├── index.html              # Login-sida (demo)
│   ├── dashboard.html          # Dashboard (demo)
│   └── assets/
│       ├── css/
│       │   └── style.css       # Stilar
│       ├── js/                 # JavaScript
│       └── images/             # Bilder
├── index.php                   # PHP-version (för webbhotell)
├── dashboard.php               # PHP-version (för webbhotell)
├── includes/                   # PHP-kod
├── database/                   # SQL
└── GITHUB_SETUP.md            # Denna fil
```

## Två miljöer

| Miljö | URL | Syfte | Uppdatering |
|-------|-----|-------|-------------|
| **GitHub Pages** | `https://YOUR_USERNAME.github.io/comdira` | Demo, designgranskning | Automatisk vid push |
| **Webbhotell** | `https://comdira.com` | Riktig funktionalitet (PHP) | Manuell/FTP |

## Vanliga kommandon

```bash
# Se status
git status

# Lägg till nya filer
git add nyfil.html

# Commit med beskrivning
git commit -m "Lade till ny feature"

# Pusha till GitHub
git push

# Hämta senaste ändringar
git pull

# Se historik
git log --oneline
```

## Felsökning

### "Page not found" på GitHub Pages
- Vänta 2-5 minuter efter push
- Kontrollera att `.github/workflows/deploy.yml` finns
- Gå till "Actions" i GitHub-repot och kolla om workflow kördes

### "Permission denied" vid push
- Kontrollera att du har rätt remote: `git remote -v`
- Logga in på GitHub: `git config --global user.name "Ditt Namn"`
- `git config --global user.email "din@email.com"`

### Ändringar syns inte
- Töm webbläsarens cache (Ctrl+F5)
- Kontrollera att du pushat till `main` och inte en annan branch
- Gå till Actions-fliken i GitHub och kolla om bygget lyckades

## Tips för VD:n

1. **Bokmärk båda URL:erna**
   - GitHub Pages (demo): för snabb granskning
   - Webbhotell (riktig): för full funktionalitet

2. **Se ändringar i realtid**
   - Pusha kod → Gå till GitHub Actions → Se status → Besök sidan

3. **Godkänn innan produktion**
   - Teamet pushar till GitHub Pages
   - Du granskar och godkänner
   - Jin deployar till webbhotell

4. **Mobiltestning**
   - GitHub Pages fungerar på mobil direkt
   - Perfekt för att testa responsiv design

---

Frågor? Kontakta Kai (CTO) eller Jin (Backend Lead).
