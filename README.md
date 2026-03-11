# Slap Battles Multi Macro

Makro do automatyzacji farmowania odznak i przedmiotów w **Slap Battles** (Roblox).
Składa się z 6 niezależnych modułów, systemu licencji opartego na HWID oraz panelu administracyjnego.

---

## Pobieranie

Pobierz najnowszą wersję z zakładki **[Releases](../../releases/latest)**.
Plik `SlapBattlesMultiMacro.exe` — nie wymaga instalacji AutoHotkey.

---

## Pierwsze uruchomienie

1. Uruchom `SlapBattlesMultiMacro.exe`
2. Przeczytaj i zaakceptuj [Warunki Użytkowania](docs/ToS-Makro.md) (otwierają się w przeglądarce)
3. Wpisz klucz licencyjny (format: `XXXX-XXXX-XXXX-XXXX`)
4. Makro wyśle Twój HWID do administratora — **poczekaj na aktywację**
5. Po aktywacji uruchom makro ponownie
6. Wybierz moduł z menu głównego

---

## Skróty klawiszowe

| Klawisz | Akcja |
|---------|-------|
| `F6` | Start / Stop (przełącznik) |
| `F8` | Bezpieczne wyjście (zapisuje dane) |
| `F9` | Panic Stop — zatrzymanie + zwolnienie wszystkich klawiszy |

---

## Moduły

### BOB — Portal
Automatycznie klika portal, wykrywa kolory baz i wykonuje sekwencję ruchu i resetu.
**Szansa na Boba: 1/7500**

### Trap — Brick Master
Automatycznie klika cegłę co 5 sekund. Cel: 1000 cegieł (odznaka Brick Master).

### Obby Mastery
Automatycznie kładzie części Obby co 3 sekundy. Cel: 2000 części (Quest 3 Mastery).

### Replica Bob
Automatycznie klika E co 14 sekund (cooldown repliki Boba).
**Szansa na Boba: 1/7500**

### Manual Bob
Po naciśnięciu przypisanego klawisza wykonuje sekwencję: `Esc → R → Enter` (respawn).
Domyślny klawisz: `E`

### Critical Glove
Po naciśnięciu przypisanego klawisza wykonuje combo: `Spacja + LPM` (trafienie krytyczne przez skok).
Domyślny klawisz: Prawy przycisk myszy

---

## Konfiguracja

Każdy moduł ma własne okno ustawień (przycisk **⚙ Ustawienia**):

- **Auto-pauza** — wstrzymuje makro gdy Roblox nie jest aktywny
- **Webhook Discord** — URL webhooka do raportowania statystyk
- **Zaawansowane timingowe** — precyzyjne dostosowanie opóźnień
- **Debugowanie** (chronione kodem PIN) — krytyczne ustawienia

Konfiguracja zapisywana jest automatycznie w:
`%AppData%\SBMM\`

---

## Dokumenty prawne

| Dokument | Dotyczy |
|----------|---------|
| [Warunki Użytkowania — Makro](docs/ToS-Makro.md) | Zasady korzystania z programu `SlapBattlesMultiMacro.exe` |
| [Polityka Prywatności — Makro](docs/PrivacyPolicy-Makro.md) | Jakie dane zbiera Makro i jak są chronione |
| [Warunki Użytkowania — Bot](docs/ToS-Bot.md) | Zasady korzystania z bota administracyjnego Discord |
| [Polityka Prywatności — Bot](docs/PrivacyPolicy-Bot.md) | Jakie dane przetwarza Bot i jak są chronione |

---

## Wersjonowanie

Format wersji: `vDużyUpdate.Update.Bugfix`

Przykłady:
- `v1.0.0` — pierwsza publiczna wersja
- `v1.1.0` — nowy moduł / duża zmiana
- `v1.1.1` — poprawka błędu

---

## Dla administratorów — konfiguracja serwera

### Wymagania

- Python 3.11+
- Konto Replit (lub inny hosting)
- Bot Discord
- GitHub account

### Konfiguracja Gist (przechowywanie licencji)

Ponieważ repo jest **publiczne**, plik `licenses.json` przechowywany jest w prywatnym GitHub Gist:

1. Wejdź na [gist.github.com](https://gist.github.com)
2. Utwórz nowy Gist:
   - Filename: `licenses.json`
   - Zawartość: `{}`
   - Typ: **Secret** (nie Public!)
3. Skopiuj **Gist ID** z URL: `gist.github.com/nazwauzytkownika/`**`to_jest_gist_id`**
4. Skopiuj **Raw URL** (przycisk "Raw") — to jest URL dla makra
5. Otwórz `SlapBattlesMultiMacro.ahk` i podmień w linii 15:
   ```
   global jsonURL := "https://gist.githubusercontent.com/TWOJ_USERNAME/TWOJ_GIST_ID/raw/licenses.json"
   ```
   > Po zmianie URL zrób nowy Release (patrz niżej)

### Replit Secrets

W Replit dodaj następujące Secrets (nie wklejaj ich do kodu!):

| Secret | Opis |
|--------|------|
| `DISCORD_TOKEN` | Token bota Discord |
| `GIST_TOKEN` | GitHub token z zakresem `gist` (github.com/settings/tokens) |
| `GIST_ID` | ID Gista z `licenses.json` |
| `ADMIN_CHANNEL_ID` | ID kanału Discord do raportowania |

Plik z przykładem: `SerwerIBot/.env.example`

### Uruchomienie bota (Replit)

```bash
cd SerwerIBot
pip install -r requirements.txt
python main.py
```

Panel administracyjny dostępny na porcie `5000`.

### Komendy bota Discord

| Komenda | Opis |
|---------|------|
| `.generate` | Generuje nowy klucz licencyjny |
| `.ban KLUCZ` | Blokuje klucz |
| `.unban KLUCZ` | Odblokowuje klucz |
| `.reset KLUCZ` | Resetuje HWID klucza |
| `.assign KLUCZ HWID` | Ręcznie przypisuje HWID |
| `.info KLUCZ` | Wyświetla informacje o kluczu |
| `.list` | Lista wszystkich kluczy |
| `.note KLUCZ tekst` | Dodaje notatkę (np. nick gracza) |
| `.clearnote KLUCZ` | Usuwa notatkę |
| `.debugcode KLUCZ` | Pokazuje kod PIN debugowania |
| `.delete KLUCZ` | Usuwa klucz |

### Tworzenie nowego Release (exe)

Release tworzony jest automatycznie przez GitHub Actions przy każdym nowym tagu:

```bash
git tag v1.4.2
git push origin v1.4.2
```

Możesz też uruchomić release ręcznie z GitHub UI:
**Actions → Build & Release → Run workflow** → podaj wersję

GitHub Actions automatycznie:
1. Kompiluje `SlapBattlesMultiMacro.ahk` → `SlapBattlesMultiMacro.exe`
2. Tworzy Release z tym plikiem

---

## Struktura repo

```
/
├── SlapBattlesMultiMacro.ahk   ← główny plik makra (AutoHotkey v2)
├── .gitignore
├── README.md
├── docs/
│   ├── ToS-Makro.md            ← Warunki Użytkowania — Makro
│   ├── ToS-Bot.md              ← Warunki Użytkowania — Bot Discord
│   ├── PrivacyPolicy-Makro.md  ← Polityka Prywatności — Makro
│   └── PrivacyPolicy-Bot.md    ← Polityka Prywatności — Bot Discord
├── .github/
│   └── workflows/
│       └── release.yml         ← auto-kompilacja i release
└── SerwerIBot/
    ├── main.py                 ← bot Discord + panel web
    ├── panel.html              ← panel administracyjny
    ├── requirements.txt
    └── .env.example            ← przykład zmiennych środowiskowych
```

> `licenses.json` **NIE jest w repo** — przechowywany w prywatnym GitHub Gist.
