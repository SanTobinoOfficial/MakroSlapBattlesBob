# Bob Makro v1.3 — Dokumentacja developerska

## Architektura ogólna

Plik: `SlapBattlesMultiMacro.ahk` (~3300 linii), AutoHotkey v2.0

Makro działa jako **single-threaded event loop** AHK z timerami i hotkeys.
Jeden plik, jedno okno GUI naraz, jeden aktywny moduł (`activeModule`).

```
Startup
  └─ Weryfikacja licencji (HTTP GET → GitHub JSON)
  └─ LoadXxxINI() × 6
  └─ InitDebugCode()
  └─ sentInfoFile check → SendWebhookHWID() (tylko raz)
  └─ ShowMenu()
       └─ SelectXxx() → BuildXxxGUI()
            └─ StartMacro() → SetTimer / Hotkey
                 └─ XxxLoop() / XxxTrigger() — właściwa logika
```

---

## Zmienne globalne — współdzielone

| Zmienna | Typ | Opis |
|---------|-----|------|
| `APP_NAME` | String | Nazwa aplikacji: `"Bob Makro"` |
| `APP_VERSION` | String | Wersja: `"v1.3"` |
| `activeModule` | String | Aktualnie wybrany moduł: `"portal"` / `"trap"` / `"obby"` / `"replica"` / `"manualbob"` / `"critglove"` |
| `running` | Boolean | Czy makro jest uruchomione |
| `paused` | Boolean | Czy makro jest zapauzowane (gra nieaktywna) |
| `sessionStart` | Integer | `A_TickCount` momentu startu — do liczenia czasu sesji |
| `key` | String | Klucz licencyjny wczytany z `license.dat` |
| `hwid` | String | HWID urządzenia (z rejestru Windows, MachineGuid) |
| `licenseFile` | String | Ścieżka do `%AppData%\SBMM\license.dat` |
| `jsonURL` | String | URL do pliku `licenses.json` na GitHub |
| `webhookHWID` | String | URL webhooka Discord do rejestracji HWID |
| `debugCode` | String | 8-znakowy kod PIN (format `XXXX-XXXX`) do sekcji debugowania |
| `debugCodeFile` | String | Ścieżka do `%AppData%\SBMM\debug_code.dat` |
| `sentInfoFile` | String | Ścieżka do `%AppData%\SBMM\sent_info.dat` — flaga jednorazowego wysłania HWID |
| `gui1` | Gui | Aktualnie widoczne okno modułu |
| `statusText` | GuiCtrl | Kontrolka statusu (DZIAŁA/ZATRZYMANE/PAUZA) |
| `gameText` | GuiCtrl | Kontrolka stanu gry (✓/✗) |

---

## Zmienne globalne — moduł Portal (prefix `P_`)

| Zmienna | Domyślna | Opis |
|---------|----------|------|
| `P_IniFile` | `%AppData%\SBMM\portal_config.ini` | Plik konfiguracji |
| `P_HistFile` | `%AppData%\SBMM\portal_historia.txt` | Log historii sesji |
| `P_TotalFile` | `%AppData%\SBMM\portal_total.dat` | Plik z łączną liczbą pętli |
| `P_webhook` | `""` | URL webhooka statystyk |
| `P_whCooldown` | `3000` | Minimalny czas (ms) między wysłaniami webhooka |
| `P_lastWH` | `0` | `A_TickCount` ostatniego wysłania webhooka |
| `P_loopCount` | `0` | Liczba pętli w bieżącej sesji |
| `P_bobHits` | `0` | Liczba znalezionych Bobów (losowe, symulowane) |
| `P_totalLoops` | `0` | Łączna liczba pętli (wczytywana z `P_TotalFile`) |
| `P_BOB_DENOM` | `7500` | Mianownik szansy na Boba: 1/P_BOB_DENOM |
| `portalX`, `portalY` | `956`, `982` | Współrzędne ekranowe portalu (piksele) |

### INI — Portal (`portal_config.ini`)

| Sekcja | Klucz | Domyślna | Opis |
|--------|-------|----------|------|
| Makro | CzasRuchu | 3000 | Czas ruchu do portalu (ms) |
| Makro | CzasStrafe | 1500 | Czas ruchu bocznego (ms) |
| Makro | OffsetMax | 10 | Maksymalny losowy offset pikseli |
| Makro | InterwalStatystyk | 100 | Co ile pętli wysyłać webhook |
| Makro | AutoPauza | 1 | Auto-pauza gdy gra nieaktywna |
| Makro | DzwiekBob | 1 | Dźwięk przy znalezieniu Boba |
| Zaawansowane | ClickSleep | 80 | Sleep po kliknięciu portalu (ms) |
| Zaawansowane | PostClickSleep | 500 | Sleep po zamknięciu okna portalu (ms) |
| Zaawansowane | CloseX_X / CloseX_Y | 1395 / 242 | Współrzędne przycisku X zamknięcia |
| Zaawansowane | CloseXSleepA / B | 50 / 200 | Sleep przed/po kliknięciu X |
| Zaawansowane | GridOffset | 6 | Offset siatki wyszukiwania pikseli |
| Zaawansowane | BlueBaseX/Y | 687 / 588 | Współrzędne środka niebieskiej bazy |
| Zaawansowane | RedBaseX/Y | 1247 / 646 | Współrzędne środka czerwonej bazy |
| Zaawansowane | PortalX/Y | 956 / 982 | Współrzędne portalu |
| Zaawansowane | PreMoveSleep | 0 | Sleep przed ruchem (ms) |
| Zaawansowane | PostMoveSleep | 150 | Sleep po ruchu (ms) |
| Zaawansowane | InteractSleep | 150 | Sleep po kliknięciu interakcji |
| Zaawansowane | InteractSleep2 | 100 | Drugi sleep interakcji |
| Zaawansowane | EscSleep | 100 | Sleep po Esc |
| Zaawansowane | RSleep | 100 | Sleep po R |
| Zaawansowane | EnterSleep | 5000 | Sleep po Enter (czas ładowania mapy) |
| GoToPortal | WTime | 0 | Czas ruchu W (do portalu) |
| GoToPortal | DTime | 0 | Czas ruchu D |
| GoToPortal | ATime | 0 | Czas ruchu A |
| GoToPortal | Sleep | 0 | Sleep po dojściu do portalu |
| Debug | ScanHits | 3 | Minimalna liczba trafień koloru do potwierdzenia bazy |
| Debug | BlueB_min | 200 | Min wartość kanału B dla niebieskiej bazy |
| Debug | BlueRG_max | 50 | Max wartość R i G dla niebieskiej bazy |
| Debug | RedR_min | 200 | Min wartość kanału R dla czerwonej bazy |
| Debug | RedBG_max | 50 | Max wartość B i G dla czerwonej bazy |
| Debug | BobDenom | 7500 | Mianownik szansy na Boba |
| Webhook | URL | "" | URL webhooka |
| Webhook | Cooldown | 3000 | Cooldown webhooka (ms) |

---

## Zmienne globalne — moduł Trap (prefix `T_`)

| Zmienna | Domyślna | Opis |
|---------|----------|------|
| `T_IniFile` | `%AppData%\SBMM\trap_config.ini` | Plik konfiguracji |
| `T_HistFile` | `%AppData%\SBMM\trap_historia.txt` | Log historii |
| `T_TotalFile` | `%AppData%\SBMM\trap_total.dat` | Łączna liczba cegieł |
| `T_webhook` | `""` | URL webhooka |
| `T_whCooldown` | `5000` | Cooldown webhooka (ms) |
| `T_lastWH` | `0` | Timestamp ostatniego webhooka |
| `T_brickCount` | `0` | Cegły w bieżącej sesji |
| `T_totalBricks` | `0` | Cegły łącznie |
| `T_BRICK_GOAL` | `1000` | Cel cegieł (wczytywany z INI) |
| `T_BRICK_CD` | `5000` | Cooldown kliknięcia (ms) — częstotliwość timera |

### INI — Trap (`trap_config.ini`)

| Sekcja | Klucz | Domyślna | Opis |
|--------|-------|----------|------|
| Makro | AutoPauza | 1 | Auto-pauza |
| Makro | DzwiekCel | 1 | Dźwięk po osiągnięciu celu |
| Makro | InterwalStatystyk | 50 | Co ile cegieł wysyłać webhook |
| Zaawansowane | ClickSleep | 100 | Sleep po kliknięciu (ms) |
| Zaawansowane | BrickCD | 5000 | Cooldown między kliknięciami (ms) |
| Zaawansowane | BrickGoal | 1000 | Cel liczby cegieł |
| Zaawansowane | GoalSoundDelay | 300 | Sleep między piknięciami dźwięku celu |
| Webhook | URL | "" | URL webhooka |
| Webhook | Cooldown | 5000 | Cooldown webhooka (ms) |

---

## Zmienne globalne — moduł Obby (prefix `O_`)

| Zmienna | Domyślna | Opis |
|---------|----------|------|
| `O_IniFile` | `%AppData%\SBMM\obby_config.ini` | Plik konfiguracji |
| `O_HistFile` | `%AppData%\SBMM\obby_historia.txt` | Log historii |
| `O_TotalFile` | `%AppData%\SBMM\obby_total.dat` | Łączna liczba części |
| `O_webhook` | `""` | URL webhooka |
| `O_whCooldown` | `5000` | Cooldown webhooka (ms) |
| `O_lastWH` | `0` | Timestamp ostatniego webhooka |
| `O_partCount` | `0` | Części w bieżącej sesji |
| `O_totalParts` | `0` | Części łącznie |
| `O_PART_GOAL` | `2000` | Cel części (Quest 3 Mastery) |
| `O_PART_CD` | `3000` | Cooldown między kliknięciami (ms) |

### INI — Obby (`obby_config.ini`)

| Sekcja | Klucz | Domyślna | Opis |
|--------|-------|----------|------|
| Makro | AutoPauza | 1 | Auto-pauza |
| Makro | DzwiekCel | 1 | Dźwięk po osiągnięciu celu |
| Makro | InterwalStatystyk | 100 | Co ile części wysyłać webhook |
| Makro | DoubleTapDelay | 500 | Delay między dwukrotnym naciśnięciem E |
| Zaawansowane | PostESleep | 100 | Sleep po naciśnięciu E (ms) |
| Zaawansowane | PartCD | 3000 | Cooldown między częściami (ms) |
| Zaawansowane | PartGoal | 2000 | Cel liczby części |
| Zaawansowane | GoalSoundDelay | 300 | Sleep między piknięciami celu |
| Webhook | URL | "" | URL webhooka |
| Webhook | Cooldown | 5000 | Cooldown webhooka (ms) |

---

## Zmienne globalne — moduł Replica Bob (prefix `R_`)

| Zmienna | Domyślna | Opis |
|---------|----------|------|
| `R_IniFile` | `%AppData%\SBMM\replica_config.ini` | Plik konfiguracji |
| `R_HistFile` | `%AppData%\SBMM\replica_historia.txt` | Log historii |
| `R_TotalFile` | `%AppData%\SBMM\replica_total.dat` | Łączna liczba kliknięć |
| `R_webhook` | `""` | URL webhooka |
| `R_whCooldown` | `10000` | Cooldown webhooka (ms) |
| `R_lastWH` | `0` | Timestamp ostatniego webhooka |
| `R_clickCount` | `0` | Kliki w bieżącej sesji |
| `R_totalClicks` | `0` | Kliki łącznie |
| `R_BOB_DENOM` | `7500` | Mianownik szansy na Boba |
| `R_CD` | `14000` | Cooldown repliki Boba (ms) — częstotliwość timera |
| `R_bobHits` | `0` | Znalezione Boby |
| `R_lastTick` | `0` | Timestamp ostatniego ticku timera (do obliczania driftu) |
| `R_loopTimer` | `0` | Akumulowany czas pętli |

### INI — Replica (`replica_config.ini`)

| Sekcja | Klucz | Domyślna | Opis |
|--------|-------|----------|------|
| Makro | AutoPauza | 1 | Auto-pauza |
| Makro | DzwiekBob | 1 | Dźwięk przy znalezieniu Boba |
| Makro | InterwalStatystyk | 100 | Co ile kliknięć wysyłać webhook |
| Zaawansowane | CD | 14000 | Cooldown kliknięcia (ms) |
| Debug | BobDenom | 7500 | Mianownik szansy na Boba |
| Webhook | URL | "" | URL webhooka |
| Webhook | Cooldown | 10000 | Cooldown webhooka (ms) |

---

## Zmienne globalne — moduł Manual Bob (prefix `MB_`)

| Zmienna | Domyślna | Opis |
|---------|----------|------|
| `MB_IniFile` | `%AppData%\SBMM\manualbob_config.ini` | Plik konfiguracji |
| `MB_HistFile` | `%AppData%\SBMM\manualbob_historia.txt` | Log historii |
| `MB_TotalFile` | `%AppData%\SBMM\manualbob_total.dat` | Łączna liczba kliknięć |
| `MB_webhook` | `""` | URL webhooka |
| `MB_whCooldown` | `5000` | Cooldown webhooka (ms) |
| `MB_lastWH` | `0` | Timestamp ostatniego webhooka |
| `MB_clickCount` | `0` | Kliki w bieżącej sesji |
| `MB_totalClicks` | `0` | Kliki łącznie |
| `MB_BOB_DENOM` | `7500` | Mianownik szansy na Boba |
| `MB_bobHits` | `0` | Znalezione Boby |
| `MB_hotkey` | `"e"` | Aktualnie przypisany klawisz wyzwalacza (wczytywany z INI) |

### INI — Manual Bob (`manualbob_config.ini`)

| Sekcja | Klucz | Domyślna | Opis |
|--------|-------|----------|------|
| Makro | AutoPauza | 1 | Auto-pauza |
| Makro | DzwiekBob | 1 | Dźwięk przy znalezieniu Boba |
| Makro | InterwalStatystyk | 100 | Co ile kliknięć wysyłać webhook |
| Zaawansowane | Hotkey | `e` | Klawisz wyzwalacza sekwencji |
| Zaawansowane | PreEscSleep | 0 | Sleep przed Esc (ms) |
| Zaawansowane | EscSleep | 100 | Sleep po Esc (ms) |
| Zaawansowane | RSleep | 100 | Sleep po R (ms) |
| Zaawansowane | EnterSleep | 100 | Sleep po Enter (ms) |
| Debug | BobDenom | 7500 | Mianownik szansy na Boba |
| Webhook | URL | "" | URL webhooka |
| Webhook | Cooldown | 5000 | Cooldown webhooka (ms) |

---

## Zmienne globalne — moduł Critical Glove (prefix `CG_`)

| Zmienna | Domyślna | Opis |
|---------|----------|------|
| `CG_IniFile` | `%AppData%\SBMM\critglove_config.ini` | Plik konfiguracji |
| `CG_HistFile` | `%AppData%\SBMM\critglove_historia.txt` | Log historii |
| `CG_TotalFile` | `%AppData%\SBMM\critglove_total.dat` | Łączna liczba kliknięć |
| `CG_webhook` | `""` | URL webhooka |
| `CG_whCooldown` | `5000` | Cooldown webhooka (ms) |
| `CG_lastWH` | `0` | Timestamp ostatniego webhooka |
| `CG_clickCount` | `0` | Kliki w bieżącej sesji |
| `CG_totalClicks` | `0` | Kliki łącznie |
| `CG_hotkey` | `"RButton"` | Aktualnie przypisany klawisz wyzwalacza |

### INI — Critical Glove (`critglove_config.ini`)

| Sekcja | Klucz | Domyślna | Opis |
|--------|-------|----------|------|
| Makro | AutoPauza | 1 | Auto-pauza |
| Makro | InterwalStatystyk | 100 | Co ile kliknięć wysyłać webhook |
| Zaawansowane | Hotkey | `RButton` | Klawisz wyzwalacza combo |
| Zaawansowane | SpaceSleep | 50 | Sleep między Space a LButton (ms) |
| Zaawansowane | ClickSleep | 30 | Sleep po LButton (ms) |
| Webhook | URL | "" | URL webhooka |
| Webhook | Cooldown | 5000 | Cooldown webhooka (ms) |

---

## Zmienne globalne — WKP (Key Picker, prefix `WKP_`)

Używane przez system przechwytywania klawisza w ustawieniach.

| Zmienna | Opis |
|---------|------|
| `WKP_ih` | Aktywny obiekt `InputHook` — `""` gdy nieaktywny |
| `WKP_targetEdit` | Referencja do kontrolki `Edit` która przyjmie wynik |
| `WKP_gui` | Okno dialogowe "Naciśnij klawisz" |

---

## Funkcje pomocnicze

### `SafeNum(val, def)`
Konwertuje `val` na liczbę. Jeśli konwersja się nie uda (pusty string, tekst),
zwraca `def`. Zapobiega błędom przy odczycie INI.

### `FormatTime2(ms)`
Konwertuje milisekundy na string `HH:MM:SS`. Używane do wyświetlania czasu sesji.

### `FormatLoops(n)`
Formatuje liczbę z separatorem tysięcy (np. `12345` → `"12 345"`).

### `PostWebhook(url, msg)`
Wysyła wiadomość na webhook Discord przez `WinHttp.WinHttpRequest.5.1`.
Asynchroniczne — nie blokuje wątku. Jeśli `url` jest pusty, nie robi nic.

### `SendWebhookHWID(msg)`
Wysyła wiadomość na `webhookHWID` (webhook rejestracji HWID).
Używana tylko przy pierwszej aktywacji.

### `CheckLicenseFull(k, &aHWID)`
Pobiera `licenses.json` z GitHub, parsuje JSON, zwraca status:
`"ok"` / `"invalid"` / `"banned"` / `"hwid_mismatch"` / `"network_error"`.
Przez referencję `&aHWID` zwraca aktualny HWID przypisany do klucza.

### `GenerateDebugCode()`
Generuje losowy 8-znakowy kod w formacie `XXXX-XXXX` z zestawu `ABCDEFGHJKLMNPQRSTUVWXYZ23456789` (bez mylących znaków O/0/1/I).

### `InitDebugCode()`
Wczytuje `debugCode` z `debugCodeFile`. Jeśli plik nie istnieje, generuje nowy kod i zapisuje.

---

## Przepływ startu makra

### `StartMacro(*)`
1. Ustawia `running := true`, `paused := false`, `sessionStart := A_TickCount`
2. Zeruje liczniki sesji dla aktywnego modułu
3. Dla modułów timer-based (`portal`, `trap`, `obby`, `replica`): `SetTimer(XxxLoop, cd)`
4. Dla modułów hotkey-based (`manualbob`, `critglove`): `Hotkey MB_hotkey/CG_hotkey, XxxTrigger, "On"` + odczyt hotkey z INI
5. `SetTimer(UpdateTimer, 1000)` + `SetTimer(CheckGame, 2000)`
6. Aktualizuje status i tray tip

### `StopMacro(*)`
1. Ustawia `running := false`
2. Wyłącza wszystkie timery: `SetTimer(XxxLoop, 0)` × 4
3. Wyłącza hotkeys: `try Hotkey MB_hotkey, ..., "Off"` + `try Hotkey CG_hotkey, ..., "Off"`
4. Zapisuje historię sesji (`SaveHistory`) i dane łączne (`SaveTotalData`)

### `CheckGame()`
Wywoływana co 2 sekundy przez timer.
- Sprawdza czy `test.exe` jest aktywny (`WinExist`)
- Aktualizuje `gameText` (zielony/czerwony)
- Jeśli `AutoPauza=1`:
  - Gra zniknęła → `paused := true`, zatrzymuje timery/hotkeys
  - Gra wróciła → `paused := false`, wznawia timery/hotkeys

### `UpdateTimer()`
Wywoływana co 1 sekundę. Oblicza `elapsed = A_TickCount - sessionStart` i wywołuje `UpdateXxxStats(elapsed)` dla aktywnego modułu.

---

## Logika pętli modułów

### `PortalLoop()`
1. Odczytuje wszystkie parametry z INI (live — zmiany działają bez restartu)
2. Skanuje piksele w siatce wokół `BlueBaseX/Y` i `RedBaseX/Y` sprawdzając progi kolorów
3. Porusza postacią do odpowiedniej bazy (WASD + Sleep)
4. Klika portal w `(portalX, portalY)`
5. Zamyka okno portalu kliknięciem X
6. Wykonuje sekwencję Esc → R → Enter (respawn)
7. Losuje szansę na Boba (`Random(1, P_BOB_DENOM) = 1`)
8. Co `statsInterval` pętli → webhook

### `TrapLoop()`
Timer wywoływany co `T_BRICK_CD` ms.
1. Klika w bieżącą pozycję kursora (gracz celuje w cegłę)
2. Inkrementuje `T_brickCount`, `T_totalBricks`
3. Sprawdza cel → dźwięk + webhook
4. Co `statsInterval` cegieł → webhook

### `ObbyLoop()`
Timer wywoływany co `O_PART_CD` ms.
1. Wysyła podwójne E (`{E down/up}` × 2 z `doubleTapDelay` pomiędzy)
2. Inkrementuje `O_partCount`, `O_totalParts`
3. Sprawdza cel → dźwięk + webhook

### `ReplicaLoop()`
Timer wywoływany co `R_CD` ms (domyślnie 14000).
Pierwsze wywołanie następuje **natychmiast** po starcie (`ReplicaLoop()` wywołane raz ręcznie w `StartMacro`).
1. Wysyła E (`SendInput "e"`)
2. Losuje szansę na Boba
3. Co `statsInterval` kliknięć → webhook

### `ManualBobTrigger(*)`
Hotkey callback — wywoływany przy naciśnięciu `MB_hotkey`.
1. Guard: `if (!running || paused) return`
2. Odczytuje wszystkie parametry z INI (live)
3. Sekwencja: `Sleep preEscSleep` → `Escape` → `Sleep escSleep` → `r` → `Sleep rSleep` → `Enter` → `Sleep enterSleep`
4. Losuje szansę na Boba
5. Co `statsInterval` kliknięć → webhook

### `CritGloveTrigger(*)`
Hotkey callback — wywoływany przy naciśnięciu `CG_hotkey`.
1. Guard: `if (!running || paused) return`
2. Odczytuje parametry z INI (live)
3. Combo: `{Space down}` → `Sleep spaceSleep` → `{Space up}` → `{LButton down}` → `Sleep clickSleep` → `{LButton up}`
4. Co `statsInterval` kliknięć → webhook

---

## System przypisywania klawiszy (WKP)

### `WKP_Open(parentHwnd, editCtrl)`
Otwiera niemodalny dialog "Naciśnij klawisz". **Nie blokuje wątku** (brak `ih.Wait()`).
- Tworzy `InputHook("L0 T10")` — timeout 10s, przechwytuje bez suppress
- Rejestruje `OnKeyDown := WKP_OnKey` (klawiatura)
- Rejestruje hotkeys na `RButton/MButton/XButton1/XButton2` (myszy)
- `LButton` celowo **pominięty** — nim klikamy przycisk "Ustaw klawisz"

### `WKP_OnKey(ih, vk, sc)`
- `Escape` → `WKP_Cancel()`
- Inny klawisz → `WKP_Finish(key)`

### `WKP_Finish(key)`
Wywołuje `WKP_Cleanup()`, wpisuje klawisz do `WKP_targetEdit.Value`, niszczy okno.

### `WKP_Cleanup()`
Wyłącza hotkeys myszy i zatrzymuje InputHook. Zawsze bezpieczne (try).

---

## System licencji

### Przepływ weryfikacji przy starcie

```
1. Wczytaj key z license.dat
2. Jeśli brak → InputBox → zapisz do license.dat
3. CheckLicenseFull(key, &aHWID)
   └─ HTTP GET → GitHub raw licenses.json
   └─ Parsuj JSON (string matching, bez bibliotek)
   └─ Zwróć status + HWID
4. Obsługa statusów:
   - "network_error" → MsgBox błąd sieci
   - "invalid"       → MsgBox błędny klucz, FileDelete license.dat
   - "banned"        → MsgBox zbanowany
   - "hwid_mismatch" → MsgBox inny HWID
   - "ok" z aHWID="" → SendWebhookHWID(NOWA AKTYWACJA) + FileAppend sentInfoFile + ExitApp
   - "ok" z HWID     → kontynuuj
5. InitDebugCode()
6. if !FileExist(sentInfoFile) → SendWebhookHWID() + FileAppend sentInfoFile
```

### `sentInfoFile` — mechanizm jednorazowego wysłania
Plik `%AppData%\SBMM\sent_info.dat` tworzy się po pierwszym wysłaniu HWID.
Jego istnienie blokuje ponowne wysyłanie przy każdym starcie.
Usunięcie pliku → webhook zostanie wysłany przy kolejnym uruchomieniu.

---

## System webhooków Discord

### `PostWebhook(url, msg)`
Wysyła POST na URL Discorda z payloadem `{"content": "msg"}`.
Używa `WinHttp.WinHttpRequest.5.1` (Windows built-in, nie wymaga bibliotek).
Ustawia `SetRequestHeader "Content-Type", "application/json"`.

### Kiedy są wysyłane webhooki:
- Znaleziony Bob → natychmiast, bez cooldownu
- Statystyki → co `InterwalStatystyk` iteracji, respektując `whCooldown`
- `P_lastWH / T_lastWH / ...` → timestamp ostatniego wysłania, sprawdzany przed każdym wysłaniem

---

## Zapisywanie danych

### `SaveHistory()`
Wywoływana przy `StopMacro`. Dopisuje (`FileAppend`) jedną linię do pliku historii aktywnego modułu. Format:
```
2025-01-15 14:23:11 | Kliki: 150 | Boby: 0 | Szac.: 0.020 | Czas: 00:35:00
```

### `SaveTotalData()`
Wywoływana przy `StopMacro` i `SafeExit`. Nadpisuje plik `*_total.dat` aktualną wartością łączną. Używa `FileDelete` + `FileAppend` zamiast `FileOverwrite` dla bezpieczeństwa.

### Dane INI
Każde `Save*Settings()` wywołuje `IniWrite` dla zmienionych wartości.
Parametry timingowe są odczytywane **live** (przy każdej iteracji pętli), więc zmiana w ustawieniach działa bez restartu modułu.

---

## Konwencje nazewnictwa

| Wzorzec | Znaczenie |
|---------|-----------|
| `P_*` | Portal |
| `T_*` | Trap |
| `O_*` | Obby |
| `R_*` | Replica Bob |
| `MB_*` | Manual Bob |
| `CG_*` | Critical Glove |
| `WKP_*` | Key Picker (picker okno wyboru klawisza) |
| `Build*GUI()` | Tworzy okno GUI modułu |
| `Update*Stats()` | Odświeża kontrolki GUI statystyk |
| `Open*Settings()` | Otwiera okno ustawień |
| `Save*Settings()` | Zapisuje ustawienia do INI |
| `Open*Debug()` | Otwiera chronioną sekcję debugowania |
| `Save*Debug()` | Zapisuje ustawienia debugowania |
| `Open*History()` | Otwiera okno historii sesji |
| `Load*INI()` | Wczytuje konfigurację z pliku INI |
| `*Loop()` | Główna pętla modułu (timer-based) |
| `*Trigger()` | Główna akcja modułu (hotkey-based) |

---

## Zależności zewnętrzne

- **AutoHotkey v2.0** — interpreter
- **WinHttp.WinHttpRequest.5.1** — wbudowany w Windows, używany do HTTP
- **Gra (`test.exe`)** — wykrywana przez `WinExist` do auto-pauzy
- **GitHub** — hosting `licenses.json` (raw.githubusercontent.com)
- **Discord Webhooks** — opcjonalne, do statystyk

Brak zewnętrznych bibliotek AHK ani DLL poza systemowymi.

---

---

# main.py — Bot Discord + Web Panel API

## Opis ogólny

Plik `main.py` to serwer napisany w Pythonie łączący trzy funkcje:
1. **Bot Discord** — zarządzanie kluczami licencyjnymi komendami
2. **Odbieranie webhooków z makra** — automatyczne przypisywanie HWID i debug_code
3. **Web API + WebSocket** — REST API dla panelu administracyjnego (`panel.html`)

Uruchamia się jako jeden proces. Bot Discord i serwer HTTP (`aiohttp`) działają równolegle w tej samej pętli `asyncio`.

---

## Zmienne środowiskowe (konfiguracja)

| Zmienna | Opis |
|---------|------|
| `DISCORD_TOKEN` | Token bota Discord |
| `GITHUB_TOKEN` | Personal Access Token do zapisu `licenses.json` na GitHub |
| `GITHUB_REPO_OWNER` | Właściciel repozytorium GitHub (np. `SanTobinoOfficial`) |
| `GITHUB_REPO_NAME` | Nazwa repozytorium (np. `MakroSlapBattlesBob`) |
| `ADMIN_CHANNEL_ID` | ID kanału Discord (aktualnie nieużywany bezpośrednio) |
| `WEBHOOK_SECRET` | Sekret webhooka (aktualnie zarezerwowany, nieużywany) |

---

## Stałe i stan globalny

| Zmienna | Typ | Opis |
|---------|-----|------|
| `JSON_FILE` | `str` | Nazwa lokalnego pliku z licencjami: `"licenses.json"` |
| `activity_log` | `list[dict]` | Log ostatnich 200 akcji. Każdy wpis: `{time, date, action, details}` |
| `ws_clients` | `set` | Zbiór aktywnych połączeń WebSocket (`web.WebSocketResponse`) |
| `bot` | `commands.Bot` | Instancja bota discord.py z prefixem `"."` |

---

## Funkcje pomocnicze

### `log_activity(action, details)`
Dodaje wpis na początek `activity_log` (insert na indeks 0 = najnowszy pierwszy).
Przycina listę do 200 wpisów. Wywołuje `asyncio.ensure_future(_broadcast_ws())` żeby powiadomić panel.

### `async _broadcast_ws()`
Wysyła `{"type": "update"}` do wszystkich klientów WebSocket z `ws_clients`.
Usuwa martwe połączenia z zestawu.

### `load_licenses() → dict`
Wczytuje `licenses.json` z dysku. Zwraca `{}` jeśli plik nie istnieje lub JSON jest uszkodzony.

### `save_licenses(data)`
Zapisuje `data` do `licenses.json` (z `indent=4`), następnie wywołuje `update_github_file(data)`.

### `update_github_file(data)`
Wysyła PUT na GitHub API (`/repos/.../contents/licenses.json`).
Najpierw GET aby pobrać aktualny `sha` (wymagany przez GitHub do update).
Koduje JSON jako base64. Pomija jeśli brak zmiennych środowiskowych.

### `generate_key() → str`
Generuje losowy klucz licencyjny formatu `XXXX-XXXX-XXXX-XXXX` z wielkich liter i cyfr.

### `parse_webhook_message(content: str) → dict`
Parsuje treść wiadomości Discord z makra AHK przez regex.

Zwracane pola:
| Pole | Regex | Opis |
|------|-------|------|
| `key` | `Klucz: XXXX-XXXX-XXXX-XXXX` | Klucz licencyjny |
| `hwid` | `HWID: [A-F0-9-]{30,}` | HWID urządzenia |
| `debug_code` | `KodDebug: XXXX-XXXX` | Kod debug PIN |
| `type` | `"NOWA AKTYWACJA"` w treści | Typ wiadomości: `"activation"` |

Jeśli brak `"NOWA AKTYWACJA"` w treści — `type` nie jest ustawiany.

---

## Komendy Discord (prefix `.`)

Wszystkie komendy wymagają wpisania ich na kanale gdzie bot ma dostęp.

| Komenda | Argumenty | Opis |
|---------|-----------|------|
| `.generate` | — | Generuje nowy klucz, dodaje do JSON, pushuje na GitHub |
| `.ban` | `key` | Ustawia `banned: true` dla klucza |
| `.unban` | `key` | Ustawia `banned: false` dla klucza |
| `.reset` | `key` | Czyści pole `hwid` (pozwala na ponowne przypisanie) |
| `.assign` | `key hwid` | Ręcznie przypisuje HWID do klucza |
| `.note` | `key tekst...` | Ustawia notatkę dla klucza |
| `.clearnote` | `key` | Czyści notatkę |
| `.info` | `key` | Wyświetla wszystkie dane klucza (status, HWID, debug_code, notatka) |
| `.list` | — | Lista wszystkich kluczy ze statusem, HWID (skrócony), debug_code, notatką |
| `.debugcode` | `key` | Wyświetla kod debug dla klucza |
| `.delete` | `key` | Usuwa klucz z bazy całkowicie |

---

## Odbieranie webhooków z makra — `on_message(message)`

Wywoływany dla każdej wiadomości na serwerze.

**Filtrowanie:**
- Ignoruje wiadomości od zwykłych użytkowników (`not message.author.bot`)
- Ignoruje wiadomości od samego bota (`message.author == bot.user`)
- Ignoruje wiadomości bez `key` w treści
- Ignoruje wiadomości gdzie `type != "activation"`

**Logika dla `NOWA AKTYWACJA`:**
1. Sprawdza czy klucz istnieje w bazie — jeśli nie, nie robi nic
2. **HWID:** zapisuje tylko jeśli pole `hwid` jest puste (`not data[key].get('hwid')`)
3. **debug_code:** zapisuje tylko jeśli pole `debug_code` jest puste (`not data[key].get('debug_code')`)
4. Jeśli cokolwiek się zmieniło → `save_licenses()` → GitHub push
5. **Brak wiadomości na kanał** — bot działa cicho, tylko log w konsoli

---

## Struktura `licenses.json`

```json
{
    "ABCD-EFGH-IJKL-MNOP": {
        "hwid": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "banned": false,
        "note": "Jan Kowalski",
        "debug_code": "ABCD-1234"
    }
}
```

| Pole | Typ | Opis |
|------|-----|------|
| `hwid` | `str` | HWID urządzenia. Pusty = klucz oczekuje na aktywację |
| `banned` | `bool` | Czy klucz jest zablokowany |
| `note` | `str` | Notatka admina (np. nazwa użytkownika) |
| `debug_code` | `str` | Kod PIN do sekcji debugowania. Pusty = makro nie uruchomione jeszcze |

---

## REST API (aiohttp, port 5000)

### `GET /`
Serwuje `templates/panel.html` jako HTML.

### `GET /api/licenses`
Zwraca tablicę JSON wszystkich kluczy. Każdy wpis zawiera:
`key, hwid, banned, note, debug_code, active` (active = bool: ma HWID i nie jest zbanowany).

### `GET /api/log`
Zwraca `activity_log` — tablicę ostatnich 200 akcji.

### `GET /api/stats`
Zwraca `{total, active, pending, banned}` — statystyki kluczy.

### `GET /api/generate`
Generuje nowy klucz, zapisuje, zwraca `{"key": "XXXX-..."}`.

### `POST /api/action`
Wykonuje akcję na kluczu. Body JSON: `{"action": "...", "key": "...", ...}`

| action | Dodatkowe pola | Opis |
|--------|----------------|------|
| `ban` | — | Banuje klucz |
| `unban` | — | Odbanowuje |
| `reset` | — | Czyści HWID |
| `delete` | — | Usuwa klucz |
| `note` | `note: str` | Ustawia notatkę |
| `clear_debug` | — | Czyści debug_code (pozwala na ponowne przypisanie) |

### `GET /ws`
WebSocket endpoint. Serwer wysyła `{"type": "update"}` przy każdej zmianie danych.
Klient powinien odświeżyć dane po odebraniu tego komunikatu.

---

## `async on_ready()`
Wywoływany gdy bot połączy się z Discord. Wywołuje `start_webserver()`.

## `async start_webserver()`
Tworzy `web.Application()`, rejestruje wszystkie routes, uruchamia `TCPSite` na `0.0.0.0:5000`.

---

---

# panel.html — Panel administracyjny

## Opis ogólny

Pojedynczy plik HTML (~555 linii) z wbudowanym CSS i JavaScript.
Interfejs webowy do zarządzania kluczami licencyjnymi.
Komunikuje się z `main.py` przez REST API i WebSocket.
Nie wymaga żadnych zewnętrznych bibliotek — czysty HTML/CSS/JS.

---

## Struktura HTML

| Element | ID | Opis |
|---------|----|------|
| Pasek statusu | `status-text` | Wyświetla stan połączenia WebSocket |
| Karty statystyk | `stat-total/active/pending/banned` | Liczniki kluczy |
| Tabela kluczy | `keys-tbody` | Główna tabela z listą kluczy |
| Pole wyszukiwania | `search` | Filtrowanie tabeli |
| Licznik kluczy | `key-count` | Aktualizowany po filtrze |
| Log aktywności | `log-list` | Lista ostatnich akcji |
| Nowy klucz | `new-key-display` | Wyświetla ostatnio wygenerowany klucz |
| Modal notatki | `note-modal` | Okno edycji notatki |
| Modal debug | `debug-modal` | Okno z kodem debug + przycisk kopiowania |
| Toast | `toast` | Powiadomienia (znika po 2.5s) |

---

## Zmienne JS

| Zmienna | Opis |
|---------|------|
| `allLicenses` | Lokalna kopia wszystkich kluczy (tablica) — używana do filtrowania bez ponownego fetch |
| `ws` | Aktywne połączenie WebSocket |
| `wsRetryDelay` | Aktualny delay reconnect (ms) — rośnie eksponencjalnie, max 30s |
| `currentNoteKey` | Klucz dla którego aktualnie edytowana jest notatka |

---

## Funkcje JavaScript

### `api(path, opts={}) → Promise`
Wrapper na `fetch()`. Rzuca błąd jeśli `response.ok` jest false. Upraszcza wywołania API.

### `toast(msg, type='success')`
Wyświetla powiadomienie na dole ekranu. Typy: `'success'` (zielony), `'error'` (czerwony).
Automatycznie znika po 2500ms.

### `debugCell(item) → string`
Generuje HTML komórki z kodem debug. Jeśli kod istnieje — klikalny badge otwierający modal. Jeśli nie — szary tekst "brak".

### `openDebugModal(key, code)`
Otwiera modal z kodem debug dla klucza. Ustawia `debug-modal-key-label` i `debug-modal-code`.

### `closeDebugModal()`
Zamyka modal debug.

### `async copyDebugFromModal()`
Kopiuje kod debug do schowka przez `navigator.clipboard.writeText()`. Pokazuje toast potwierdzający.

### `async clearDebugCode()`
Wywołuje `POST /api/action {action: "clear_debug"}`. Po sukcesie odświeża dane i zamyka modal.

### `statusBadge(item) → string`
Zwraca HTML badge statusu: `Aktywny` (zielony) / `Oczekuje` (żółty) / `Zbanowany` (czerwony).

### `noteCell(item) → string`
Zwraca HTML komórki notatki z przyciskiem edycji (ikona ołówka).

### `renderTable(data)`
Renderuje całą tabelę kluczy z podanej tablicy. Każdy wiersz zawiera:
klucz, HWID (skrócony), status badge, debug_code, notatkę, przyciski akcji (Ban/Unban, Reset, Usuń).

### `filterTable()`
Filtruje `allLicenses` po wartości `#search` (szuka w: key, hwid, note, debug_code).
Wywołuje `renderTable()` z przefiltrowaną tablicą. Aktualizuje `#key-count`.

### `openNoteModal(key, currentNote)`
Otwiera modal edycji notatki. Wypełnia `#note-input` aktualną notatką.

### `closeNoteModal()`
Zamyka modal notatki.

### `async saveNote()`
Wywołuje `POST /api/action {action: "note", note: ...}`. Odświeża dane.

### `async clearNote()`
Wywołuje `POST /api/action {action: "note", note: ""}`. Odświeża dane.

### `async loadStats()`
Pobiera `GET /api/stats`, aktualizuje cztery karty statystyk.

### `async loadLicenses()`
Pobiera `GET /api/licenses`, zapisuje do `allLicenses`, wywołuje `renderTable(allLicenses)`.

### `async loadLog()`
Pobiera `GET /api/log`, renderuje listę ostatnich akcji w `#log-list`.
Format wpisu: `[HH:MM:SS] AKCJA — szczegóły`.

### `async loadAll()`
Wywołuje równolegle `loadStats()`, `loadLicenses()`, `loadLog()` przez `Promise.all`.

### `async generateKey()`
Wywołuje `GET /api/generate`. Wyświetla nowy klucz w `#new-key-display`. Odświeża dane.

### `copyKey()`
Kopiuje klucz z `#new-key-display` do schowka.

### `async action(act, key)`
Ogólna funkcja akcji. Wywołuje `POST /api/action {action: act, key: key}`.
Odświeża dane po sukcesie.

### `connectWS()`
Łączy się z `ws://host/ws`. Obsługa zdarzeń:
- `onopen` → aktualizuje `#status-text` na "Polaczono", resetuje `wsRetryDelay`
- `onmessage` → jeśli `type == "update"` → wywołuje `loadAll()`
- `onclose` → aktualizuje status, ponawia połączenie z eksponencjalnym backoff (max 30s)
- `onerror` → zamyka połączenie (wyzwala `onclose`)

---

## Przepływ inicjalizacji panelu

```
DOMContentLoaded
  └─ loadAll()        — pierwsze załadowanie danych
  └─ connectWS()      — połączenie WebSocket
       └─ onmessage "update" → loadAll()   — każda zmiana danych
```

---

---

# requirements.txt

Zależności Pythona dla `main.py`:

| Pakiet | Wersja min. | Opis |
|--------|-------------|------|
| `discord.py` | `>=2.3.0` | Biblioteka bota Discord. Używana do `commands.Bot`, dekoratorów `@bot.command`, `@bot.event` |
| `aiohttp` | `>=3.9.0` | Asynchroniczny serwer HTTP. Używany do REST API i WebSocket (`web.Application`, `web.TCPSite`, `web.WebSocketResponse`) |
| `requests` | `>=2.31.0` | Synchroniczny HTTP client. Używany wyłącznie w `update_github_file()` do komunikacji z GitHub API |

### Instalacja
```bash
pip install -r requirements.txt
```

### Uruchomienie
```bash
python main.py
```

Panel dostępny pod: `http://localhost:5000`

