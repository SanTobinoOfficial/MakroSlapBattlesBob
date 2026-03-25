# Polityka Prywatności — Makro

**Slap Battles Multi Macro** (`SlapBattlesMultiMacro.ahk`)
Ostatnia aktualizacja: 25 marca 2026 r.

---

## 1. Jakie dane zbiera Makro?

### 1.1 Dane wysyłane jednorazowo (aktywacja)

| Dane | Cel | Gdzie wysyłane |
|------|-----|----------------|
| **HWID** (Hardware ID) | Powiązanie klucza z urządzeniem | Webhook Discord Administratora |
| **Klucz licencyjny** | Weryfikacja aktywacji | Webhook Discord Administratora |
| **Kod debug** | Diagnostyka problemów z licencją | Webhook Discord Administratora |

HWID wysyłany jest **jednorazowo** — tylko przy pierwszej aktywacji. Przy kolejnych uruchomieniach Makro jedynie odczytuje dane z GitHub Gist.

### 1.2 Dane użytkowania (telemetria)

Po zakończeniu każdej sesji (zatrzymanie makra lub zamknięcie programu) Makro automatycznie wysyła anonimowe dane użytkowania do panelu Administratora:

| Dane | Cel |
|------|-----|
| **Klucz licencyjny** | Identyfikacja sesji |
| **HWID** | Identyfikacja urządzenia |
| **Wersja Makra** | Monitorowanie wersji wśród użytkowników |
| **Aktywny moduł** | Statystyki popularności modułów |
| **Czas trwania sesji** (sekundy) | Analiza wzorców użytkowania |
| **Liczba wykonanych akcji** | Statystyki wydajności makra |
| **Wersja systemu Windows** | Diagnostyka kompatybilności |

Dane te są wysyłane **wyłącznie wtedy, gdy URL panelu jest skonfigurowany** przez Administratora w ustawieniach debugowania Makra. Dane nie są wysyłane, jeśli URL nie został ustawiony.

### 1.3 Dane diagnostyczne (na żądanie)

Wysyłane wyłącznie ręcznie przez Użytkownika (przycisk „Wyślij diagnostykę" lub opcja z menu tray). Zawierają: klucz, HWID, wersję, moduł, kod debug, wersję systemu oraz opis błędu podany przez Użytkownika.

### 1.4 Dane przechowywane wyłącznie lokalnie

| Plik | Lokalizacja | Zawartość |
|------|-------------|-----------|
| `portal_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu BOB Portal |
| `trap_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Trap |
| `obby_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Obby |
| `replica_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Replica Bob |
| `manualbob_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Manual Bob |
| `critglove_config.ini` | `%AppData%\SBMM\` | Ustawienia modułu Critical Glove |
| `global_config.ini` | `%AppData%\SBMM\` | Globalny URL panelu |
| `tos_accepted.dat` | `%AppData%\SBMM\` | Flaga akceptacji Warunków |
| `license.dat` | `%AppData%\SBMM\` | Klucz licencyjny |
| `debug_code.dat` | `%AppData%\SBMM\` | Kod debug dla wsparcia |
| `sent_info.dat` | `%AppData%\SBMM\` | Flaga wysłania HWID |

**Żaden z tych plików nie jest wysyłany na zewnątrz.**

---

## 2. Jak pobierany jest HWID?

HWID pobierany jest z rejestru Windows: `HKLM\SOFTWARE\Microsoft\Cryptography\MachineGuid`. Jest to unikalny identyfikator przypisywany komputerowi podczas instalacji systemu Windows, niezwiązany z kontem użytkownika ani z kontem Roblox.

---

## 3. Procesory danych zewnętrznych

| Usługa | Rola | Polityka prywatności |
|--------|------|---------------------|
| **Discord** | Odbiór webhooka z HWID przy aktywacji | [discord.com/privacy](https://discord.com/privacy) |
| **GitHub Gist** | Przechowywanie bazy kluczy (tylko odczyt przez Makro) | [docs.github.com/privacy](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement) |
| **Panel Administratora** (Replit) | Odbiór danych użytkowania i diagnostycznych | [replit.com/privacy](https://replit.com/site/privacy) |

---

## 4. Jak długo przechowywane są dane?

| Dane | Okres |
|------|-------|
| Dane użytkowania na panelu | Sesyjnie — kasowane po restarcie bota, maks. 1000 wpisów |
| Pliki konfiguracyjne lokalne | Do ręcznego usunięcia przez Użytkownika |
| HWID w bazie Administratora | Do usunięcia klucza przez Administratora |
| Wiadomość webhook na Discord | Zgodnie z polityką Discord |

---

## 5. Prawa Użytkownika

- **Dostęp:** Możesz zapytać Administratora, jakie dane są przechowywane dla Twojego klucza.
- **Usunięcie:** Możesz zażądać usunięcia swojego klucza i danych z bazy (skutkuje utratą dostępu do Makra).
- **Reset HWID:** Możesz poprosić Administratora o reset HWID w celu przeniesienia licencji.
- **Dane lokalne:** Możesz usunąć folder `%AppData%\SBMM\` w dowolnym momencie.
- **Opt-out z telemetrii:** Możesz wyłączyć wysyłanie danych użytkowania, usuwając URL panelu z ustawień debugowania (pozostaw pole puste i zapisz).

---

## 6. Kontakt

Skontaktuj się z Administratorem przez serwer Discord projektu BOB.

---

> Warunki Korzystania z Makra: [ToS-Makro.md](./ToS-Makro.md)
> Polityka prywatności Bota: [PrivacyPolicy-Bot.md](./PrivacyPolicy-Bot.md)
