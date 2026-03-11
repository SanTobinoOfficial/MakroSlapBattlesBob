# Polityka Prywatności — Bot Discord

**Bot Administracyjny BOB** (SerwerIBot)
Ostatnia aktualizacja: 11 marca 2026 r.

---

## 1. Jakie dane przechowuje Bot?

### Dane w bazie licencji (`licenses.json`)

| Dane | Opis | Cel |
|------|------|-----|
| **Klucz licencyjny** | `XXXX-XXXX-XXXX-XXXX` | Identyfikacja licencji |
| **HWID** | Identyfikator sprzętowy urządzenia Użytkownika | Weryfikacja jednego urządzenia na klucz |
| **Status** | `banned: true/false` | Kontrola dostępu |
| **Notatka** | Opcjonalny opis (np. nick gracza) | Identyfikacja Użytkownika przez Administratora |
| **Kod debug** | Tymczasowy kod PIN | Diagnostyka problemów z licencją |

### Dane przetwarzane przez Bota (niezapisywane)

| Dane | Cel |
|------|-----|
| ID kanału Discord | Konfiguracja kanału administracyjnego |
| Treść wiadomości od webhooków Makra | Automatyczne przypisanie HWID do klucza |
| Logi aktywności administracyjnej | Audyt działań (sesyjne — kasowane po restarcie) |

---

## 2. Gdzie przechowywane są dane?

2.1. Baza kluczy (`licenses.json`) przechowywana jest w **prywatnym GitHub Gist**, dostępnym wyłącznie za pomocą tokenu z ograniczonym zakresem uprawnień (`gist` scope).

2.2. Podczas działania Bota dane są załadowane do pamięci RAM serwera Replit i zapisane lokalnie jako `licenses.json`.

2.3. Tokeny dostępowe (`DISCORD_TOKEN`, `GIST_TOKEN`) przechowywane są jako zaszyfrowane zmienne środowiskowe w Replit Secrets — **nigdy w kodzie ani w repozytorium**.

---

## 3. Procesory danych zewnętrznych

| Usługa | Rola | Polityka prywatności |
|--------|------|---------------------|
| **Discord** | Platforma Bota (komendy, odbiór webhooków, tworzenie kanałów) | [discord.com/privacy](https://discord.com/privacy) |
| **GitHub Gist** | Przechowywanie bazy `licenses.json` | [docs.github.com/privacy](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement) |
| **Replit** | Hosting Bota i tymczasowe przechowywanie pliku | [replit.com/privacy](https://replit.com/site/privacy) |

---

## 4. Jak długo przechowywane są dane?

| Dane | Okres |
|------|-------|
| Klucze z HWID w Gist | Do ręcznego usunięcia klucza przez Administratora |
| Logi aktywności Bota | Sesyjnie — kasowane po restarcie Bota |
| Dane w pamięci RAM Replit | Do restartu Bota |

---

## 5. Prawa Użytkownika Makra

Użytkownik Makra (którego klucz jest w bazie) ma prawo do:

- **Dostępu:** Uzyskania informacji, jakie dane są przechowywane dla jego klucza — poprzez kontakt z Administratorem.
- **Korekty:** Skorygowania błędnych danych (np. notatki).
- **Usunięcia:** Żądania usunięcia klucza i HWID z bazy (skutkuje utratą dostępu do Makra).
- **Resetu HWID:** Przeniesienia licencji na nowe urządzenie.

Aby skorzystać z powyższych praw, skontaktuj się z Administratorem przez serwer Discord projektu BOB.

---

## 6. Bezpieczeństwo

- Baza kluczy przechowywana jest w **prywatnym** Gist — nie jest publicznie widoczna.
- Token GitHub Gist posiada wyłącznie zakres `gist` — nie ma dostępu do kodu ani innych repozytoriów.
- Administrator stosuje zasadę minimalnych uprawnień — dostęp do komend Bota posiadają wyłącznie upoważnione osoby.

---

## 7. Zmiany Polityki

O istotnych zmianach Administrator poinformuje na serwerze Discord projektu BOB. Dalsze korzystanie z Bota po opublikowaniu zmian oznacza ich akceptację.

---

## 8. Kontakt

W przypadku pytań dotyczących przetwarzania danych skontaktuj się przez serwer Discord projektu BOB.

---

> Warunki Korzystania z Bota: [ToS-Bot.md](./ToS-Bot.md)
> Polityka prywatności Makra: [PrivacyPolicy-Makro.md](./PrivacyPolicy-Makro.md)
