# Comdira Lifecoach Platform

## Om projektet
Comdira Lifecoach är en plattform för personlig utveckling som kombinerar medkänsla, disciplin och rationalitet.

## 🚀 Snabbstart för VD:n

### GitHub Pages (Demo/Granskning) ⭐ REKOMMENDERAT
**För dig som vill se ändringar direkt utan att uppdatera webbhotell.**

```bash
# 1. Skapa repo på GitHub
# 2. Pusha koden
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/DITT-NAMN/comdira.git
git push -u origin main

# 3. Aktivera GitHub Pages i Settings → Pages → GitHub Actions
# 4. Besök: https://DITT-NAMN.github.io/comdira
```

✅ **Automatisk deploy:** Varje push uppdaterar sidan på 2 minuter!

📖 **Detaljerad guide:** Se `GITHUB_SETUP.md`

### Webbhotell (Full funktionalitet)
**För PHP, databas, login, och riktig funktionalitet.**

1. Ladda upp PHP-filer till webbhotell via FTP
2. Importera `database/comdira.sql` till MySQL
3. Konfigurera `includes/config.php`
4. Besök: `https://din-domän.com`

## Teknisk stack
- **Backend:** PHP 8+, MySQL
- **Frontend:** HTML5, CSS3, JavaScript
- **Demo:** GitHub Pages (statisk hosting)
- **Produktion:** Webbhotell med PHP/MySQL

## Färgschema (Pastellgrön tema)
| Färg | Hex | Användning |
|------|-----|------------|
| Primär | `#90EE90` | Huvudfärg, knappar, framhävning |
| Primär Ljus | `#C8F6C8` | Bakgrunder, hover states |
| Primär Mörk | `#5CB85C` | Text, ikoner |
| Accent | `#98D8C8` | Sekundära element |
| Bakgrund | `#F0FDF0` | Huvudbakgrund |

## Filstruktur
```
comdira/
├── .github/workflows/deploy.yml  # GitHub Actions (automatisk deploy)
├── public/                        # GitHub Pages DEMO
│   ├── index.html                 # Statisk login (demo)
│   ├── dashboard.html             # Statisk dashboard (demo)
│   └── assets/                    # CSS/JS för demo
├── index.php                      # Riktig login (PHP)
├── dashboard.php                  # Riktig dashboard (PHP)
├── assets/                        # CSS/JS för PHP-version
├── includes/                      # PHP-konfiguration
├── database/                      # SQL-schema
├── GITHUB_SETUP.md               # Guide för GitHub
└── README.md                     # Denna fil
```

## Inloggning

### Demo (GitHub Pages)
- URL: `https://DITT-NAMN.github.io/comdira`
- E-post: `demo@comdira.com`
- Lösenord: `demo`
- ⚠️ Ingen riktig databas — allt är mock-data

### Produktion (Webbhotell)
- URL: `https://din-domän.com`
- E-post: `admin@comdira.com`
- Lösenord: `comdira2024`
- ✅ Full funktionalitet med databas

**VIKTIGT:** Ändra lösenordet direkt efter första inloggning!

## Funktioner
- ✅ Inloggningssystem med sessionshantering
- ✅ Dashboard med widgets
- ✅ Daglig check-in (humör, energi, fokus)
- ✅ Vanor/tracking
- ✅ Målhantering med progress
- ✅ Uppgifter/Todo-lista
- ✅ Responsiv design (mobil + desktop)
- ✅ Pastellgrön design enligt varumärket

## De tre pelarna i designen
- **Compassion:** Rundade hörn, mjuka övergångar, välkomnande färger
- **Discipline:** Tydlig struktur, konsekvent layout, organiserad information
- **Rationalitet:** Data-visualisering, tydlig typografi, logisk hierarki

## Teamet
- **Kai** (CTO) — Teknisk ledning
- **Leo** (Lead Dev, Design) — UI/UX, frontend
- **Jin** (Lead Dev, Backend) — PHP, databas, API
- **Zoe** (Lead Dev, QA/Security) — Testning, säkerhet

---
*Comdira — Compassion × Discipline × Rationality*
