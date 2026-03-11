# Warunki Korzystania z Bota Discord

**Bot Administracyjny BOB** (SerwerIBot)
Ostatnia aktualizacja: 11 marca 2026 r.

---

## 1. Definicje

| Pojęcie | Znaczenie |
|---------|-----------|
| **Bot** | Discord bot administracyjny zarządzający licencjami Makra |
| **Administrator** | Właściciel projektu BOB lub upoważniona przez niego osoba z dostępem do komend Bota |
| **Klucz licencyjny** | Unikalny ciąg w formacie `XXXX-XXXX-XXXX-XXXX` |
| **HWID** | Identyfikator sprzętowy komputera przypisany do klucza |

---

## 2. Przeznaczenie Bota

2.1. Bot jest **narzędziem wyłącznie administracyjnym** — nie jest przeznaczony do użytku publicznego.

2.2. Dostęp do komend Bota posiadają wyłącznie osoby upoważnione przez Administratora projektu.

---

## 3. Zasady Użytkowania przez Administratorów

3.1. Osoby posiadające dostęp do Bota zobowiązują się do:
- nieudostępniania komend administracyjnych osobom nieuprawnionym,
- zachowania poufności informacji o kluczach i HWID Użytkowników Makra,
- korzystania z komend wyłącznie zgodnie z ich przeznaczeniem.

3.2. **Zakazane jest:**
- generowanie kluczy w celu odsprzedaży bez zgody właściciela projektu,
- manipulowanie bazą `licenses.json` z pominięciem Bota,
- próby uzyskania nieautoryzowanego dostępu do panelu administracyjnego (port 5000).

---

## 4. Komendy Administracyjne

| Komenda | Opis |
|---------|------|
| `.generate` | Generuje nowy klucz licencyjny |
| `.ban KLUCZ` | Blokuje klucz |
| `.unban KLUCZ` | Odblokowuje klucz |
| `.reset KLUCZ` | Resetuje przypisany HWID (pozwala na zmianę urządzenia) |
| `.assign KLUCZ HWID` | Ręcznie przypisuje HWID do klucza |
| `.info KLUCZ` | Wyświetla szczegóły klucza |
| `.list` | Lista wszystkich kluczy |
| `.note KLUCZ tekst` | Dodaje notatkę do klucza |
| `.clearnote KLUCZ` | Usuwa notatkę |
| `.debugcode KLUCZ` | Pokazuje kod PIN debugowania |
| `.delete KLUCZ` | Trwale usuwa klucz z bazy |

---

## 5. Bezpieczeństwo i Poufność

5.1. Token Bota (`DISCORD_TOKEN`), token GitHub (`GIST_TOKEN`) i identyfikator Gista (`GIST_ID`) muszą być przechowywane wyłącznie jako zmienne środowiskowe (Replit Secrets) — **nigdy w kodzie ani w repozytorium**.

5.2. Panel administracyjny (port 5000) powinien być dostępny wyłącznie dla uprawnionych osób. Nie należy publicznie udostępniać adresu URL panelu.

---

## 6. Odpowiedzialność

6.1. Administrator projektu nie ponosi odpowiedzialności za działania osób, którym udzielono dostępu do Bota, jeśli nadużyją one przyznanych uprawnień.

6.2. Bot dostarczany jest **„tak jak jest"** — bez gwarancji ciągłości działania.

---

## 7. Postanowienia Końcowe

Niniejsze Warunki podlegają prawu Rzeczypospolitej Polskiej. W razie pytań skontaktuj się z właścicielem projektu przez serwer Discord projektu BOB.

---

> Polityka prywatności Bota: [PrivacyPolicy-Bot.md](./PrivacyPolicy-Bot.md)
> Warunki dla Makra: [ToS-Makro.md](./ToS-Makro.md)
