# Polityka Prywatności — Makro

**Slap Battles Multi Macro** (`SlapBattlesMultiMacro.exe`)
Ostatnia aktualizacja: 11 marca 2026 r.

---

## 1. Jakie dane zbiera Makro?

### Dane wysyłane na zewnątrz (jednorazowo)

| Dane | Cel | Gdzie wysyłane |
|------|-----|----------------|
| **HWID** (Hardware ID) | Powiązanie klucza licencyjnego z urządzeniem | Webhook Discord Administratora |
| **Klucz licencyjny** | Weryfikacja aktywacji | Webhook Discord Administratora |
| **Kod debug** | Diagnostyka problemów z licencją | Webhook Discord Administratora |

HWID jest wysyłany **jednorazowo** — tylko przy pierwszej aktywacji, gdy klucz nie ma jeszcze przypisanego urządzenia. Przy kolejnych uruchomieniach Makro jedynie odczytuje dane z GitHub Gist w celu weryfikacji klucza — nie wysyła dalszych informacji.

### Dane przechowywane wyłącznie lokalnie

| Plik | Lokalizacja | Zawartość |
|------|-------------|-----------|
| `portal_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu BOB |
| `trap_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Trap |
| `obby_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Obby |
| `replica_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Replica Bob |
| `manualbob_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Manual Bob |
| `critglove_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Critical Glove |
| `tos_accepted.dat` | `%AppData%\SBMM\` | Flaga akceptacji Warunków |
| `license.dat` | `%AppData%\SBMM\` | Zapisany klucz licencyjny |
| `debug_code.dat` | `%AppData%\SBMM\` | Kod debug dla wsparcia |
| `sent_info.dat` | `%AppData%\SBMM\` | Flaga wysłania HWID (jednorazowa) |

**Żaden z tych plików nie jest wysyłany na zewnątrz.**

---

## 2. Jak pobierany jest HWID?

HWID pobierany jest z systemu Windows za pomocą zapytania WMI (`Win32_ComputerSystemProduct.UUID`). Jest to unikalny identyfikator sprzętowy komputera, niezwiązany z kontem użytkownika Windows ani z kontem Roblox.

---

## 3. Procesory danych zewnętrznych

| Usługa | Rola | Polityka prywatności |
|--------|------|---------------------|
| **Discord** | Odbiór webhooka z HWID przy aktywacji | [discord.com/privacy](https://discord.com/privacy) |
| **GitHub Gist** | Przechowywanie bazy kluczy (tylko odczyt przez Makro) | [docs.github.com/privacy](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement) |

Makro **wyłącznie odczytuje** plik `licenses.json` z GitHub Gist — nie ma uprawnień do jego modyfikacji.

---

## 4. Jak długo przechowywane są dane?

| Dane | Okres |
|------|-------|
| Pliki konfiguracyjne lokalne | Do ręcznego usunięcia przez Użytkownika |
| HWID w bazie Administratora | Do usunięcia klucza przez Administratora |
| Wiadomość webhook na Discord | Zgodnie z polityką Discord |

---

## 5. Prawa Użytkownika

- **Dostęp:** Możesz zapytać Administratora, jakie dane są przechowywane dla Twojego klucza.
- **Usunięcie:** Możesz zażądać usunięcia swojego klucza i HWID z bazy (skutkuje utratą dostępu do Makra).
- **Reset HWID:** Możesz poprosić Administratora o reset HWID, aby przenieść licencję na nowe urządzenie.
- **Dane lokalne:** Możesz usunąć folder `%AppData%\SBMM\` w dowolnym momencie.

---

## 6. Kontakt

Skontaktuj się z Administratorem przez serwer Discord projektu BOB.

---

> Warunki Korzystania z Makra: [ToS-Makro.md](./ToS-Makro.md)
> Polityka prywatności Bota: [PrivacyPolicy-Bot.md](./PrivacyPolicy-Bot.md)
