#Requires AutoHotkey v2.0
#SingleInstance Force

; ╔══════════════════════════════════════════════╗
; ║   SLAP BATTLES MULTI MACRO  —  v1.4.1       ║
; ╚══════════════════════════════════════════════╝

; ══════════════════════════════════════════════
; STAŁE APLIKACJI
; ══════════════════════════════════════════════
global APP_NAME    := "Slap Battles Multi Macro"
global APP_VERSION := "v1.4.1"

global licenseFile := A_AppData "\SBMM\license.dat"
global jsonURL     := "https://gist.githubusercontent.com/SanTobinoOfficial/4700f4452a52144b6e3922501b55dcf1/raw/licenses.json"
global webhookHWID := ""

global key  := ""
global hwid := ""

; ── aktywny moduł ──
global activeModule := ""   ; "portal" / "trap" / "obby" / "replica" / "manualbob" / "critglove"

; ── Manual Bob zmienne ──────────────────────────────────────────
global MB_IniFile     := A_AppData "\SBMM\manualbob_config.ini"
global MB_hotkey      := "e"   ; klawisz wczytywany z INI przy starcie
global MB_HistFile    := A_AppData "\SBMM\manualbob_historia.txt"
global MB_TotalFile   := A_AppData "\SBMM\manualbob_total.dat"
global MB_webhook     := ""
global MB_whCooldown  := 5000
global MB_lastWH      := 0
global MB_clickCount  := 0
global MB_totalClicks := 0
global MB_BOB_DENOM   := 7500
global MB_bobHits     := 0
global MB_clickText, MB_totalText, MB_timerText, MB_cphText, MB_bobText, MB_estText

; ── Critical Glove zmienne ──────────────────────────────────────
global CG_IniFile     := A_AppData "\SBMM\critglove_config.ini"
global CG_hotkey      := "RButton"   ; klawisz wczytywany z INI przy starcie
global CG_HistFile    := A_AppData "\SBMM\critglove_historia.txt"
global CG_TotalFile   := A_AppData "\SBMM\critglove_total.dat"
global CG_webhook     := ""
global CG_whCooldown  := 5000
global CG_lastWH      := 0
global CG_clickCount  := 0
global CG_totalClicks := 0
global CG_running     := false
global CG_clickText, CG_totalText, CG_timerText, CG_cphText

; ── Replica Bob zmienne ──
global R_IniFile     := A_AppData "\SBMM\replica_config.ini"
global R_HistFile    := A_AppData "\SBMM\replica_historia.txt"
global R_TotalFile   := A_AppData "\SBMM\replica_total.dat"
global R_webhook     := ""
global R_whCooldown  := 10000
global R_lastWH      := 0
global R_clickCount  := 0
global R_totalClicks := 0
global R_BOB_DENOM   := 7500
global R_CD          := 14000
global R_bobHits     := 0
global R_lastTick    := 0
global R_loopTimer   := 0
global R_clickText, R_totalText, R_timerText, R_cphText, R_bobText, R_estText

; ── stan współdzielony ──
global running      := false
global paused       := false
global sessionStart := 0

; ── BOB zmienne ──
global P_IniFile     := A_AppData "\SBMM\portal_config.ini"
global P_HistFile    := A_AppData "\SBMM\portal_historia.txt"
global P_TotalFile   := A_AppData "\SBMM\portal_total.dat"
global P_webhook     := ""
global P_whCooldown  := 3000
global P_lastWH      := 0
global P_loopCount   := 0
global P_bobHits     := 0
global P_totalLoops  := 0
global P_BOB_DENOM   := 7500
; ── Debug / Security ──
global debugCodeFile := A_AppData "\SBMM\debug_code.dat"
global sentInfoFile  := A_AppData "\SBMM\sent_info.dat"   ; flaga — info wysłane raz
global debugCode     := ""

; Portal coords found dynamically at runtime
global portalX := 956, portalY := 982

; ── Trap/Brick zmienne ──
global T_IniFile      := A_AppData "\SBMM\trap_config.ini"
global T_HistFile     := A_AppData "\SBMM\trap_historia.txt"
global T_TotalFile    := A_AppData "\SBMM\trap_total.dat"
global T_webhook      := ""
global T_whCooldown   := 5000
global T_lastWH       := 0
global T_brickCount   := 0
global T_totalBricks  := 0
global T_BRICK_GOAL   := 1000
global T_BRICK_CD     := 5000

; ── Obby Mastery zmienne ──
global O_IniFile      := A_AppData "\SBMM\obby_config.ini"
global O_HistFile     := A_AppData "\SBMM\obby_historia.txt"
global O_TotalFile    := A_AppData "\SBMM\obby_total.dat"
global O_webhook      := ""
global O_whCooldown   := 5000
global O_lastWH       := 0
global O_partCount    := 0
global O_totalParts   := 0
global O_PART_GOAL    := 2000
global O_PART_CD      := 3000

; ── GUI handles ──
global gui1
global statusText, gameText
global P_loopText, P_bobText, P_estText, P_timerText, P_lphText, P_totalText
global T_brickText, T_totalText, T_timerText, T_bphText, T_etaText, T_progressText, T_progressBar
global O_partText, O_totalText, O_timerText, O_pphText, O_etaText, O_progressText, O_progressBar

; ══════════════════════════════════════════════
; FOLDER
; ══════════════════════════════════════════════
if !DirExist(A_AppData "\SBMM")
    DirCreate(A_AppData "\SBMM")

; ══════════════════════════════════════════════
; WARUNKI UŻYTKOWANIA (ToS) — akceptacja raz
; ══════════════════════════════════════════════
global tosFile := A_AppData "\SBMM\tos_accepted.dat"
if !FileExist(tosFile) {
    ; Otwórz pełne Warunki Użytkowania w przeglądarce
    Run "https://github.com/SanTobinoOfficial/BOB/blob/main/docs/ToS-Makro.md"
    tosText := "WARUNKI UŻYTKOWANIA — Slap Battles Multi Macro " APP_VERSION "`n"
        . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n`n"
        . "Pełna treść warunków została otwarta w przeglądarce:`n"
        . "github.com/SanTobinoOfficial/BOB`n`n"
        . "Skrót kluczowych zasad:`n"
        . "• Makro tylko na własnym koncie Roblox`n"
        . "• Zakaz sprzedaży i udostępniania klucza`n"
        . "• Używasz na własne ryzyko (ban w grze)`n"
        . "• HWID wysyłany raz do admina (weryfikacja licencji)`n`n"
        . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
        . "Klikając OK akceptujesz pełne Warunki Użytkowania."
    result := MsgBox(tosText, APP_NAME " — Warunki użytkowania", "OKCancel Icon! 262144")
    if (result != "OK") {
        MsgBox "Musisz zaakceptować warunki, aby używać makra.", APP_NAME, 16
        ExitApp
    }
    FileAppend "accepted", tosFile
}

; ══════════════════════════════════════════════
; POMOCNICZE
; ══════════════════════════════════════════════
SafeNum(val, def) {
    val := Trim(val)
    return (val != "" && IsNumber(val)) ? Number(val) : def
}

FormatTime2(ms) {
    s := ms // 1000
    m := s  // 60
    h := m  // 60
    return Format("{:02d}:{:02d}:{:02d}", h, Mod(m,60), Mod(s,60))
}

FormatLoops(n) {
    if (n >= 1000000)
        return Format("{:.2f}M", n/1000000)
    if (n >= 1000)
        return Format("{:.1f}k", n/1000)
    return String(n)
}

; ══════════════════════════════════════════════
; HWID
; ══════════════════════════════════════════════
GetHWID() {
    for item in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_ComputerSystemProduct")
        return item.UUID
    return "UNKNOWN"
}

; ══════════════════════════════════════════════
; WEBHOOK
; ══════════════════════════════════════════════
BuildPayload(msg) {
    s := StrReplace(msg, "\",     "\\")
    s := StrReplace(s,   Chr(34), "\" Chr(34))
    s := StrReplace(s,   "`r`n",  "\n")
    s := StrReplace(s,   "`n",    "\n")
    return Chr(123) Chr(34) "content" Chr(34) ":" Chr(34) s Chr(34) Chr(125)
}

PostWebhook(url, msg) {
    if (url = "")
        return
    try {
        h := ComObject("WinHttp.WinHttpRequest.5.1")
        h.Open("POST", url, false)
        h.SetRequestHeader("Content-Type", "application/json")
        h.Send(BuildPayload(msg))
    }
}

SendWebhookHWID(msg) {
    global webhookHWID
    if (webhookHWID = "")
        return
    try {
        h := ComObject("WinHttp.WinHttpRequest.5.1")
        h.Open("POST", webhookHWID, false)
        h.SetRequestHeader("Content-Type", "application/json")
        h.Send(BuildPayload(msg))
    } catch as e {
        MsgBox "Błąd webhooka HWID: " e.Message, APP_NAME, 16
    }
}

; ══════════════════════════════════════════════
; SYSTEM LICENCJI
; ══════════════════════════════════════════════
GetKeyBlock(json, k) {
    if !InStr(json, '"' k '"')
        return ""
    p  := InStr(json, '"' k '"')
    bs := InStr(json, "{", , p)
    be := InStr(json, "}", , bs)
    return SubStr(json, bs, be - bs + 1)
}

CheckLicenseFull(k, &aHWID) {
    global jsonURL
    aHWID := ""
    try {
        h := ComObject("WinHttp.WinHttpRequest.5.1")
        h.Open("GET", jsonURL "?t=" A_TickCount, false)
        h.Send()
        json := h.ResponseText
    } catch {
        return "NETWORK_ERROR"
    }
    block := GetKeyBlock(json, k)
    if (block = "")
        return "INVALID"
    if RegExMatch(block, '"banned"\s*:\s*true')
        return "BANNED"
    if RegExMatch(block, '"hwid"\s*:\s*"([^"]*)"', &m) aHWID := m[1]
    if (aHWID != "" && aHWID != GetHWID())
        return "HWID_MISMATCH"
    return "VALID"
}

; ══════════════════════════════════════════════
; AKTYWACJA LICENCJI
; ══════════════════════════════════════════════
if !FileExist(licenseFile) {
    ib  := InputBox("Wprowadź klucz licencyjny:", APP_NAME " — Aktywacja")
    key := ib.Value
    if (ib.Result = "Cancel" || key = "") {
        MsgBox "Anulowano aktywację.", APP_NAME, 48
        ExitApp
    }
    FileAppend key, licenseFile
}

key    := Trim(FileRead(licenseFile))
hwid   := GetHWID()
aHWID  := ""
result := CheckLicenseFull(key, &aHWID)

switch result {
    case "NETWORK_ERROR":
        MsgBox "Brak połączenia z serwerem.", APP_NAME, 16
        ExitApp()
    case "INVALID":
        MsgBox "Nieprawidłowy klucz.", APP_NAME, 16
        FileDelete licenseFile
        ExitApp()
    case "BANNED":
        MsgBox "Klucz zablokowany.", APP_NAME, 16
        FileDelete licenseFile
        ExitApp()
    case "HWID_MISMATCH":
        MsgBox "Klucz na innym urządzeniu.", APP_NAME, 16
        FileDelete licenseFile
        ExitApp()
}

if (aHWID = "") {
    ; Nowe urządzenie — wyślij HWID + debug_code, ustaw flagę
    InitDebugCode()
    SendWebhookHWID("NOWA AKTYWACJA`nKlucz: " key "`nHWID: " hwid "`nKodDebug: " debugCode "`nData: " FormatTime(, "yyyy-MM-dd HH:mm:ss"))
    ; Zapisz flagę żeby następnym razem nie wysyłać ponownie
    FileAppend "sent", sentInfoFile
    MsgBox "HWID wysłany do admina.`nUruchom ponownie po aktywacji.`n`nKlucz: " key "`nHWID: " hwid, APP_NAME, 64
    FileDelete licenseFile
    ExitApp
}

CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
InitDebugCode()  ; wczytaj/wygeneruj kod debug po pomyślnej weryfikacji

; Wyślij info tylko jeśli flaga nie istnieje (pierwszy start po przypisaniu HWID)
if !FileExist(sentInfoFile) {
    SendWebhookHWID("NOWA AKTYWACJA`nKlucz: " key "`nHWID: " hwid "`nKodDebug: " debugCode "`nData: " FormatTime(, "yyyy-MM-dd HH:mm:ss"))
    FileAppend "sent", sentInfoFile
}

; ══════════════════════════════════════════════
; WCZYTAJ INI MODUŁÓW
; ══════════════════════════════════════════════
LoadPortalINI() {
    global P_IniFile, P_webhook, P_whCooldown, P_totalLoops, P_TotalFile
    if !FileExist(P_IniFile) {
        IniWrite "",   P_IniFile, "Webhook", "URL"
        IniWrite 3000, P_IniFile, "Webhook", "Cooldown"
        IniWrite 3000, P_IniFile, "Makro",   "CzasRuchu"
        IniWrite 1500, P_IniFile, "Makro",   "CzasStrafe"
        IniWrite 10,   P_IniFile, "Makro",   "OffsetMax"
        IniWrite 100,  P_IniFile, "Makro",   "InterwalStatystyk"
        IniWrite 1,    P_IniFile, "Makro",   "AutoPauza"
        IniWrite 1,    P_IniFile, "Makro",   "DzwiekBob"
    }
    P_webhook    := IniRead(P_IniFile, "Webhook", "URL",      "")
    P_whCooldown := SafeNum(IniRead(P_IniFile, "Webhook", "Cooldown", "3000"), 3000)
    P_totalLoops := FileExist(P_TotalFile) ? SafeNum(Trim(FileRead(P_TotalFile)), 0) : 0
}

LoadTrapINI() {
    global T_IniFile, T_webhook, T_whCooldown, T_totalBricks, T_TotalFile
    if !FileExist(T_IniFile) {
        IniWrite "",   T_IniFile, "Webhook", "URL"
        IniWrite 5000, T_IniFile, "Webhook", "Cooldown"
        IniWrite 50,   T_IniFile, "Makro",   "InterwalStatystyk"
        IniWrite 1,    T_IniFile, "Makro",   "AutoPauza"
        IniWrite 1,    T_IniFile, "Makro",   "DzwiekCel"
    }
    T_webhook    := IniRead(T_IniFile, "Webhook", "URL",      "")
    T_whCooldown := SafeNum(IniRead(T_IniFile, "Webhook", "Cooldown", "5000"), 5000)
    T_totalBricks := FileExist(T_TotalFile) ? SafeNum(Trim(FileRead(T_TotalFile)), 0) : 0
}

LoadObbyINI() {
    global O_IniFile, O_webhook, O_whCooldown, O_totalParts, O_TotalFile
    if !FileExist(O_IniFile) {
        IniWrite "",   O_IniFile, "Webhook", "URL"
        IniWrite 5000, O_IniFile, "Webhook", "Cooldown"
        IniWrite 100,  O_IniFile, "Makro",   "InterwalStatystyk"
        IniWrite 1,    O_IniFile, "Makro",   "AutoPauza"
        IniWrite 1,    O_IniFile, "Makro",   "DzwiekCel"
        IniWrite 500,  O_IniFile, "Makro",   "DoubleTapDelay"
    }
    O_webhook    := IniRead(O_IniFile, "Webhook", "URL",      "")
    O_whCooldown := SafeNum(IniRead(O_IniFile, "Webhook", "Cooldown", "5000"), 5000)
    O_totalParts := FileExist(O_TotalFile) ? SafeNum(Trim(FileRead(O_TotalFile)), 0) : 0
}

LoadPortalINI()
LoadTrapINI()
LoadObbyINI()

; ── Replica INI ───────────────────────────────────────────────────
LoadReplicaINI() {
    global R_IniFile, R_webhook, R_whCooldown, R_totalClicks, R_TotalFile, R_CD, R_BOB_DENOM
    if !FileExist(R_IniFile) {
        IniWrite "",     R_IniFile, "Webhook",      "URL"
        IniWrite 10000,  R_IniFile, "Webhook",      "Cooldown"
        IniWrite 14000,  R_IniFile, "Zaawansowane", "CD"
        IniWrite 7500,   R_IniFile, "Debug",        "BobDenom"
        IniWrite 100,    R_IniFile, "Makro",        "InterwalStatystyk"
        IniWrite 1,      R_IniFile, "Makro",        "AutoPauza"
        IniWrite 1,      R_IniFile, "Makro",        "DzwiekBob"
    }
    R_webhook    := IniRead(R_IniFile, "Webhook", "URL",      "")
    R_whCooldown := SafeNum(IniRead(R_IniFile, "Webhook", "Cooldown", "10000"), 10000)
    R_CD         := SafeNum(IniRead(R_IniFile, "Zaawansowane", "CD", "14000"), 14000)
    R_BOB_DENOM  := SafeNum(IniRead(R_IniFile, "Debug", "BobDenom", "7500"),   7500)
    R_totalClicks := FileExist(R_TotalFile) ? SafeNum(Trim(FileRead(R_TotalFile)), 0) : 0
}
LoadReplicaINI()

; ── Manual Bob INI ───────────────────────────────────────────────
LoadManualBobINI() {
    global MB_IniFile, MB_webhook, MB_whCooldown, MB_totalClicks, MB_TotalFile, MB_BOB_DENOM
    if !FileExist(MB_IniFile) {
        IniWrite "",    MB_IniFile, "Webhook",      "URL"
        IniWrite 5000,  MB_IniFile, "Webhook",      "Cooldown"
        IniWrite 100,   MB_IniFile, "Makro",        "InterwalStatystyk"
        IniWrite 1,     MB_IniFile, "Makro",        "AutoPauza"
        IniWrite 1,     MB_IniFile, "Makro",        "DzwiekBob"
        IniWrite 7500,  MB_IniFile, "Debug",        "BobDenom"
        IniWrite 100,   MB_IniFile, "Zaawansowane", "EscSleep"
        IniWrite 100,   MB_IniFile, "Zaawansowane", "RSleep"
        IniWrite 100,   MB_IniFile, "Zaawansowane", "EnterSleep"
        IniWrite "e",   MB_IniFile, "Zaawansowane", "Hotkey"
        IniWrite 0,     MB_IniFile, "Zaawansowane", "PreEscSleep"
    }
    MB_webhook    := IniRead(MB_IniFile, "Webhook", "URL",      "")
    MB_whCooldown := SafeNum(IniRead(MB_IniFile, "Webhook", "Cooldown", "5000"), 5000)
    MB_BOB_DENOM  := SafeNum(IniRead(MB_IniFile, "Debug",   "BobDenom", "7500"), 7500)
    MB_hotkey     := IniRead(MB_IniFile, "Zaawansowane", "Hotkey", "e")
    MB_totalClicks := FileExist(MB_TotalFile) ? SafeNum(Trim(FileRead(MB_TotalFile)), 0) : 0
}
LoadManualBobINI()

; ── Critical Glove INI ───────────────────────────────────────────
LoadCritGloveINI() {
    global CG_IniFile, CG_webhook, CG_whCooldown, CG_totalClicks, CG_TotalFile
    if !FileExist(CG_IniFile) {
        IniWrite "",    CG_IniFile, "Webhook",      "URL"
        IniWrite 5000,  CG_IniFile, "Webhook",      "Cooldown"
        IniWrite 100,   CG_IniFile, "Makro",        "InterwalStatystyk"
        IniWrite 1,     CG_IniFile, "Makro",        "AutoPauza"
        IniWrite 50,    CG_IniFile, "Zaawansowane", "SpaceSleep"
        IniWrite 30,    CG_IniFile, "Zaawansowane", "ClickSleep"
        IniWrite "RButton", CG_IniFile, "Zaawansowane", "Hotkey"
    }
    CG_webhook    := IniRead(CG_IniFile, "Webhook", "URL",      "")
    CG_whCooldown := SafeNum(IniRead(CG_IniFile, "Webhook", "Cooldown", "5000"), 5000)
    CG_hotkey     := IniRead(CG_IniFile, "Zaawansowane", "Hotkey", "RButton")
    CG_totalClicks := FileExist(CG_TotalFile) ? SafeNum(Trim(FileRead(CG_TotalFile)), 0) : 0
}
LoadCritGloveINI()

; ── Debug code: generowany raz przy pierwszym uruchomieniu ──────
GenerateDebugCode() {
    chars := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    code  := ""
    Loop 8
        code .= SubStr(chars, Random(1, StrLen(chars)), 1)
    return SubStr(code, 1, 4) "-" SubStr(code, 5, 4)
}

InitDebugCode() {
    global debugCodeFile, debugCode, key, hwid
    if FileExist(debugCodeFile) {
        ; Format pliku: "XXXX-XXXX|klucz|hwid" — bierzemy tylko pierwszą część
        raw       := Trim(FileRead(debugCodeFile))
        debugCode := StrSplit(raw, "|")[1]
    } else {
        debugCode := GenerateDebugCode()
        ; Zapisz razem z kluczem i HWID dla identyfikacji
        FileAppend debugCode "|" key "|" hwid, debugCodeFile
    }
}


; ══════════════════════════════════════════════
; TRAY
; ══════════════════════════════════════════════
A_TrayMenu.Delete()
A_TrayMenu.Add("Pokaż okno",   (*) => gui1.Show())
A_TrayMenu.Add("Start / Stop", (*) => ToggleMacro())
A_TrayMenu.Add()
A_TrayMenu.Add("Wyjście",      (*) => SafeExit())
TraySetIcon("shell32.dll", 24)
A_IconTip := APP_NAME

; ══════════════════════════════════════════════
; MENU STARTOWE
; ══════════════════════════════════════════════
guiMenu := Gui("+AlwaysOnTop -MaximizeBox", APP_NAME " — Wybór modułu")
guiMenu.BackColor := "0A0C12"
guiMenu.MarginX := 20
guiMenu.MarginY := 20

guiMenu.SetFont("s13 Bold cF1F5F9", "Segoe UI")
guiMenu.AddText("xm y20 w360 Center", "⚔  BOB")
guiMenu.SetFont("s8 c64748B", "Segoe UI")
guiMenu.AddText("xm y+4 w360 Center", "Wybierz moduł który chcesz uruchomić")
guiMenu.AddText("xm y+16 w360 h1 0x10", "")

guiMenu.SetFont("s10 Bold cF1F5F9", "Segoe UI")
guiMenu.AddText("xm y+16 w360", "🌀  BOB")
guiMenu.SetFont("s8 c94A3B8", "Segoe UI")
guiMenu.AddText("xm y+4 w360", "Automatyczne farmienie portali i wykrywanie Boba.")
guiMenu.AddText("xm y+2 w360", "Szansa na Boba: 1/7500")
guiMenu.SetFont("s9 Bold cF1F5F9", "Segoe UI")
btnPortal := guiMenu.AddButton("xm y+10 w360 h32", "▶   Uruchom BOB")

guiMenu.AddText("xm y+14 w360 h1 0x10", "")

guiMenu.SetFont("s10 Bold cF1F5F9", "Segoe UI")
guiMenu.AddText("xm y+14 w360", "🧱  Trap — Brick Master")
guiMenu.SetFont("s8 c94A3B8", "Segoe UI")
guiMenu.AddText("xm y+4 w360", "Automatyczne kładzenie 1000 cegieł (odznaka Brick Master).")
guiMenu.AddText("xm y+2 w360", "Cooldown: 5s  ·  Szac. czas: ~85 min")
guiMenu.SetFont("s9 Bold cF1F5F9", "Segoe UI")
btnTrap := guiMenu.AddButton("xm y+10 w360 h32", "▶   Uruchom Trap / Brick Master")

guiMenu.AddText("xm y+14 w360 h1 0x10", "")

guiMenu.SetFont("s10 Bold cF1F5F9", "Segoe UI")
guiMenu.AddText("xm y+14 w360", "🏗️  Obby Mastery — Place Parts")
guiMenu.SetFont("s8 c94A3B8", "Segoe UI")
guiMenu.AddText("xm y+4 w360", "Automatyczne kładzenie 2000 Obby parts (Quest 3 Mastery).")
guiMenu.AddText("xm y+2 w360", "Cooldown: 3s  ·  Szac. czas: ~100 min")
guiMenu.SetFont("s9 Bold cF1F5F9", "Segoe UI")
btnObby := guiMenu.AddButton("xm y+10 w360 h32", "▶   Uruchom Obby Mastery")

guiMenu.AddText("xm y+14 w360 h1 0x10", "")

guiMenu.SetFont("s10 Bold cF1F5F9", "Segoe UI")
guiMenu.AddText("xm y+14 w360", "⚡  Replica Bob — prosty klik")
guiMenu.SetFont("s8 c94A3B8", "Segoe UI")
guiMenu.AddText("xm y+4 w360", "Klika E co 14s (cooldown repliki) niezależnie od lagów.")
guiMenu.AddText("xm y+2 w360", "Szansa na Boba: 1/7500  ·  Cooldown: 14s")
guiMenu.SetFont("s9 Bold cF1F5F9", "Segoe UI")
btnReplica := guiMenu.AddButton("xm y+10 w360 h32", "▶   Uruchom Replica Bob")

guiMenu.AddText("xm y+14 w360 h1 0x10", "")

guiMenu.SetFont("s10 Bold cF1F5F9", "Segoe UI")
guiMenu.AddText("xm y+14 w360", "🖐  Manual Bob — ręczny respawn")
guiMenu.SetFont("s8 c94A3B8", "Segoe UI")
guiMenu.AddText("xm y+4 w360", "Naciśnij E aby wykonać sekwencję Esc+R+Enter (respawn).")
guiMenu.AddText("xm y+2 w360", "Szansa na Boba: 1/7500  ·  Klawisz: E")
guiMenu.SetFont("s9 Bold cF1F5F9", "Segoe UI")
btnManualBob := guiMenu.AddButton("xm y+10 w360 h32", "▶   Uruchom Manual Bob")

guiMenu.AddText("xm y+14 w360 h1 0x10", "")

guiMenu.SetFont("s10 Bold cF1F5F9", "Segoe UI")
guiMenu.AddText("xm y+14 w360", "💥  Critical Glove — auto klik")
guiMenu.SetFont("s8 c94A3B8", "Segoe UI")
guiMenu.AddText("xm y+4 w360", "PPM → Spacja + LPM (kryt. trafienie przez skok).")
guiMenu.AddText("xm y+2 w360", "Prawy przycisk myszy wyzwala combo Spacja+LPM")
guiMenu.SetFont("s9 Bold cF1F5F9", "Segoe UI")
btnCritGlove := guiMenu.AddButton("xm y+10 w360 h32", "▶   Uruchom Critical Glove")

guiMenu.AddText("xm y+14 w360 h1 0x10", "")
guiMenu.SetFont("s7 c334155", "Segoe UI")
guiMenu.AddText("xm y+10 w360 Center", "Klucz: " key "  ·  HWID: " SubStr(hwid,1,8) "…")

btnPortal.OnEvent("Click",    SelectPortal)
btnTrap.OnEvent("Click",      SelectTrap)
btnObby.OnEvent("Click",      SelectObby)
btnReplica.OnEvent("Click",   SelectReplica)
btnManualBob.OnEvent("Click", SelectManualBob)
btnCritGlove.OnEvent("Click", SelectCritGlove)
guiMenu.OnEvent("Close",      (*) => ExitApp())
guiMenu.Show("w400")

SelectPortal(*) {
    global activeModule, guiMenu
    activeModule := "portal"
    guiMenu.Destroy()
    BuildPortalGUI()
}

SelectTrap(*) {
    global activeModule, guiMenu
    activeModule := "trap"
    guiMenu.Destroy()
    BuildTrapGUI()
}

SelectObby(*) {
    global activeModule, guiMenu
    activeModule := "obby"
    guiMenu.Destroy()
    BuildObbyGUI()
}

SelectReplica(*) {
    global activeModule, guiMenu
    activeModule := "replica"
    guiMenu.Destroy()
    BuildReplicaGUI()
}

SelectManualBob(*) {
    global activeModule, guiMenu
    activeModule := "manualbob"
    guiMenu.Destroy()
    BuildManualBobGUI()
}

SelectCritGlove(*) {
    global activeModule, guiMenu
    activeModule := "critglove"
    guiMenu.Destroy()
    BuildCritGloveGUI()
}

; ══════════════════════════════════════════════
; HOTKEYS
; ══════════════════════════════════════════════
F6:: ToggleMacro()
F8:: SafeExit()
F9:: PanicStop()

ToggleMacro() {
    if running
        StopMacro()
    else
        StartMacro()
}

PanicStop() {
    SendInput "{a up}{d up}{s up}{w up}"
    StopMacro()
    MsgBox "PANIC STOP — klawisze zwolnione.", APP_NAME, 48
}

SafeExit() {
    if running
        StopMacro()
    SaveTotalData()
    ExitApp
}

SaveTotalData() {
    global activeModule, P_TotalFile, P_totalLoops, T_TotalFile, T_totalBricks
    if (activeModule = "portal") {
        try {
            if FileExist(P_TotalFile)
                FileDelete P_TotalFile
            FileAppend String(P_totalLoops), P_TotalFile
        }
    } else if (activeModule = "trap") {
        try {
            if FileExist(T_TotalFile)
                FileDelete T_TotalFile
            FileAppend String(T_totalBricks), T_TotalFile
        }
    } else if (activeModule = "obby") {
        try {
            if FileExist(O_TotalFile)
                FileDelete O_TotalFile
            FileAppend String(O_totalParts), O_TotalFile
        }
    } else if (activeModule = "replica") {
        try {
            if FileExist(R_TotalFile)
                FileDelete R_TotalFile
            FileAppend String(R_totalClicks), R_TotalFile
        }
    } else if (activeModule = "manualbob") {
        try {
            if FileExist(MB_TotalFile)
                FileDelete MB_TotalFile
            FileAppend String(MB_totalClicks), MB_TotalFile
        }
    } else if (activeModule = "critglove") {
        try {
            if FileExist(CG_TotalFile)
                FileDelete CG_TotalFile
            FileAppend String(CG_totalClicks), CG_TotalFile
        }
    }
}

; ══════════════════════════════════════════════
; START / STOP
; ══════════════════════════════════════════════
StartMacro(*) {
    global running, paused, sessionStart, activeModule
    global P_loopCount, P_bobHits, T_brickCount
    if running
        return
    running      := true
    paused       := false
    sessionStart := A_TickCount
    if (activeModule = "portal") {
        P_loopCount := 0
        P_bobHits   := 0
        SetTimer(PortalLoop,  10)
        SetTimer(UpdateTimer, 1000)
        SetTimer(CheckGame, 2000)
    } else if (activeModule = "trap") {
        T_brickCount := 0
        SetTimer(TrapLoop,    T_BRICK_CD)
        SetTimer(UpdateTimer, 1000)
        SetTimer(CheckGame, 2000)
    } else if (activeModule = "obby") {
        O_partCount  := 0
        SetTimer(ObbyLoop,    O_PART_CD)
        SetTimer(UpdateTimer, 1000)
        SetTimer(CheckGame, 2000)
    } else if (activeModule = "replica") {
        R_clickCount := 0
        R_bobHits    := 0
        R_lastTick   := A_TickCount
        R_loopTimer  := 0
        cd := SafeNum(IniRead(R_IniFile, "Zaawansowane", "CD", "14000"), 14000)
        SetTimer(ReplicaLoop,  cd)
        SetTimer(UpdateTimer,  1000)
        SetTimer(CheckGame,  2000)
        ReplicaLoop()
    } else if (activeModule = "manualbob") {
        MB_clickCount := 0
        MB_bobHits    := 0
        MB_hotkey     := IniRead(MB_IniFile, "Zaawansowane", "Hotkey", "e")
        SetTimer(UpdateTimer, 1000)
        SetTimer(CheckGame, 2000)
        Hotkey MB_hotkey, ManualBobTrigger, "On"
    } else if (activeModule = "critglove") {
        CG_clickCount := 0
        CG_hotkey     := IniRead(CG_IniFile, "Zaawansowane", "Hotkey", "RButton")
        SetTimer(UpdateTimer, 1000)
        SetTimer(CheckGame, 2000)
        Hotkey CG_hotkey, CritGloveTrigger, "On"
    }
    UpdateStatus("DZIAŁA", "4ADE80")
    UpdateTrayTip()
}

StopMacro(*) {
    global running, paused, activeModule
    if !running
        return
    running := false
    paused  := false
    SetTimer(PortalLoop,  0)
    SetTimer(TrapLoop,    0)
    SetTimer(ObbyLoop,    0)
    SetTimer(ReplicaLoop, 0)
    SetTimer(UpdateTimer, 0)
    SetTimer(CheckGame, 0)
    try Hotkey MB_hotkey, ManualBobTrigger, "Off"
    try Hotkey CG_hotkey, CritGloveTrigger, "Off"
    UpdateStatus("ZATRZYMANE", "F87171")
    UpdateTrayTip()
    SaveHistory()
    SaveTotalData()
}

UpdateStatus(txt, col) {
    global statusText
    try {
        statusText.Text := "● " txt
        statusText.SetFont("c" col)
    }
}

UpdateTrayTip() {
    global running, activeModule, P_loopCount, P_bobHits, T_brickCount, T_BRICK_GOAL
    if (activeModule = "portal")
        A_IconTip := "BOB | " (running?"DZIAŁA":"STOP") " | Pętle: " P_loopCount " | Boby: " P_bobHits
    else if (activeModule = "replica")
        A_IconTip := "Replica Bob | " (running?"DZIAŁA":"STOP") " | Kliki: " R_clickCount " | Boby: " R_bobHits
    else if (activeModule = "manualbob")
        A_IconTip := "Manual Bob | " (running?"DZIAŁA":"STOP") " | Kliki: " MB_clickCount " | Boby: " MB_bobHits
    else if (activeModule = "critglove")
        A_IconTip := "Critical Glove | " (running?"DZIAŁA":"STOP") " | Kliki: " CG_clickCount
    else
        A_IconTip := "Trap | " (running?"DZIAŁA":"STOP") " | Cegły: " T_brickCount "/" T_BRICK_GOAL
}

; ══════════════════════════════════════════════
; AUTO-PAUZA
; ══════════════════════════════════════════════
CheckGame() {
    global running, paused, activeModule, gameText, P_IniFile, T_IniFile, T_BRICK_CD
    ini := (activeModule = "portal") ? P_IniFile
        : (activeModule = "replica")   ? R_IniFile
        : (activeModule = "manualbob") ? MB_IniFile
        : (activeModule = "critglove") ? CG_IniFile
        : T_IniFile
    ap  := SafeNum(IniRead(ini, "Makro", "AutoPauza", "1"), 1)
    ok  := WinExist("ahk_exe RobloxPlayerBeta.exe") ? true : false
    try {
        gameText.Text := ok ? "Gra ✓" : "Gra ✗"
        gameText.SetFont(ok ? "c4ADE80" : "cF87171")
    }
    if !ap
        return
    if (running && !paused && !ok) {
        paused := true
        UpdateStatus("PAUZA", "FBBF24")
        SetTimer(PortalLoop,  0)
        SetTimer(TrapLoop,    0)
        SetTimer(ObbyLoop,    0)
        SetTimer(ReplicaLoop, 0)
        try Hotkey MB_hotkey, ManualBobTrigger, "Off"
        try Hotkey CG_hotkey, CritGloveTrigger, "Off"
    } else if (running && paused && ok) {
        paused := false
        UpdateStatus("DZIAŁA", "4ADE80")
        if (activeModule = "portal")
            SetTimer(PortalLoop, 10)
        else if (activeModule = "trap")
            SetTimer(TrapLoop,    T_BRICK_CD)
        else if (activeModule = "replica") {
            cd := SafeNum(IniRead(R_IniFile, "Zaawansowane", "CD", "14000"), 14000)
            SetTimer(ReplicaLoop, cd)
        } else if (activeModule = "manualbob")
            Hotkey MB_hotkey, ManualBobTrigger, "On"
        else if (activeModule = "critglove")
            Hotkey CG_hotkey, CritGloveTrigger, "On"
        else
            SetTimer(ObbyLoop,    O_PART_CD)
    }
}

; ══════════════════════════════════════════════
; TIMER TICKER
; ══════════════════════════════════════════════
UpdateTimer() {
    global running, sessionStart, activeModule
    if !running
        return
    elapsed := A_TickCount - sessionStart
    if (activeModule = "portal")
        UpdatePortalStats(elapsed)
    else if (activeModule = "trap")
        UpdateTrapStats(elapsed)
    else if (activeModule = "replica")
        UpdateReplicaStats(elapsed)
    else if (activeModule = "manualbob")
        UpdateManualBobStats(elapsed)
    else if (activeModule = "critglove")
        UpdateCritGloveStats(elapsed)
    else
        UpdateObbyStats(elapsed)
    UpdateTrayTip()
}

SaveHistory() {
    global activeModule, sessionStart
    global P_HistFile, P_loopCount, P_bobHits, P_BOB_DENOM
    global T_HistFile, T_brickCount, T_totalBricks
    dt := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    t  := FormatTime2(A_TickCount - sessionStart)
    if (activeModule = "portal") {
        est := Format("{:.3f}", P_loopCount * (1/P_BOB_DENOM))
        FileAppend dt " | Pętle: " P_loopCount " | Boby: " P_bobHits " | Szac.: " est " | Czas: " t "`n", P_HistFile
    } else if (activeModule = "trap") {
        FileAppend dt " | Cegły: " T_brickCount " | Łącznie: " T_totalBricks " | Czas: " t "`n", T_HistFile
    } else if (activeModule = "obby") {
        FileAppend dt " | Części: " O_partCount " | Łącznie: " O_totalParts " | Czas: " t "`n", O_HistFile
    } else if (activeModule = "replica") {
        est := Format("{:.3f}", R_clickCount * (1/R_BOB_DENOM))
        FileAppend dt " | Kliki: " R_clickCount " | Boby: " R_bobHits " | Szac.: " est " | Czas: " t "`n", R_HistFile
    } else if (activeModule = "manualbob") {
        est := Format("{:.3f}", MB_clickCount * (1/MB_BOB_DENOM))
        FileAppend dt " | Kliki: " MB_clickCount " | Boby: " MB_bobHits " | Szac.: " est " | Czas: " t "`n", MB_HistFile
    } else if (activeModule = "critglove") {
        FileAppend dt " | Kliki: " CG_clickCount " | Łącznie: " CG_totalClicks " | Czas: " t "`n", CG_HistFile
    }
}

; ══════════════════════════════════════════════════════════════════
; MODUŁ PORTAL — GUI
; ══════════════════════════════════════════════════════════════════
BuildPortalGUI() {
    global gui1, statusText, gameText
    global P_loopText, P_bobText, P_estText, P_timerText, P_lphText, P_totalText
    global P_totalLoops, P_BOB_DENOM

    W := 300
    gui1 := Gui("+AlwaysOnTop -MaximizeBox", "SBMM — BOB Portal " APP_VERSION)
    gui1.BackColor := "0A0C12"
    gui1.MarginX := 16
    gui1.MarginY := 14
    gui1.OnEvent("Close", (*) => gui1.Hide())

    gui1.SetFont("s12 Bold cF1F5F9", "Segoe UI")
    gui1.AddText("xm y14 w" W-32 " Center", "🌀  BOB")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gui1.AddText("xm y+2 w" W-32 " Center", APP_NAME "  ·  " APP_VERSION)
    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    gui1.SetFont("s9 Bold cF87171", "Segoe UI")
    statusText  := gui1.AddText("xm y+8 w" (W-32)//2, "● ZATRZYMANE")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gameText  := gui1.AddText("x+0 yp w" (W-32)//2 " Right", "Gra —")
    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    LW := 155 , VW := W-32-LW-2

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+10 w" LW, "Pętle sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    P_loopText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Znalezione Boby")
    gui1.SetFont("s8 Bold cA78BFA", "Segoe UI")
    P_bobText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Szacowane Boby")
    gui1.SetFont("s8 Bold c4ADE80", "Segoe UI")
    P_estText := gui1.AddText("x+2 yp w" VW " Right", "0.000")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Czas sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    P_timerText := gui1.AddText("x+2 yp w" VW " Right", "00:00:00")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Pętle/godz.")
    gui1.SetFont("s8 c6366F1", "Segoe UI")
    P_lphText := gui1.AddText("x+2 yp w" VW " Right", "—")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Pętle łącznie")
    gui1.SetFont("s8 c818CF8", "Segoe UI")
    P_totalText := gui1.AddText("x+2 yp w" VW " Right", FormatLoops(P_totalLoops))

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Szansa na Boba")
    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("x+2 yp w" VW " Right", "1/" P_BOB_DENOM)

    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    BW := (W-32-8)//2
    gui1.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    sBtn := gui1.AddButton("xm y+10 w" BW " h30", "▶  Start")
    eBtn := gui1.AddButton("x+8 yp w" BW " h30",  "■  Stop")
    gui1.SetFont("s8 c64748B", "Segoe UI")
    tBtn := gui1.AddButton("xm y+6 w" BW " h24", "⚙  Ustawienia")
    hBtn := gui1.AddButton("x+8 yp w" BW " h24", "📋  Historia")
    gui1.SetFont("s7 c334155", "Segoe UI")
    gui1.AddText("xm y+10 w" W-32 " Center", "F6 start/stop   F9 panic   F8 wyjście")

    sBtn.OnEvent("Click", StartMacro)
    eBtn.OnEvent("Click", StopMacro)
    tBtn.OnEvent("Click", OpenPortalSettings)
    hBtn.OnEvent("Click", OpenPortalHistory)

    gui1.Show("w" W)
}

UpdatePortalStats(elapsed) {
    global P_loopCount, P_bobHits, P_totalLoops, P_BOB_DENOM, sessionStart
    global P_loopText, P_bobText, P_estText, P_timerText, P_lphText, P_totalText
    P_loopText.Text  := FormatLoops(P_loopCount)
    P_bobText.Text   := String(P_bobHits)
    P_estText.Text   := Format("{:.3f}", P_loopCount * (1/P_BOB_DENOM))
    P_timerText.Text := FormatTime2(elapsed)
    P_totalText.Text := FormatLoops(P_totalLoops)
    h := elapsed / 3600000
    P_lphText.Text := (h > 0.001) ? Format("{:.0f}", P_loopCount/h) : "—"
}

; ── Portal: Ustawienia — wszystkie zmienne ────
global P_mI, P_sI, P_oI, P_siI, P_apC, P_dzC
global P_adv_ClickSleep, P_adv_PostClickSleep
global P_adv_CloseX_SleepA, P_adv_CloseX_SleepB
global P_adv_GridOffset, P_adv_PostMoveSleep
global P_adv_EscSleep, P_adv_RSleep, P_adv_EnterSleep
global P_adv_PortalX, P_adv_PortalY
global P_adv_CloseX_X, P_adv_CloseX_Y
global P_adv_BlueBaseX, P_adv_BlueBaseY
global P_adv_RedBaseX,  P_adv_RedBaseY
global P_adv_PreMoveSleep, P_adv_InteractSleep, P_adv_InteractSleep2
global P_adv_GoToWTime, P_adv_GoToDTime, P_adv_GoToATime, P_adv_GoToSleep
global P_wh_URL, P_wh_CD

OpenPortalSettings(*) {
    global P_IniFile, gui1
    global P_mI, P_sI, P_oI, P_siI, P_apC, P_dzC
    global P_adv_PortalX, P_adv_PortalY
    global P_adv_GoToWTime, P_adv_GoToDTime, P_adv_GoToATime, P_adv_GoToSleep
    global P_wh_URL, P_wh_CD

    LW := 185
    VW := 340 - LW - 8

    gsP := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Ustawienia — BOB")
    gsP.BackColor := "0A0C12"
    gsP.MarginX := 16
    gsP.MarginY := 10

    gsP.SetFont("s10 Bold cF1F5F9", "Segoe UI")
    gsP.AddText("xm y10 w340 Center", "Ustawienia — BOB")

    ; OPCJE
    gsP.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsP.AddText("xm y+10 w340", "OPCJE")
    gsP.AddText("xm y+3 w340 h1 0x10", "")
    gsP.SetFont("s8 c64748B", "Segoe UI")
    P_apC := gsP.AddCheckbox("xm y+6 w340 c94A3B8", "Auto-pauza gdy gra nieaktywna")
    P_apC.Value := SafeNum(IniRead(P_IniFile, "Makro", "AutoPauza", "1"), 1)
    P_dzC := gsP.AddCheckbox("xm y+4 w340 c94A3B8", "Dzwiek przy znalezieniu Boba")
    P_dzC.Value := SafeNum(IniRead(P_IniFile, "Makro", "DzwiekBob", "1"), 1)

    ; PODSTAWOWE
    gsP.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsP.AddText("xm y+10 w340", "PODSTAWOWE")
    gsP.AddText("xm y+3 w340 h1 0x10", "")
    gsP.SetFont("s8 c64748B", "Segoe UI")
    gsP.AddText("xm y+4 w" LW, "Czas ruchu D/A (ms) [3000]:")
    P_mI := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Makro", "CzasRuchu", "3000"))
    gsP.AddText("xm y+4 w" LW, "Czas strafe S (ms) [1500]:")
    P_sI := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Makro", "CzasStrafe", "1500"))
    gsP.AddText("xm y+4 w" LW, "Offset klikania portalu (px) [10]:")
    P_oI := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Makro", "OffsetMax", "10"))
    gsP.AddText("xm y+4 w" LW, "Portal klik X (px) [956]:")
    P_adv_PortalX := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "PortalX", "956"))
    gsP.AddText("xm y+4 w" LW, "Portal klik Y (px) [982]:")
    P_adv_PortalY := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "PortalY", "982"))
    gsP.AddText("xm y+4 w" LW, "Co ile petli wysylac stats [100]:")
    P_siI := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Makro", "InterwalStatystyk", "100"))

    ; GO-TO-PORTAL
    gsP.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsP.AddText("xm y+10 w340", "GO-TO-PORTAL")
    gsP.AddText("xm y+3 w340 h1 0x10", "")
    gsP.SetFont("s8 c64748B", "Segoe UI")
    gsP.AddText("xm y+4 w" LW, "Czas W przed klik (ms) [0=off]:")
    P_adv_GoToWTime := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "GoToPortal", "WTime", "0"))
    gsP.AddText("xm y+4 w" LW, "Czas D do portalu (ms) [0=off]:")
    P_adv_GoToDTime := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "GoToPortal", "DTime", "0"))
    gsP.AddText("xm y+4 w" LW, "Czas A korekcja (ms) [0=off]:")
    P_adv_GoToATime := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "GoToPortal", "ATime", "0"))
    gsP.AddText("xm y+4 w" LW, "Sleep po dojsciu (ms) [0=off]:")
    P_adv_GoToSleep := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "GoToPortal", "Sleep", "0"))

    ; WEBHOOK STATYSTYK
    gsP.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsP.AddText("xm y+10 w340", "WEBHOOK STATYSTYK")
    gsP.AddText("xm y+3 w340 h1 0x10", "")
    gsP.SetFont("s8 c64748B", "Segoe UI")
    gsP.AddText("xm y+4 w" LW, "URL webhooka statystyk:")
    P_wh_URL := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Webhook", "URL", ""))
    gsP.AddText("xm y+4 w" LW, "Cooldown webhooka (ms) [3000]:")
    P_wh_CD := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Webhook", "Cooldown", "3000"))

    ; ZAAWANSOWANE — osobne okno
    gsP.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsP.AddText("xm y+10 w340", "ZAAWANSOWANE (timingowe)")
    gsP.AddText("xm y+3 w340 h1 0x10", "")
    gsP.SetFont("s8 c64748B", "Segoe UI")
    gsP.AddText("xm y+4 w340", "Sleep, koordynaty skanowania, progi kolorow portali.")
    gsP.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    advBtn := gsP.AddButton("xm y+6 w340 h26", ">> Otwórz zaawansowane ustawienia")
    advBtn.OnEvent("Click", (*) => OpenPortalAdvanced(gsP))

    ; DEBUGOWANIE
    gsP.SetFont("s7 Bold cF87171", "Segoe UI")
    gsP.AddText("xm y+10 w340", "DEBUGOWANIE")
    gsP.AddText("xm y+3 w340 h1 0x10", "")
    gsP.SetFont("s7 c94A3B8", "Segoe UI")
    gsP.AddText("xm y+3 w340", "Krytyczne — bledna wartosc zniszczy makro.")
    gsP.SetFont("s8 c64748B", "Segoe UI")
    gsP.AddText("xm y+6 w" LW, "Kod PIN:")
    dbPinI := gsP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200 Password")
    gsP.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    dbBtn := gsP.AddButton("xm y+6 w340 h26", "Odblokuj sekcje debugowania")
    dbBtn.OnEvent("Click", (*) => OpenPortalDebug(gsP, dbPinI.Value))

    gsP.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    svBtn := gsP.AddButton("xm y+10 w340 h30", "Zapisz ustawienia")
    svBtn.OnEvent("Click", SavePortalSettings)
    gsP.Show("w372")
}

OpenPortalAdvanced(parentGui) {
    global P_IniFile
    global P_adv_ClickSleep, P_adv_PostClickSleep
    global P_adv_CloseX_SleepA, P_adv_CloseX_SleepB
    global P_adv_GridOffset, P_adv_PostMoveSleep
    global P_adv_EscSleep, P_adv_RSleep, P_adv_EnterSleep
    global P_adv_CloseX_X, P_adv_CloseX_Y
    global P_adv_BlueBaseX, P_adv_BlueBaseY
    global P_adv_RedBaseX,  P_adv_RedBaseY
    global P_adv_PreMoveSleep, P_adv_InteractSleep, P_adv_InteractSleep2

    LW := 185
    VW := 340 - LW - 8
    gaP := Gui("+AlwaysOnTop +Owner" parentGui.Hwnd, "Zaawansowane — BOB")
    gaP.BackColor := "0A0C12"
    gaP.MarginX := 16
    gaP.MarginY := 10

    gaP.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    gaP.AddText("xm y10 w340 Center", "Zaawansowane — BOB")
    gaP.SetFont("s7 c94A3B8", "Segoe UI")
    gaP.AddText("xm y+4 w340 Center", "Zapis przez glowne okno ustawien -> Zapisz.")

    gaP.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gaP.AddText("xm y+10 w340", "  Ruch")
    gaP.SetFont("s8 c64748B", "Segoe UI")
    gaP.AddText("xm y+4 w" LW, "Sleep przed ruchem (ms) [0]:")
    P_adv_PreMoveSleep := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "PreMoveSleep", "0"))
    gaP.AddText("xm y+4 w" LW, "Sleep po ruchu (ms) [150]:")
    P_adv_PostMoveSleep := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "PostMoveSleep", "150"))

    gaP.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gaP.AddText("xm y+8 w340", "  Klikanie")
    gaP.SetFont("s8 c64748B", "Segoe UI")
    gaP.AddText("xm y+4 w" LW, "Sleep miedzy klik (ms) [80]:")
    P_adv_ClickSleep := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "ClickSleep", "80"))
    gaP.AddText("xm y+4 w" LW, "Sleep po 3x klik (ms) [500]:")
    P_adv_PostClickSleep := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "PostClickSleep", "500"))

    gaP.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gaP.AddText("xm y+8 w340", "  Zamkniecie X")
    gaP.SetFont("s8 c64748B", "Segoe UI")
    gaP.AddText("xm y+4 w" LW, "X przycisku X (px) [1395]:")
    P_adv_CloseX_X := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "CloseX_X", "1395"))
    gaP.AddText("xm y+4 w" LW, "Y przycisku X (px) [242]:")
    P_adv_CloseX_Y := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "CloseX_Y", "242"))
    gaP.AddText("xm y+4 w" LW, "Sleep przed klik X (ms) [50]:")
    P_adv_CloseX_SleepA := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "CloseXSleepA", "50"))
    gaP.AddText("xm y+4 w" LW, "Sleep po klik X (ms) [200]:")
    P_adv_CloseX_SleepB := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "CloseXSleepB", "200"))

    gaP.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gaP.AddText("xm y+8 w340", "  Skanowanie portali")
    gaP.SetFont("s8 c64748B", "Segoe UI")
    gaP.AddText("xm y+4 w" LW, "Offset siatki (px) [6]:")
    P_adv_GridOffset := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "GridOffset", "6"))
    gaP.AddText("xm y+4 w" LW, "Niebieski base X [687]:")
    P_adv_BlueBaseX := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "BlueBaseX", "687"))
    gaP.AddText("xm y+4 w" LW, "Niebieski base Y [588]:")
    P_adv_BlueBaseY := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "BlueBaseY", "588"))
    gaP.AddText("xm y+4 w" LW, "Czerwony base X [1247]:")
    P_adv_RedBaseX := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "RedBaseX", "1247"))
    gaP.AddText("xm y+4 w" LW, "Czerwony base Y [646]:")
    P_adv_RedBaseY := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "RedBaseY", "646"))

    gaP.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gaP.AddText("xm y+8 w340", "  Interakcja i reset")
    gaP.SetFont("s8 c64748B", "Segoe UI")
    gaP.AddText("xm y+4 w" LW, "Sleep przed E (ms) [150]:")
    P_adv_InteractSleep := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "InteractSleep", "150"))
    gaP.AddText("xm y+4 w" LW, "Sleep po E (ms) [100]:")
    P_adv_InteractSleep2 := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "InteractSleep2", "100"))
    gaP.AddText("xm y+4 w" LW, "Sleep po Esc (ms) [100]:")
    P_adv_EscSleep := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "EscSleep", "100"))
    gaP.AddText("xm y+4 w" LW, "Sleep po R (ms) [100]:")
    P_adv_RSleep := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "RSleep", "100"))
    gaP.AddText("xm y+4 w" LW, "Sleep po Enter (ms) [5000]:")
    P_adv_EnterSleep := gaP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Zaawansowane", "EnterSleep", "5000"))

    gaP.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    gaP.AddButton("xm y+12 w340 h26", "Zamknij").OnEvent("Click", (*) => gaP.Destroy())
    gaP.Show("w372")
}


OpenPortalDebug(parentGui, enteredPin) {
    global debugCode, P_IniFile, webhookHWID, jsonURL, P_BOB_DENOM
    if (enteredPin != debugCode) {
        MsgBox "Nieprawidlowy kod PIN.", "Debugowanie", 48
        return
    }
    gdP := Gui("+AlwaysOnTop +Owner" parentGui.Hwnd, "Debugowanie — BOB")
    gdP.BackColor := "0A0C12"
    gdP.MarginX := 16
    gdP.MarginY := 10
    LW := 185
    VW := 340 - LW - 8

    gdP.SetFont("s9 Bold cF87171", "Segoe UI")
    gdP.AddText("xm y10 w340 Center", "SEKCJA DEBUGOWANIA")
    gdP.SetFont("s7 c94A3B8", "Segoe UI")
    gdP.AddText("xm y+4 w340 Center", "UWAGA: bledna zmiana = makro przestanie dzialac!")
    gdP.AddText("xm y+8 w340 h1 0x10", "")

    ; Licencja i HWID
    gdP.SetFont("s7 Bold cF87171", "Segoe UI")
    gdP.AddText("xm y+8 w340", "  Licencja i HWID")
    gdP.SetFont("s8 c64748B", "Segoe UI")
    gdP.AddText("xm y+4 w" LW, "URL JSON licencji:")
    dbJsonI := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", jsonURL)
    gdP.AddText("xm y+4 w" LW, "Webhook HWID (rejestracja):")
    dbWHI := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", webhookHWID)

    ; Webhook statystyk — przeniesiony do głównych ustawień
    gdP.SetFont("s7 Bold cF87171", "Segoe UI")
    gdP.AddText("xm y+8 w340", "  Webhook (progi / Bob / licencja)")
    gdP.SetFont("s7 c94A3B8", "Segoe UI")
    gdP.AddText("xm y+3 w340", "URL i cooldown webhooka sa w glownych ustawieniach.")
    gdP.SetFont("s8 c64748B", "Segoe UI")
    gdP.AddText("xm y+4 w" LW, "Cooldown webhooka (ms) [3000]:")
    dbWHCD := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Webhook", "Cooldown", "3000"))

    ; Progi kolorow
    gdP.SetFont("s7 Bold cF87171", "Segoe UI")
    gdP.AddText("xm y+8 w340", "  Progi kolorow skanowania (krytyczne!)")
    gdP.SetFont("s8 c64748B", "Segoe UI")
    gdP.AddText("xm y+4 w" LW, "Prog B niebieskiego (min) [200]:")
    dbBBmin := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Debug", "BlueB_min", "200"))
    gdP.AddText("xm y+4 w" LW, "Prog R/G niebieskiego (max) [50]:")
    dbBRmax := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Debug", "BlueRG_max", "50"))
    gdP.AddText("xm y+4 w" LW, "Prog R czerwonego (min) [200]:")
    dbRRmin := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Debug", "RedR_min", "200"))
    gdP.AddText("xm y+4 w" LW, "Prog B/G czerwonego (max) [50]:")
    dbRBmax := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Debug", "RedBG_max", "50"))
    gdP.AddText("xm y+4 w" LW, "Min. trafien skanowania (1-9) [3]:")
    dbScanHits := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(P_IniFile, "Debug", "ScanHits", "3"))

    ; Szansa na Boba
    gdP.SetFont("s7 Bold cF87171", "Segoe UI")
    gdP.AddText("xm y+8 w340", "  Szansa na Boba")
    gdP.SetFont("s8 c64748B", "Segoe UI")
    gdP.AddText("xm y+4 w" LW, "Mianownik szansy (1/X) [7500]:")
    dbBobDenom := gdP.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", String(P_BOB_DENOM))

    gdP.SetFont("s9 Bold cF87171", "Segoe UI")
    svDbP := gdP.AddButton("xm y+12 w340 h28", "Zapisz ustawienia debugowania")
    svDbP.OnEvent("Click", (*) => SavePortalDebug(
        dbJsonI.Value, dbWHI.Value, dbWHCD.Value,
        dbBBmin.Value, dbBRmax.Value, dbRRmin.Value, dbRBmax.Value,
        dbScanHits.Value, dbBobDenom.Value
    ))
    gdP.SetFont("s8 c64748B", "Segoe UI")
    gdP.AddButton("xm y+5 w340 h24", "Zamknij").OnEvent("Click", (*) => gdP.Destroy())
    gdP.Show("w372")
}

SavePortalDebug(newJson, newWH, newWHCD, newBBmin, newBRmax, newRRmin, newRBmax, newScanHits, newBobDenom) {
    global jsonURL, webhookHWID, P_IniFile, P_webhook, P_whCooldown, P_BOB_DENOM
    jsonURL      := newJson
    webhookHWID  := newWH
    P_whCooldown := SafeNum(newWHCD, 3000)
    P_BOB_DENOM  := SafeNum(newBobDenom, 7500)
    IniWrite newWHCD, P_IniFile, "Webhook", "Cooldown"
    IniWrite newBBmin,    P_IniFile, "Debug",   "BlueB_min"
    IniWrite newBRmax,    P_IniFile, "Debug",   "BlueRG_max"
    IniWrite newRRmin,    P_IniFile, "Debug",   "RedR_min"
    IniWrite newRBmax,    P_IniFile, "Debug",   "RedBG_max"
    IniWrite newScanHits, P_IniFile, "Debug",   "ScanHits"
    IniWrite newBobDenom, P_IniFile, "Debug",   "BobDenom"
    MsgBox "Ustawienia debugowania zapisane.", "Debugowanie", 64
}

SavePortalSettings(*) {
    global P_IniFile, portalX, portalY
    global P_mI, P_sI, P_oI, P_siI, P_apC, P_dzC
    global P_adv_ClickSleep, P_adv_PostClickSleep
    global P_adv_CloseX_SleepA, P_adv_CloseX_SleepB
    global P_adv_GridOffset, P_adv_PostMoveSleep
    global P_adv_EscSleep, P_adv_RSleep, P_adv_EnterSleep
    global P_adv_PortalX, P_adv_PortalY
    global P_adv_CloseX_X, P_adv_CloseX_Y
    global P_adv_BlueBaseX, P_adv_BlueBaseY
    global P_adv_RedBaseX,  P_adv_RedBaseY
    global P_adv_PreMoveSleep, P_adv_InteractSleep, P_adv_InteractSleep2
    IniWrite P_mI.Value,                P_IniFile, "Makro",        "CzasRuchu"
    IniWrite P_sI.Value,                P_IniFile, "Makro",        "CzasStrafe"
    IniWrite P_oI.Value,                P_IniFile, "Makro",        "OffsetMax"
    IniWrite P_siI.Value,               P_IniFile, "Makro",        "InterwalStatystyk"
    IniWrite P_apC.Value,               P_IniFile, "Makro",        "AutoPauza"
    IniWrite P_dzC.Value,               P_IniFile, "Makro",        "DzwiekBob"
    IniWrite P_adv_ClickSleep.Value,    P_IniFile, "Zaawansowane", "ClickSleep"
    IniWrite P_adv_PostClickSleep.Value,P_IniFile, "Zaawansowane", "PostClickSleep"
    IniWrite P_adv_CloseX_SleepA.Value, P_IniFile, "Zaawansowane", "CloseXSleepA"
    IniWrite P_adv_CloseX_SleepB.Value, P_IniFile, "Zaawansowane", "CloseXSleepB"
    IniWrite P_adv_GridOffset.Value,    P_IniFile, "Zaawansowane", "GridOffset"
    IniWrite P_adv_PreMoveSleep.Value,  P_IniFile, "Zaawansowane", "PreMoveSleep"
    IniWrite P_adv_PostMoveSleep.Value, P_IniFile, "Zaawansowane", "PostMoveSleep"
    IniWrite P_adv_EscSleep.Value,      P_IniFile, "Zaawansowane", "EscSleep"
    IniWrite P_adv_RSleep.Value,        P_IniFile, "Zaawansowane", "RSleep"
    IniWrite P_adv_EnterSleep.Value,    P_IniFile, "Zaawansowane", "EnterSleep"
    IniWrite P_adv_InteractSleep.Value, P_IniFile, "Zaawansowane", "InteractSleep"
    IniWrite P_adv_InteractSleep2.Value,P_IniFile, "Zaawansowane", "InteractSleep2"
    IniWrite P_adv_PortalX.Value,       P_IniFile, "Zaawansowane", "PortalX"
    IniWrite P_adv_PortalY.Value,       P_IniFile, "Zaawansowane", "PortalY"
    IniWrite P_adv_CloseX_X.Value,      P_IniFile, "Zaawansowane", "CloseX_X"
    IniWrite P_adv_CloseX_Y.Value,      P_IniFile, "Zaawansowane", "CloseX_Y"
    IniWrite P_adv_BlueBaseX.Value,     P_IniFile, "Zaawansowane", "BlueBaseX"
    IniWrite P_adv_BlueBaseY.Value,     P_IniFile, "Zaawansowane", "BlueBaseY"
    IniWrite P_adv_RedBaseX.Value,      P_IniFile, "Zaawansowane", "RedBaseX"
    IniWrite P_adv_RedBaseY.Value,      P_IniFile, "Zaawansowane", "RedBaseY"
    portalX := SafeNum(P_adv_PortalX.Value, 956)
    portalY := SafeNum(P_adv_PortalY.Value, 982)
    IniWrite P_adv_GoToWTime.Value, P_IniFile, "GoToPortal", "WTime"
    IniWrite P_adv_GoToDTime.Value, P_IniFile, "GoToPortal", "DTime"
    IniWrite P_adv_GoToATime.Value, P_IniFile, "GoToPortal", "ATime"
    IniWrite P_adv_GoToSleep.Value, P_IniFile, "GoToPortal", "Sleep"
    IniWrite P_wh_URL.Value,        P_IniFile, "Webhook", "URL"
    IniWrite P_wh_CD.Value,         P_IniFile, "Webhook", "Cooldown"
    P_webhook    := P_wh_URL.Value
    P_whCooldown := SafeNum(P_wh_CD.Value, 3000)
    MsgBox "Ustawienia zapisane!", APP_NAME, 64
}

OpenPortalHistory(*) {
    global P_HistFile
    if !FileExist(P_HistFile) {
        MsgBox "Brak historii.", APP_NAME, 64
        return
    }
    content := FileRead(P_HistFile)
    ghP := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Historia — BOB")
    ghP.BackColor := "0A0C12"
    ghP.MarginX := 14
    ghP.MarginY := 14
    ghP.SetFont("s8 cF1F5F9", "Segoe UI")
    eP := ghP.AddEdit("xm y14 w540 h300 ReadOnly Background12151F cF1F5F9 -E0x200", content)
    ghP.SetFont("s8 c64748B", "Segoe UI")
    c1 := ghP.AddButton("xm y+8 w265 h24", "🗑   Wyczyść")
    c2 := ghP.AddButton("x+10 yp w265 h24", "✕   Zamknij")
    c1.OnEvent("Click", (*) => (FileDelete(P_HistFile), eP.Value := "", MsgBox("Wyczyszczono.", APP_NAME, 64)))
    c2.OnEvent("Click", (*) => ghP.Destroy())
    ghP.Show("w568")
}

; ══════════════════════════════════════════════════════════════════
; MODUŁ TRAP — GUI
; ══════════════════════════════════════════════════════════════════
BuildTrapGUI() {
    global gui1, statusText, gameText
    global T_brickText, T_totalText, T_timerText, T_bphText, T_etaText
    global T_progressText, T_progressBar
    global T_totalBricks, T_BRICK_GOAL

    W := 300
    gui1 := Gui("+AlwaysOnTop -MaximizeBox", "Trap / Brick Master — " APP_VERSION)
    gui1.BackColor := "0A0C12"
    gui1.MarginX := 16
    gui1.MarginY := 14
    gui1.OnEvent("Close", (*) => gui1.Hide())

    gui1.SetFont("s12 Bold cF1F5F9", "Segoe UI")
    gui1.AddText("xm y14 w" W-32 " Center", "🧱  Trap — Brick Master")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gui1.AddText("xm y+2 w" W-32 " Center", APP_NAME "  ·  " APP_VERSION)
    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    gui1.SetFont("s9 Bold cF87171", "Segoe UI")
    statusText := gui1.AddText("xm y+8 w" (W-32)//2, "● ZATRZYMANE")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gameText := gui1.AddText("x+0 yp w" (W-32)//2 " Right", "Gra —")
    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    ; Pasek postępu
    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+10 w" W-32, "Postęp do Brick Master:")
    gui1.SetFont("s9 Bold cFBBF24", "Segoe UI")
    T_progressText := gui1.AddText("xm y+4 w" W-32 " Center", "0 / 1000  (0%)")
    T_progressBar  := gui1.AddProgress("xm y+4 w" W-32 " h14 Background1C2030 cFBBF24", 0)
    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    LW := 155 , VW := W-32-LW-2

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+10 w" LW, "Cegły (sesja)")
    gui1.SetFont("s8 Bold cFBBF24", "Segoe UI")
    T_brickText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Cegły łącznie")
    gui1.SetFont("s8 c818CF8", "Segoe UI")
    T_totalText := gui1.AddText("x+2 yp w" VW " Right", FormatLoops(T_totalBricks))

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Czas sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    T_timerText := gui1.AddText("x+2 yp w" VW " Right", "00:00:00")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Cegły/godz.")
    gui1.SetFont("s8 c6366F1", "Segoe UI")
    T_bphText := gui1.AddText("x+2 yp w" VW " Right", "—")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Szac. czas do celu")
    gui1.SetFont("s8 c94A3B8", "Segoe UI")
    T_etaText := gui1.AddText("x+2 yp w" VW " Right", "—")

    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    gui1.SetFont("s7 c4A5568", "Segoe UI")
    gui1.AddText("xm y+8 w" W-32, "ℹ  Klika E (zdolność Brick) co 5 sekund.")
    gui1.AddText("xm y+3 w" W-32, "    Cel: 1000 cegieł = odznaka Brick Master.")
    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    BW := (W-32-8)//2
    gui1.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    sBtn := gui1.AddButton("xm y+10 w" BW " h30", "▶  Start")
    eBtn := gui1.AddButton("x+8 yp w" BW " h30",  "■  Stop")
    gui1.SetFont("s8 c64748B", "Segoe UI")
    tBtn := gui1.AddButton("xm y+6 w" BW " h24", "⚙  Ustawienia")
    hBtn := gui1.AddButton("x+8 yp w" BW " h24", "📋  Historia")
    gui1.SetFont("s7 c334155", "Segoe UI")
    gui1.AddText("xm y+10 w" W-32 " Center", "F6 start/stop   F9 panic   F8 wyjście")

    sBtn.OnEvent("Click", StartMacro)
    eBtn.OnEvent("Click", StopMacro)
    tBtn.OnEvent("Click", OpenTrapSettings)
    hBtn.OnEvent("Click", OpenTrapHistory)

    gui1.Show("w" W)
}

UpdateTrapStats(elapsed) {
    global T_brickCount, T_totalBricks, T_BRICK_GOAL
    global T_brickText, T_totalText, T_timerText, T_bphText, T_etaText
    global T_progressText, T_progressBar
    pct := Min(100, Round(T_brickCount / T_BRICK_GOAL * 100))
    T_brickText.Text    := String(T_brickCount)
    T_totalText.Text    := FormatLoops(T_totalBricks)
    T_timerText.Text    := FormatTime2(elapsed)
    T_progressText.Text := T_brickCount " / " T_BRICK_GOAL "  (" pct "%)"
    T_progressBar.Value := pct
    h := elapsed / 3600000
    if (h > 0.001) {
        bph := Round(T_brickCount / h)
        T_bphText.Text := bph "/h"
        rem := T_BRICK_GOAL - T_brickCount
        if (bph > 0) {
            eta := Round(rem / bph * 60)
            T_etaText.Text := (eta > 60) ? Format("{:.1f}h", eta/60) : eta "min"
        } else T_etaText.Text := "—"
    } else {
        T_bphText.Text := "—"
        T_etaText.Text := "—"
    }
}

; ── Trap: Ustawienia ───────────────────────────
global T_wI, T_cI, T_siI2, T_apC2, T_dcC

; ── Trap advanced vars ──
global T_adv_ClickSleep, T_adv_PostClickSleep, T_adv_GoalLoops

; ── Trap advanced globals ──
global T_adv_ClickSleep, T_adv_BrickCD, T_adv_BrickGoal, T_adv_StatsInterval
global T_adv_GoalSoundDelay
global T_wh_URL, T_wh_CD

OpenTrapSettings(*) {
    global T_IniFile, gui1, T_apC2, T_dcC
    global T_adv_ClickSleep, T_adv_BrickCD, T_adv_BrickGoal, T_adv_StatsInterval
    global T_adv_GoalSoundDelay
    global T_wh_URL, T_wh_CD

    gsT := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Ustawienia — Trap/Brick")
    gsT.BackColor := "0A0C12"
    gsT.MarginX := 16
    gsT.MarginY := 10

    gsT.SetFont("s10 Bold cF1F5F9", "Segoe UI")
    gsT.AddText("xm y10 w340 Center", "Ustawienia — Trap / Brick Master")

    ; OPCJE
    gsT.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsT.AddText("xm y+10 w340", "OPCJE")
    gsT.AddText("xm y+3 w340 h1 0x10", "")
    gsT.SetFont("s8 c64748B", "Segoe UI")
    T_apC2 := gsT.AddCheckbox("xm y+6 w340 c94A3B8", "Auto-pauza gdy gra nieaktywna")
    T_apC2.Value := SafeNum(IniRead(T_IniFile, "Makro", "AutoPauza", "1"), 1)
    T_dcC := gsT.AddCheckbox("xm y+4 w340 c94A3B8", "Dzwiek po osiagnieciu celu")
    T_dcC.Value := SafeNum(IniRead(T_IniFile, "Makro", "DzwiekCel", "1"), 1)

    ; ZAAWANSOWANE
    gsT.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsT.AddText("xm y+12 w340", "ZAAWANSOWANE USTAWIENIA")
    gsT.AddText("xm y+3 w340 h1 0x10", "")
    gsT.SetFont("s7 c94A3B8", "Segoe UI")
    gsT.AddText("xm y+3 w340", "Zmiana moze destabilizowac makro. Domyslne wartosci w [...].")
    LW := 185
    VW := 340 - LW - 8
    gsT.SetFont("s8 c64748B", "Segoe UI")

    ; Timing
    gsT.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsT.AddText("xm y+8 w340", "  Timing")
    gsT.SetFont("s8 c64748B", "Segoe UI")
    gsT.AddText("xm y+4 w" LW, "Sleep po nacisnięciu E (ms) [100]:")
    T_adv_ClickSleep := gsT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(T_IniFile, "Zaawansowane", "ClickSleep", "100"))
    gsT.AddText("xm y+4 w" LW, "Cooldown Brick (ms) [5000]:")
    T_adv_BrickCD := gsT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(T_IniFile, "Zaawansowane", "BrickCD", "5000"))
    gsT.AddText("xm y+4 w" LW, "Sleep dzwiek po osiagnieciu celu (ms) [300]:")
    T_adv_GoalSoundDelay := gsT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(T_IniFile, "Zaawansowane", "GoalSoundDelay", "300"))

    ; Cel i statystyki
    gsT.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsT.AddText("xm y+8 w340", "  Cel i statystyki")
    gsT.SetFont("s8 c64748B", "Segoe UI")
    gsT.AddText("xm y+4 w" LW, "Cel (liczba cegiel) [1000]:")
    T_adv_BrickGoal := gsT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(T_IniFile, "Zaawansowane", "BrickGoal", "1000"))
    gsT.AddText("xm y+4 w" LW, "Co ile cegiel wysylac stats [50]:")
    T_adv_StatsInterval := gsT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(T_IniFile, "Makro", "InterwalStatystyk", "50"))

    ; WEBHOOK STATYSTYK
    gsT.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsT.AddText("xm y+12 w340", "WEBHOOK STATYSTYK")
    gsT.AddText("xm y+3 w340 h1 0x10", "")
    gsT.SetFont("s8 c64748B", "Segoe UI")
    gsT.AddText("xm y+4 w" LW, "URL webhooka statystyk:")
    T_wh_URL := gsT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(T_IniFile, "Webhook", "URL", ""))
    gsT.AddText("xm y+4 w" LW, "Cooldown webhooka (ms) [5000]:")
    T_wh_CD := gsT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(T_IniFile, "Webhook", "Cooldown", "5000"))

    ; DEBUGOWANIE
    gsT.SetFont("s7 Bold cF87171", "Segoe UI")
    gsT.AddText("xm y+12 w340", "DEBUGOWANIE")
    gsT.AddText("xm y+3 w340 h1 0x10", "")
    gsT.SetFont("s7 c94A3B8", "Segoe UI")
    gsT.AddText("xm y+3 w340", "Krytyczne zmienne — bledna wartosc zniszczy makro.")
    gsT.SetFont("s8 c64748B", "Segoe UI")
    gsT.AddText("xm y+6 w" LW, "Kod PIN:")
    dbPinT := gsT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200 Password")
    gsT.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    dbBtnT := gsT.AddButton("xm y+6 w340 h26", "Odblokuj sekcje debugowania")
    dbBtnT.OnEvent("Click", (*) => OpenTrapDebug(gsT, dbPinT.Value))

    gsT.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    svT := gsT.AddButton("xm y+10 w340 h30", "Zapisz ustawienia")
    svT.OnEvent("Click", SaveTrapSettings)
    gsT.Show("w372")
}

OpenTrapDebug(parentGui, enteredPin) {
    global debugCode, T_IniFile, webhookHWID, jsonURL
    if (enteredPin != debugCode) {
        MsgBox "Nieprawidlowy kod PIN.", "Debugowanie", 48
        return
    }
    gdT := Gui("+AlwaysOnTop +Owner" parentGui.Hwnd, "Debugowanie — Trap/Brick")
    gdT.BackColor := "0A0C12"
    gdT.MarginX := 16
    gdT.MarginY := 10
    LW := 185
    VW := 340 - LW - 8

    gdT.SetFont("s9 Bold cF87171", "Segoe UI")
    gdT.AddText("xm y10 w340 Center", "SEKCJA DEBUGOWANIA")
    gdT.SetFont("s7 c94A3B8", "Segoe UI")
    gdT.AddText("xm y+4 w340 Center", "UWAGA: bledna zmiana = makro przestanie dzialac!")
    gdT.AddText("xm y+8 w340 h1 0x10", "")

    ; Licencja i HWID
    gdT.SetFont("s7 Bold cF87171", "Segoe UI")
    gdT.AddText("xm y+8 w340", "  Licencja i HWID")
    gdT.SetFont("s8 c64748B", "Segoe UI")
    gdT.AddText("xm y+4 w" LW, "URL JSON licencji:")
    dbJsonT := gdT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", jsonURL)
    gdT.AddText("xm y+4 w" LW, "Webhook HWID (rejestracja):")
    dbWHT := gdT.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", webhookHWID)

    ; Webhook — przeniesiony do ustawien glownych

    gdT.SetFont("s9 Bold cF87171", "Segoe UI")
    svDbT := gdT.AddButton("xm y+14 w340 h28", "Zapisz ustawienia debugowania")
    svDbT.OnEvent("Click", (*) => SaveTrapDebug(dbJsonT.Value, dbWHT.Value))
    gdT.SetFont("s8 c64748B", "Segoe UI")
    gdT.AddButton("xm y+5 w340 h24", "Zamknij").OnEvent("Click", (*) => gdT.Destroy())
    gdT.Show("w372")
}

SaveTrapDebug(newJson, newWH) {
    global jsonURL, webhookHWID
    jsonURL     := newJson
    webhookHWID := newWH
    MsgBox "Ustawienia debugowania zapisane.", "Debugowanie", 64
}

SaveTrapSettings(*) {
    global T_IniFile, T_BRICK_GOAL, T_BRICK_CD
    global T_apC2, T_dcC
    global T_adv_ClickSleep, T_adv_BrickCD, T_adv_BrickGoal, T_adv_StatsInterval
    global T_adv_GoalSoundDelay
    IniWrite T_apC2.Value,              T_IniFile, "Makro",        "AutoPauza"
    IniWrite T_dcC.Value,               T_IniFile, "Makro",        "DzwiekCel"
    IniWrite T_adv_StatsInterval.Value, T_IniFile, "Makro",        "InterwalStatystyk"
    IniWrite T_adv_ClickSleep.Value,    T_IniFile, "Zaawansowane", "ClickSleep"
    IniWrite T_adv_BrickCD.Value,       T_IniFile, "Zaawansowane", "BrickCD"
    IniWrite T_adv_BrickGoal.Value,     T_IniFile, "Zaawansowane", "BrickGoal"
    IniWrite T_adv_GoalSoundDelay.Value,T_IniFile, "Zaawansowane", "GoalSoundDelay"
    T_BRICK_GOAL := SafeNum(T_adv_BrickGoal.Value, 1000)
    T_BRICK_CD   := SafeNum(T_adv_BrickCD.Value,   5000)
    IniWrite T_wh_URL.Value, T_IniFile, "Webhook", "URL"
    IniWrite T_wh_CD.Value,  T_IniFile, "Webhook", "Cooldown"
    T_webhook    := T_wh_URL.Value
    T_whCooldown := SafeNum(T_wh_CD.Value, 5000)
    MsgBox "Ustawienia zapisane!", APP_NAME, 64
}

OpenTrapHistory(*) {
    global T_HistFile
    if !FileExist(T_HistFile) {
        MsgBox "Brak historii.", APP_NAME, 64
        return
    }
    content := FileRead(T_HistFile)
    ghT := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Historia — Trap/Brick")
    ghT.BackColor := "0A0C12"
    ghT.MarginX := 14
    ghT.MarginY := 14
    ghT.SetFont("s8 cF1F5F9", "Segoe UI")
    eT := ghT.AddEdit("xm y14 w540 h300 ReadOnly Background12151F cF1F5F9 -E0x200", content)
    ghT.SetFont("s8 c64748B", "Segoe UI")
    c1 := ghT.AddButton("xm y+8 w265 h24", "🗑   Wyczyść")
    c2 := ghT.AddButton("x+10 yp w265 h24", "✕   Zamknij")
    c1.OnEvent("Click", (*) => (FileDelete(T_HistFile), eT.Value := "", MsgBox("Wyczyszczono.", APP_NAME, 64)))
    c2.OnEvent("Click", (*) => ghT.Destroy())
    ghT.Show("w568")
}

; ══════════════════════════════════════════════════════════════════
; PĘTLA PORTAL — CORE (niezmienione)
; ══════════════════════════════════════════════════════════════════
PortalLoop() {
    global running, paused, sessionStart
    global P_loopCount, P_bobHits, P_totalLoops, P_BOB_DENOM
    global P_webhook, P_whCooldown, P_lastWH
    global P_IniFile, hwid
    global portalX, portalY

    if (!running || paused)
        return
    SetTimer(PortalLoop, 0)

    moveTime       := SafeNum(IniRead(P_IniFile, "Makro",        "CzasRuchu",         "3000"), 3000)
    strafeTime     := SafeNum(IniRead(P_IniFile, "Makro",        "CzasStrafe",        "1500"), 1500)
    offsetMax      := SafeNum(IniRead(P_IniFile, "Makro",        "OffsetMax",         "10"),   10)
    statsInterval  := SafeNum(IniRead(P_IniFile, "Makro",        "InterwalStatystyk", "100"),  100)
    dzwiek         := SafeNum(IniRead(P_IniFile, "Makro",        "DzwiekBob",         "1"),    1)
    clickSleep     := SafeNum(IniRead(P_IniFile, "Zaawansowane", "ClickSleep",        "80"),   80)
    postClickSleep := SafeNum(IniRead(P_IniFile, "Zaawansowane", "PostClickSleep",    "500"),  500)
    closeX_X       := SafeNum(IniRead(P_IniFile, "Zaawansowane", "CloseX_X",         "1395"), 1395)
    closeX_Y       := SafeNum(IniRead(P_IniFile, "Zaawansowane", "CloseX_Y",         "242"),  242)
    closeXSleepA   := SafeNum(IniRead(P_IniFile, "Zaawansowane", "CloseXSleepA",     "50"),   50)
    closeXSleepB   := SafeNum(IniRead(P_IniFile, "Zaawansowane", "CloseXSleepB",     "200"),  200)
    gridOffset     := SafeNum(IniRead(P_IniFile, "Zaawansowane", "GridOffset",        "6"),    6)
    blueBaseX      := SafeNum(IniRead(P_IniFile, "Zaawansowane", "BlueBaseX",        "687"),  687)
    blueBaseY      := SafeNum(IniRead(P_IniFile, "Zaawansowane", "BlueBaseY",        "588"),  588)
    redBaseX       := SafeNum(IniRead(P_IniFile, "Zaawansowane", "RedBaseX",         "1247"), 1247)
    redBaseY       := SafeNum(IniRead(P_IniFile, "Zaawansowane", "RedBaseY",         "646"),  646)
    preMoveSleep   := SafeNum(IniRead(P_IniFile, "Zaawansowane", "PreMoveSleep",     "0"),    0)
    postMoveSleep  := SafeNum(IniRead(P_IniFile, "Zaawansowane", "PostMoveSleep",    "150"),  150)
    interactSleep  := SafeNum(IniRead(P_IniFile, "Zaawansowane", "InteractSleep",    "150"),  150)
    interactSleep2 := SafeNum(IniRead(P_IniFile, "Zaawansowane", "InteractSleep2",   "100"),  100)
    escSleep       := SafeNum(IniRead(P_IniFile, "Zaawansowane", "EscSleep",         "100"),  100)
    rSleep         := SafeNum(IniRead(P_IniFile, "Zaawansowane", "RSleep",           "100"),  100)
    enterSleep     := SafeNum(IniRead(P_IniFile, "Zaawansowane", "EnterSleep",       "5000"), 5000)
    scanHits       := SafeNum(IniRead(P_IniFile, "Debug",        "ScanHits",         "3"),    3)
    blueB_min      := SafeNum(IniRead(P_IniFile, "Debug",        "BlueB_min",        "200"),  200)
    blueRG_max     := SafeNum(IniRead(P_IniFile, "Debug",        "BlueRG_max",       "50"),   50)
    redR_min       := SafeNum(IniRead(P_IniFile, "Debug",        "RedR_min",         "200"),  200)
    redBG_max      := SafeNum(IniRead(P_IniFile, "Debug",        "RedBG_max",        "50"),   50)
    pX             := SafeNum(IniRead(P_IniFile, "Zaawansowane", "PortalX",          "956"),  956)
    pY             := SafeNum(IniRead(P_IniFile, "Zaawansowane", "PortalY",          "982"),  982)
    goToWTime      := SafeNum(IniRead(P_IniFile, "GoToPortal",   "WTime",            "0"),    0)
    goToDTime      := SafeNum(IniRead(P_IniFile, "GoToPortal",   "DTime",            "0"),    0)
    goToATime      := SafeNum(IniRead(P_IniFile, "GoToPortal",   "ATime",            "0"),    0)
    goToSleep      := SafeNum(IniRead(P_IniFile, "GoToPortal",   "Sleep",            "0"),    0)
    if (offsetMax < 1) offsetMax := 1

    ; 0 Go-To-Portal (opcjonalny ruch do portalu przed klikaniem)
    if (goToWTime > 0) {
        SendInput "{w down}"
        Sleep goToWTime
        SendInput "{w up}"
    }
    if (goToDTime > 0) {
        SendInput "{d down}"
        Sleep goToDTime
        SendInput "{d up}"
    }
    if (goToATime > 0) {
        SendInput "{a down}"
        Sleep goToATime
        SendInput "{a up}"
    }
    if (goToSleep > 0)
        Sleep goToSleep

    ; 1 klikanie portalu
    Loop 3 {
        if (!running || paused)
            return
        MouseMove pX + Random(1, offsetMax), pY + Random(1, offsetMax), 0
        Sleep clickSleep
        Click
        Sleep postClickSleep
    }
    if (!running || paused)
        return

    ; 2 zamknij X
    MouseMove closeX_X, closeX_Y, 0
    Sleep closeXSleepA
    Click
    Sleep closeXSleepB

    ; ── 3  WYKRYWANIE PORTALI — skalowane do rozdzielczości ────────
    ; Koordynaty portali skalowane proporcjonalnie do okna gry.
    ; Sprawdzamy siatkę 3x3 pikseli i wymagamy min. 3 trafień — odporne
    ; na fałszywe wykrycia i antyaliasing.
    ;
    ; Wartości bazowe (1920x1080):
    ;   Niebieski portal: ~(687, 588)
    ;   Czerwony portal:  ~(1247, 646)
    ;
    ; Progi kolorów (ścisłe, bez PixelSearch):
    ;   Niebieski: B > 160, R < 70, G < 100
    ;   Czerwony:  R > 160, B < 70, G < 100

    ; Rozmiar okna gry (lub cały ekran jako fallback)
    gameHwnd := WinExist("ahk_exe RobloxPlayerBeta.exe")
    if gameHwnd {
        WinGetPos(&rX, &rY, &rW, &rH, "ahk_exe RobloxPlayerBeta.exe")
    } else {
        rX := 0, rY := 0
        rW := A_ScreenWidth
        rH := A_ScreenHeight
    }

    ; Przelicz koordynaty proporcjonalnie do rozdzielczości bazowej
    scaleX := rW / 1920
    scaleY := rH / 1080

    bCX := Round(rX + blueBaseX * scaleX)
    bCY := Round(rY + blueBaseY * scaleY)
    rCX := Round(rX + redBaseX  * scaleX)
    rCY := Round(rY + redBaseY  * scaleY)

    ; Sprawdź siatkę 3x3 pikseli — wymaga 3/9 trafień koloru
    ; Kolor niebieski portalu: 0x0000FF  (R=0,   G=0,   B=255)
    ; Kolor czerwony portalu:  0xFF0000  (R=255, G=0,   B=0  )
    ; Próg: ±20 na każdym kanale — czyste kolory, wąski zakres
    blueHits := 0
    redHits  := 0
    offsets  := [-gridOffset, 0, gridOffset]
    for dx in offsets {
        for dy in offsets {
            bc := PixelGetColor(bCX + dx, bCY + dy, "RGB")
            bR := (bc >> 16) & 0xFF
            bG := (bc >> 8)  & 0xFF
            bB :=  bc        & 0xFF
            ; 0x0000FF: B bliskie 255, R i G bliskie 0
            if (bB > blueB_min && bR < blueRG_max && bG < blueRG_max)
                blueHits++

            rc := PixelGetColor(rCX + dx, rCY + dy, "RGB")
            rR := (rc >> 16) & 0xFF
            rG := (rc >> 8)  & 0xFF
            rBc :=  rc       & 0xFF
            ; 0xFF0000: R bliskie 255, G i B bliskie 0
            if (rR > redR_min && rBc < redBG_max && rG < redBG_max)
                redHits++
        }
    }

    blueFound := (blueHits >= scanHits)
    redFound  := (redHits  >= scanHits)

    ; ── 4  RUCH — tylko gdy oba portale potwierdzone ─────────────
    if (blueFound && redFound) {
        ; Oba portale widoczne — ruch D+S
        SendInput "{d down}"
        Sleep moveTime
        SendInput "{d up}"
        SendInput "{s down}"
        Sleep strafeTime
        SendInput "{s up}"
    } else {
        ; Brak portali lub tylko jeden — ruch neutralny A+S
        SendInput "{s down}"
        Sleep strafeTime
        SendInput "{s up}"
        SendInput "{a down}"
        Sleep moveTime
        SendInput "{a up}"
    }
    if (!running || paused) {
        SendInput "{a up}{d up}{s up}{w up}"
        return
    }

    ; 5 interakcja
    Sleep interactSleep
    SendInput "e"
    Sleep interactSleep2

    P_loopCount++
    P_totalLoops++

    ; szansa na boba
    if (Random(1, P_BOB_DENOM) = 1) {
        P_bobHits++
        if dzwiek {
            Loop 3 {
                SoundPlay "*16"
                Sleep 400
            }
        }
        est := Format("{:.3f}", P_loopCount * (1/P_BOB_DENOM))
        st  := FormatTime2(A_TickCount - sessionStart)
        now := A_TickCount
        P_lastWH := now
        PostWebhook(P_webhook, "🎉 ZNALEZIONO BOBA!`nPętle: " P_loopCount "`nŁącznie: " P_totalLoops "`nBoby: " P_bobHits "`nSzac.: " est "`nSzansa: 1/" P_BOB_DENOM "`nCzas: " st "`nHWID: " hwid)
    }

    ; statystyki cykliczne
    if (Mod(P_loopCount, statsInterval) = 0) {
        now := A_TickCount
        if (P_webhook != "") && (now - P_lastWH >= P_whCooldown) {
            P_lastWH := now
            est := Format("{:.3f}", P_loopCount * (1/P_BOB_DENOM))
            st  := FormatTime2(A_TickCount - sessionStart)
            h   := (A_TickCount - sessionStart) / 3600000
            lph := (h > 0) ? Format("{:.0f}", P_loopCount/h) : "—"
            PostWebhook(P_webhook, "📊 Statystyki Portal`nPętle: " P_loopCount "`nŁącznie: " P_totalLoops "`nBoby: " P_bobHits "`nSzac.: " est "`nPętle/h: " lph "`nCzas: " st)
        }
    }

    UpdatePortalStats(A_TickCount - sessionStart)

    ; 6 reset
    SendInput "{Esc}"
    Sleep escSleep
    SendInput "r"
    Sleep rSleep
    SendInput "{Enter}"
    Sleep enterSleep

    if (running && !paused)
        SetTimer(PortalLoop, 10)
}

; ══════════════════════════════════════════════════════════════════
; PĘTLA TRAP — CORE
; Zabezpieczenie: timestamp-based throttle
; Timer odpala się co 500ms ale kliknięcie wykonuje się tylko
; gdy od ostatniego minęło >= 5000ms — żaden tick nie zostaje pominięty
; ══════════════════════════════════════════════════════════════════

TrapLoop() {
    global running, paused, sessionStart
    global T_brickCount, T_totalBricks, T_BRICK_GOAL
    global T_webhook, T_whCooldown, T_lastWH
    global T_IniFile, hwid

    if (!running || paused)
        return

    clickSleepT    := SafeNum(IniRead(T_IniFile, "Zaawansowane", "ClickSleep",   "100"), 100)
    statsIntervalT := SafeNum(IniRead(T_IniFile, "Makro",        "InterwalStatystyk", "50"), 50)

    SendInput "e"
    Sleep clickSleepT

    T_brickCount++
    T_totalBricks++

    dzwiek        := SafeNum(IniRead(T_IniFile, "Makro", "DzwiekCel",         "1"),  1)
    statsInterval := SafeNum(IniRead(T_IniFile, "Makro", "InterwalStatystyk", "50"), 50)

    UpdateTrapStats(A_TickCount - sessionStart)

    ; cel osiągnięty
    if (T_brickCount >= T_BRICK_GOAL) {
        StopMacro()
        if dzwiek {
            gsdT := SafeNum(IniRead(T_IniFile, "Zaawansowane", "GoalSoundDelay", "300"), 300)
            Loop 5 {
                SoundPlay "*16"
                Sleep gsdT
            }
        }
        st := FormatTime2(A_TickCount - sessionStart)
        PostWebhook(T_webhook, "🏆 BRICK MASTER!`nCegły: " T_brickCount "`nŁącznie: " T_totalBricks "`nCzas: " st "`nHWID: " hwid)
        MsgBox "🏆 1000 cegieł — Brick Master zdobyty!`nCzas sesji: " st, APP_NAME, 64
        return
    }

    ; statystyki cykliczne
    if (statsInterval > 0) && (Mod(T_brickCount, statsInterval) = 0) {
        now := A_TickCount
        if (T_webhook != "") && (now - T_lastWH >= T_whCooldown) {
            T_lastWH := now
            st  := FormatTime2(A_TickCount - sessionStart)
            h   := (A_TickCount - sessionStart) / 3600000
            bph := (h > 0) ? Format("{:.0f}", T_brickCount/h) : "—"
            pct := Round(T_brickCount / T_BRICK_GOAL * 100)
            PostWebhook(T_webhook, "🧱 Statystyki Brick`nCegły: " T_brickCount "/" T_BRICK_GOAL " (" pct "%)`nŁącznie: " T_totalBricks "`nCegły/h: " bph "`nCzas: " st)
        }
    }
}

; ══════════════════════════════════════════════════════════════════
; MODUŁ OBBY MASTERY — GUI
; ══════════════════════════════════════════════════════════════════
BuildObbyGUI() {
    global gui1, statusText, gameText
    global O_partText, O_totalText, O_timerText, O_pphText, O_etaText
    global O_progressText, O_progressBar
    global O_totalParts, O_PART_GOAL

    W := 300
    gui1 := Gui("+AlwaysOnTop -MaximizeBox", "Obby Mastery — " APP_VERSION)
    gui1.BackColor := "0A0C12"
    gui1.MarginX := 16
    gui1.MarginY := 14
    gui1.OnEvent("Close", (*) => gui1.Hide())

    gui1.SetFont("s12 Bold cF1F5F9", "Segoe UI")
    gui1.AddText("xm y14 w" W-32 " Center", "🏗️  Obby Mastery")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gui1.AddText("xm y+2 w" W-32 " Center", APP_NAME "  ·  " APP_VERSION)
    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    gui1.SetFont("s9 Bold cF87171", "Segoe UI")
    statusText := gui1.AddText("xm y+8 w" (W-32)//2, "● ZATRZYMANE")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gameText := gui1.AddText("x+0 yp w" (W-32)//2 " Right", "Gra —")
    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    ; Pasek postępu
    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+10 w" W-32, "Quest 3 — Place 2000 Obby Parts:")
    gui1.SetFont("s9 Bold c34D399", "Segoe UI")
    O_progressText := gui1.AddText("xm y+4 w" W-32 " Center", "0 / 2000  (0%)")
    O_progressBar  := gui1.AddProgress("xm y+4 w" W-32 " h14 Background1C2030 c34D399", 0)
    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    LW := 155 , VW := W-32-LW-2

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+10 w" LW, "Części (sesja)")
    gui1.SetFont("s8 Bold c34D399", "Segoe UI")
    O_partText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Części łącznie")
    gui1.SetFont("s8 c818CF8", "Segoe UI")
    O_totalText := gui1.AddText("x+2 yp w" VW " Right", FormatLoops(O_totalParts))

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Czas sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    O_timerText := gui1.AddText("x+2 yp w" VW " Right", "00:00:00")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Części/godz.")
    gui1.SetFont("s8 c6366F1", "Segoe UI")
    O_pphText := gui1.AddText("x+2 yp w" VW " Right", "—")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Szac. czas do celu")
    gui1.SetFont("s8 c94A3B8", "Segoe UI")
    O_etaText := gui1.AddText("x+2 yp w" VW " Right", "—")

    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    gui1.SetFont("s7 c4A5568", "Segoe UI")
    gui1.AddText("xm y+8 w" W-32, "ℹ  Klika E (zdolność Obby) co 3 sekundy.")
    gui1.AddText("xm y+3 w" W-32, "    Cel: 2000 Obby parts = Quest 3 Mastery.")
    gui1.AddText("xm y+3 w" W-32, "    Questy 1 i 2 wymagają gry manualnej.")
    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    BW := (W-32-8)//2
    gui1.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    sBtn := gui1.AddButton("xm y+10 w" BW " h30", "▶  Start")
    eBtn := gui1.AddButton("x+8 yp w" BW " h30",  "■  Stop")
    gui1.SetFont("s8 c64748B", "Segoe UI")
    tBtn := gui1.AddButton("xm y+6 w" BW " h24", "⚙  Ustawienia")
    hBtn := gui1.AddButton("x+8 yp w" BW " h24", "📋  Historia")
    gui1.SetFont("s7 c334155", "Segoe UI")
    gui1.AddText("xm y+10 w" W-32 " Center", "F6 start/stop   F9 panic   F8 wyjście")

    sBtn.OnEvent("Click", StartMacro)
    eBtn.OnEvent("Click", StopMacro)
    tBtn.OnEvent("Click", OpenObbySettings)
    hBtn.OnEvent("Click", OpenObbyHistory)

    gui1.Show("w" W)
}

UpdateObbyStats(elapsed) {
    global O_partCount, O_totalParts, O_PART_GOAL
    global O_partText, O_totalText, O_timerText, O_pphText, O_etaText
    global O_progressText, O_progressBar
    pct := Min(100, Round(O_partCount / O_PART_GOAL * 100))
    O_partText.Text     := String(O_partCount)
    O_totalText.Text    := FormatLoops(O_totalParts)
    O_timerText.Text    := FormatTime2(elapsed)
    O_progressText.Text := O_partCount " / " O_PART_GOAL "  (" pct "%)"
    O_progressBar.Value := pct
    h := elapsed / 3600000
    if (h > 0.001) {
        pph := Round(O_partCount / h)
        O_pphText.Text := pph "/h"
        rem := O_PART_GOAL - O_partCount
        if (pph > 0) {
            eta := Round(rem / pph * 60)
            O_etaText.Text := (eta > 60) ? Format("{:.1f}h", eta/60) : eta "min"
        } else {
            O_etaText.Text := "—"
        }
    } else {
        O_pphText.Text := "—"
        O_etaText.Text := "—"
    }
}

; ── Obby: Ustawienia ──────────────────────────────────────────────
global O_wI, O_cI, O_siI, O_dtI, O_apC, O_dcC

; ── Obby advanced vars ──
global O_adv_PostESleep, O_adv_GoalParts

; ── Obby advanced globals ──
global O_adv_PostESleep, O_adv_DoubleTapDelay, O_adv_PartCD, O_adv_PartGoal
global O_adv_StatsInterval, O_adv_GoalSoundDelay
global O_apC, O_dcC

OpenObbySettings(*) {
    global O_IniFile, gui1
    global O_adv_PostESleep, O_adv_DoubleTapDelay, O_adv_PartCD, O_adv_PartGoal
    global O_adv_StatsInterval, O_adv_GoalSoundDelay
    global O_apC, O_dcC
    global O_wh_URL, O_wh_CD

    gsO := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Ustawienia — Obby Mastery")
    gsO.BackColor := "0A0C12"
    gsO.MarginX := 16
    gsO.MarginY := 10

    gsO.SetFont("s10 Bold cF1F5F9", "Segoe UI")
    gsO.AddText("xm y10 w340 Center", "Ustawienia — Obby Mastery")

    ; OPCJE
    gsO.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsO.AddText("xm y+10 w340", "OPCJE")
    gsO.AddText("xm y+3 w340 h1 0x10", "")
    gsO.SetFont("s8 c64748B", "Segoe UI")
    O_apC := gsO.AddCheckbox("xm y+6 w340 c94A3B8", "Auto-pauza gdy gra nieaktywna")
    O_apC.Value := SafeNum(IniRead(O_IniFile, "Makro", "AutoPauza", "1"), 1)
    O_dcC := gsO.AddCheckbox("xm y+4 w340 c94A3B8", "Dzwiek po osiagnieciu celu")
    O_dcC.Value := SafeNum(IniRead(O_IniFile, "Makro", "DzwiekCel", "1"), 1)

    ; ZAAWANSOWANE
    gsO.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsO.AddText("xm y+12 w340", "ZAAWANSOWANE USTAWIENIA")
    gsO.AddText("xm y+3 w340 h1 0x10", "")
    gsO.SetFont("s7 c94A3B8", "Segoe UI")
    gsO.AddText("xm y+3 w340", "Zmiana moze destabilizowac makro. Domyslne wartosci w [...].")
    LW := 185
    VW := 340 - LW - 8
    gsO.SetFont("s8 c64748B", "Segoe UI")

    ; Timing
    gsO.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsO.AddText("xm y+8 w340", "  Timing")
    gsO.SetFont("s8 c64748B", "Segoe UI")
    gsO.AddText("xm y+4 w" LW, "Przerwa miedzy 2x E (ms) [500]:")
    O_adv_DoubleTapDelay := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(O_IniFile, "Makro", "DoubleTapDelay", "500"))
    gsO.AddText("xm y+4 w" LW, "Sleep po 2x E (ms) [100]:")
    O_adv_PostESleep := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(O_IniFile, "Zaawansowane", "PostESleep", "100"))
    gsO.AddText("xm y+4 w" LW, "Cooldown Obby (ms) [3000]:")
    O_adv_PartCD := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(O_IniFile, "Zaawansowane", "PartCD", "3000"))
    gsO.AddText("xm y+4 w" LW, "Sleep dzwiek po osiagnieciu celu (ms) [300]:")
    O_adv_GoalSoundDelay := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(O_IniFile, "Zaawansowane", "GoalSoundDelay", "300"))

    ; Cel i statystyki
    gsO.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsO.AddText("xm y+8 w340", "  Cel i statystyki")
    gsO.SetFont("s8 c64748B", "Segoe UI")
    gsO.AddText("xm y+4 w" LW, "Cel (liczba czesci) [2000]:")
    O_adv_PartGoal := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(O_IniFile, "Zaawansowane", "PartGoal", "2000"))
    gsO.AddText("xm y+4 w" LW, "Co ile czesci wysylac stats [100]:")
    O_adv_StatsInterval := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(O_IniFile, "Makro", "InterwalStatystyk", "100"))

    ; WEBHOOK STATYSTYK
    gsO.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsO.AddText("xm y+12 w340", "WEBHOOK STATYSTYK")
    gsO.AddText("xm y+3 w340 h1 0x10", "")
    gsO.SetFont("s8 c64748B", "Segoe UI")
    gsO.AddText("xm y+4 w" LW, "URL webhooka statystyk:")
    O_wh_URL := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(O_IniFile, "Webhook", "URL", ""))
    gsO.AddText("xm y+4 w" LW, "Cooldown webhooka (ms) [5000]:")
    O_wh_CD := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(O_IniFile, "Webhook", "Cooldown", "5000"))

    ; DEBUGOWANIE
    gsO.SetFont("s7 Bold cF87171", "Segoe UI")
    gsO.AddText("xm y+12 w340", "DEBUGOWANIE")
    gsO.AddText("xm y+3 w340 h1 0x10", "")
    gsO.SetFont("s7 c94A3B8", "Segoe UI")
    gsO.AddText("xm y+3 w340", "Krytyczne zmienne — bledna wartosc zniszczy makro.")
    gsO.SetFont("s8 c64748B", "Segoe UI")
    gsO.AddText("xm y+6 w" LW, "Kod PIN:")
    dbPinO := gsO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200 Password")
    gsO.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    dbBtnO := gsO.AddButton("xm y+6 w340 h26", "Odblokuj sekcje debugowania")
    dbBtnO.OnEvent("Click", (*) => OpenObbyDebug(gsO, dbPinO.Value))

    gsO.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    svO := gsO.AddButton("xm y+10 w340 h30", "Zapisz ustawienia")
    svO.OnEvent("Click", SaveObbySettings)
    gsO.Show("w372")
}

OpenObbyDebug(parentGui, enteredPin) {
    global debugCode, O_IniFile, webhookHWID, jsonURL
    if (enteredPin != debugCode) {
        MsgBox "Nieprawidlowy kod PIN.", "Debugowanie", 48
        return
    }
    gdO := Gui("+AlwaysOnTop +Owner" parentGui.Hwnd, "Debugowanie — Obby Mastery")
    gdO.BackColor := "0A0C12"
    gdO.MarginX := 16
    gdO.MarginY := 10
    LW := 185
    VW := 340 - LW - 8

    gdO.SetFont("s9 Bold cF87171", "Segoe UI")
    gdO.AddText("xm y10 w340 Center", "SEKCJA DEBUGOWANIA")
    gdO.SetFont("s7 c94A3B8", "Segoe UI")
    gdO.AddText("xm y+4 w340 Center", "UWAGA: bledna zmiana = makro przestanie dzialac!")
    gdO.AddText("xm y+8 w340 h1 0x10", "")

    ; Licencja i HWID
    gdO.SetFont("s7 Bold cF87171", "Segoe UI")
    gdO.AddText("xm y+8 w340", "  Licencja i HWID")
    gdO.SetFont("s8 c64748B", "Segoe UI")
    gdO.AddText("xm y+4 w" LW, "URL JSON licencji:")
    dbJsonO := gdO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", jsonURL)
    gdO.AddText("xm y+4 w" LW, "Webhook HWID (rejestracja):")
    dbWHO := gdO.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", webhookHWID)

    ; Webhook — przeniesiony do ustawien glownych

    gdO.SetFont("s9 Bold cF87171", "Segoe UI")
    svDbO := gdO.AddButton("xm y+14 w340 h28", "Zapisz ustawienia debugowania")
    svDbO.OnEvent("Click", (*) => SaveObbyDebug(dbJsonO.Value, dbWHO.Value))
    gdO.SetFont("s8 c64748B", "Segoe UI")
    gdO.AddButton("xm y+5 w340 h24", "Zamknij").OnEvent("Click", (*) => gdO.Destroy())
    gdO.Show("w372")
}

SaveObbyDebug(newJson, newWH) {
    global jsonURL, webhookHWID
    jsonURL     := newJson
    webhookHWID := newWH
    MsgBox "Ustawienia debugowania zapisane.", "Debugowanie", 64
}

SaveObbySettings(*) {
    global O_IniFile, O_PART_GOAL, O_PART_CD
    global O_apC, O_dcC
    global O_adv_PostESleep, O_adv_DoubleTapDelay, O_adv_PartCD, O_adv_PartGoal
    global O_adv_StatsInterval, O_adv_GoalSoundDelay
    IniWrite O_apC.Value,               O_IniFile, "Makro",        "AutoPauza"
    IniWrite O_dcC.Value,               O_IniFile, "Makro",        "DzwiekCel"
    IniWrite O_adv_DoubleTapDelay.Value,O_IniFile, "Makro",        "DoubleTapDelay"
    IniWrite O_adv_StatsInterval.Value, O_IniFile, "Makro",        "InterwalStatystyk"
    IniWrite O_adv_PostESleep.Value,    O_IniFile, "Zaawansowane", "PostESleep"
    IniWrite O_adv_PartCD.Value,        O_IniFile, "Zaawansowane", "PartCD"
    IniWrite O_adv_PartGoal.Value,      O_IniFile, "Zaawansowane", "PartGoal"
    IniWrite O_adv_GoalSoundDelay.Value,O_IniFile, "Zaawansowane", "GoalSoundDelay"
    O_PART_GOAL := SafeNum(O_adv_PartGoal.Value, 2000)
    O_PART_CD   := SafeNum(O_adv_PartCD.Value,   3000)
    IniWrite O_wh_URL.Value, O_IniFile, "Webhook", "URL"
    IniWrite O_wh_CD.Value,  O_IniFile, "Webhook", "Cooldown"
    O_webhook    := O_wh_URL.Value
    O_whCooldown := SafeNum(O_wh_CD.Value, 5000)
    MsgBox "Ustawienia zapisane!", APP_NAME, 64
}

OpenObbyHistory(*) {
    global O_HistFile
    if !FileExist(O_HistFile) {
        MsgBox "Brak historii.", APP_NAME, 64
        return
    }
    content := FileRead(O_HistFile)
    ghO := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Historia — Obby Mastery")
    ghO.BackColor := "0A0C12"
    ghO.MarginX := 14
    ghO.MarginY := 14
    ghO.SetFont("s8 cF1F5F9", "Segoe UI")
    eO := ghO.AddEdit("xm y14 w540 h300 ReadOnly Background12151F cF1F5F9 -E0x200", content)
    ghO.SetFont("s8 c64748B", "Segoe UI")
    c1 := ghO.AddButton("xm y+8 w265 h24", "🗑   Wyczyść")
    c2 := ghO.AddButton("x+10 yp w265 h24", "✕   Zamknij")
    c1.OnEvent("Click", (*) => (FileDelete(O_HistFile), eO.Value := "", MsgBox("Wyczyszczono.", APP_NAME, 64)))
    c2.OnEvent("Click", (*) => ghO.Destroy())
    ghO.Show("w568")
}

; ══════════════════════════════════════════════════════════════════
; PĘTLA OBBY — CORE
; Timestamp-based throttle — klika E co 3s niezależnie od obciążenia
; ══════════════════════════════════════════════════════════════════
ObbyLoop() {
    global running, paused, sessionStart
    global O_partCount, O_totalParts, O_PART_GOAL
    global O_webhook, O_whCooldown, O_lastWH
    global O_IniFile, hwid

    if (!running || paused)
        return

    ; Podwójne kliknięcie E — przerwa konfigurowalna w ustawieniach
    doubleTapDelay := SafeNum(IniRead(O_IniFile, "Makro",        "DoubleTapDelay", "500"), 500)
    postESleep     := SafeNum(IniRead(O_IniFile, "Zaawansowane", "PostESleep",     "100"), 100)
    SendInput "e"
    Sleep doubleTapDelay
    SendInput "e"
    Sleep postESleep

    O_partCount++
    O_totalParts++

    dzwiek        := SafeNum(IniRead(O_IniFile, "Makro", "DzwiekCel",         "1"),   1)
    statsInterval := SafeNum(IniRead(O_IniFile, "Makro", "InterwalStatystyk", "100"), 100)

    UpdateObbyStats(A_TickCount - sessionStart)

    ; cel osiągnięty
    if (O_partCount >= O_PART_GOAL) {
        StopMacro()
        if dzwiek {
            gsdO := SafeNum(IniRead(O_IniFile, "Zaawansowane", "GoalSoundDelay", "300"), 300)
            Loop 5 {
                SoundPlay "*16"
                Sleep gsdO
            }
        }
        st := FormatTime2(A_TickCount - sessionStart)
        now2 := A_TickCount
        O_lastWH := now2
        PostWebhook(O_webhook, "🏆 OBBY QUEST 3 UKOŃCZONY!`nCzęści: " O_partCount "`nŁącznie: " O_totalParts "`nCzas: " st "`nHWID: " hwid)
        MsgBox "🏆 2000 Obby parts — Quest 3 ukończony!`nCzas sesji: " st, APP_NAME, 64
        return
    }

    ; statystyki cykliczne
    if (statsInterval > 0) && (Mod(O_partCount, statsInterval) = 0) {
        now2 := A_TickCount
        if (O_webhook != "") && (now2 - O_lastWH >= O_whCooldown) {
            O_lastWH := now2
            st  := FormatTime2(A_TickCount - sessionStart)
            h   := (A_TickCount - sessionStart) / 3600000
            pph := (h > 0) ? Format("{:.0f}", O_partCount/h) : "—"
            pct := Round(O_partCount / O_PART_GOAL * 100)
            PostWebhook(O_webhook, "🏗️ Statystyki Obby`nCzęści: " O_partCount "/" O_PART_GOAL " (" pct "%)`nŁącznie: " O_totalParts "`nCzęści/h: " pph "`nCzas: " st)
        }
    }
}

; ══════════════════════════════════════════════════════════════════
; MODUŁ REPLICA BOB — GUI
; Prosty klik E co 14s (cooldown repliki) — niezależny od lagów.
; Timer odpala się dokładnie co CD ms bez żadnego sleep w pętli,
; więc lag w grze nie przesuwa kolejnego kliknięcia.
; ══════════════════════════════════════════════════════════════════
BuildReplicaGUI() {
    global gui1, statusText, gameText
    global R_clickText, R_totalText, R_timerText, R_cphText, R_bobText, R_estText
    global R_totalClicks, R_BOB_DENOM

    W := 300
    gui1 := Gui("+AlwaysOnTop -MaximizeBox", "Replica Bob — " APP_VERSION)
    gui1.BackColor := "0A0C12"
    gui1.MarginX := 16
    gui1.MarginY := 14
    gui1.OnEvent("Close", (*) => gui1.Hide())

    gui1.SetFont("s12 Bold cF1F5F9", "Segoe UI")
    gui1.AddText("xm y14 w" W-32 " Center", "⚡  Replica Bob")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gui1.AddText("xm y+2 w" W-32 " Center", APP_NAME "  ·  " APP_VERSION)
    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    gui1.SetFont("s9 Bold cF87171", "Segoe UI")
    statusText := gui1.AddText("xm y+8 w" (W-32)//2, "● ZATRZYMANE")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gameText := gui1.AddText("x+0 yp w" (W-32)//2 " Right", "Gra —")
    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    LW := 155 , VW := W-32-LW-2

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+10 w" LW, "Kliknięcia sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    R_clickText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Znalezione Boby")
    gui1.SetFont("s8 Bold cA78BFA", "Segoe UI")
    R_bobText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Szacowane Boby")
    gui1.SetFont("s8 Bold c4ADE80", "Segoe UI")
    R_estText := gui1.AddText("x+2 yp w" VW " Right", "0.000")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Czas sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    R_timerText := gui1.AddText("x+2 yp w" VW " Right", "00:00:00")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Kliki/godz.")
    gui1.SetFont("s8 c6366F1", "Segoe UI")
    R_cphText := gui1.AddText("x+2 yp w" VW " Right", "—")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Kliki łącznie")
    gui1.SetFont("s8 c818CF8", "Segoe UI")
    R_totalText := gui1.AddText("x+2 yp w" VW " Right", FormatLoops(R_totalClicks))

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Szansa na Boba")
    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("x+2 yp w" VW " Right", "1/" R_BOB_DENOM)

    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    BW := (W-32-8)//2
    gui1.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    sBtn := gui1.AddButton("xm y+10 w" BW " h30", "▶  Start")
    eBtn := gui1.AddButton("x+8 yp w" BW " h30",  "■  Stop")
    gui1.SetFont("s8 c64748B", "Segoe UI")
    tBtn := gui1.AddButton("xm y+6 w" BW " h24", "⚙  Ustawienia")
    hBtn := gui1.AddButton("x+8 yp w" BW " h24", "📋  Historia")
    gui1.SetFont("s7 c334155", "Segoe UI")
    gui1.AddText("xm y+10 w" W-32 " Center", "F6 start/stop   F9 panic   F8 wyjście")

    sBtn.OnEvent("Click", StartMacro)
    eBtn.OnEvent("Click", StopMacro)
    tBtn.OnEvent("Click", OpenReplicaSettings)
    hBtn.OnEvent("Click", OpenReplicaHistory)

    gui1.Show("w" W)
}

UpdateReplicaStats(elapsed) {
    global R_clickText, R_totalText, R_timerText, R_cphText, R_bobText, R_estText
    global R_clickCount, R_totalClicks, R_bobHits, R_BOB_DENOM
    try {
        R_clickText.Text := FormatLoops(R_clickCount)
        R_bobText.Text   := String(R_bobHits)
        est := Format("{:.3f}", R_clickCount * (1/R_BOB_DENOM))
        R_estText.Text   := est
        R_timerText.Text := FormatTime2(elapsed)
        R_totalText.Text := FormatLoops(R_totalClicks)
        h   := elapsed / 3600000
        R_cphText.Text   := (h > 0.001) ? Format("{:.0f}", R_clickCount/h) : "—"
    }
}

; ══════════════════════════════════════════════════════════════════
; PĘTLA REPLICA BOB — CORE
; Używa SetTimer z dokładnym interwałem — nie używa Sleep.
; Lag w grze nie wpływa na czas kolejnego kliknięcia.
; ══════════════════════════════════════════════════════════════════
ReplicaLoop() {
    global running, paused, sessionStart
    global R_clickCount, R_totalClicks, R_bobHits, R_BOB_DENOM
    global R_webhook, R_whCooldown, R_lastWH
    global R_IniFile, R_loopTimer, R_CD
    global hwid

    if (!running || paused)
        return

    ; Zatrzymaj timer — ustawimy nowy interwał po odczytaniu INI
    SetTimer(ReplicaLoop, 0)

    ; Odczytaj aktualny cooldown z INI (można zmienić bez restartu)
    cd           := SafeNum(IniRead(R_IniFile, "Zaawansowane", "CD",          "14000"), 14000)
    statsInterval := SafeNum(IniRead(R_IniFile, "Makro",        "InterwalStatystyk", "100"), 100)
    dzwiek       := SafeNum(IniRead(R_IniFile, "Makro",        "DzwiekBob",         "1"),   1)
    R_BOB_DENOM  := SafeNum(IniRead(R_IniFile, "Debug",        "BobDenom",          "7500"),7500)

    ; Kliknięcie E — główna akcja
    SendInput "e"

    R_clickCount++
    R_totalClicks++

    ; Szansa na Boba
    if (Random(1, R_BOB_DENOM) = 1) {
        R_bobHits++
        if dzwiek {
            Loop 3 {
                SoundPlay "*16"
                Sleep 400
            }
        }
        est := Format("{:.3f}", R_clickCount * (1/R_BOB_DENOM))
        st  := FormatTime2(A_TickCount - sessionStart)
        R_lastWH := A_TickCount
        PostWebhook(R_webhook, "ZNALEZIONO BOBA! (Replica)`nKliki: " R_clickCount "`nBoby: " R_bobHits "`nSzac.: " est "`nCzas: " st "`nHWID: " hwid)
    }

    ; Statystyki cykliczne
    if (Mod(R_clickCount, statsInterval) = 0) {
        now := A_TickCount
        if (R_webhook != "") && (now - R_lastWH >= R_whCooldown) {
            R_lastWH := now
            est := Format("{:.3f}", R_clickCount * (1/R_BOB_DENOM))
            st  := FormatTime2(A_TickCount - sessionStart)
            h   := (A_TickCount - sessionStart) / 3600000
            cph := (h > 0) ? Format("{:.0f}", R_clickCount/h) : "—"
            PostWebhook(R_webhook, "Statystyki Replica Bob`nKliki: " R_clickCount "`nBoby: " R_bobHits "`nSzac.: " est "`nKliki/h: " cph "`nCzas: " st)
        }
    }

    UpdateReplicaStats(A_TickCount - sessionStart)

    ; Ustaw następny timer — dokładny interwał od TERAZ
    ; (nie od startu pętli, żeby lagi gry nie kumulowały dryftu)
    if (running && !paused)
        SetTimer(ReplicaLoop, cd)
}

; ══════════════════════════════════════════════════════════════════
; REPLICA — USTAWIENIA
; ══════════════════════════════════════════════════════════════════
global R_adv_CD, R_adv_BobDenom_Adv, R_adv_StatsInterval, R_apC_R, R_dzC_R
global R_wh_URL, R_wh_CD

OpenReplicaSettings(*) {
    global R_IniFile, gui1
    global R_adv_CD, R_adv_StatsInterval, R_apC_R, R_dzC_R
    global R_wh_URL, R_wh_CD

    gsR := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Ustawienia — Replica Bob")
    gsR.BackColor := "0A0C12"
    gsR.MarginX := 16
    gsR.MarginY := 10

    gsR.SetFont("s10 Bold cF1F5F9", "Segoe UI")
    gsR.AddText("xm y10 w340 Center", "Ustawienia — Replica Bob")

    ; OPCJE
    gsR.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsR.AddText("xm y+10 w340", "OPCJE")
    gsR.AddText("xm y+3 w340 h1 0x10", "")
    gsR.SetFont("s8 c64748B", "Segoe UI")
    R_apC_R := gsR.AddCheckbox("xm y+6 w340 c94A3B8", "Auto-pauza gdy gra nieaktywna")
    R_apC_R.Value := SafeNum(IniRead(R_IniFile, "Makro", "AutoPauza", "1"), 1)
    R_dzC_R := gsR.AddCheckbox("xm y+4 w340 c94A3B8", "Dzwiek przy znalezieniu Boba")
    R_dzC_R.Value := SafeNum(IniRead(R_IniFile, "Makro", "DzwiekBob", "1"), 1)

    ; ZAAWANSOWANE
    gsR.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsR.AddText("xm y+12 w340", "ZAAWANSOWANE USTAWIENIA")
    gsR.AddText("xm y+3 w340 h1 0x10", "")
    gsR.SetFont("s7 c94A3B8", "Segoe UI")
    gsR.AddText("xm y+3 w340", "Zmiana moze destabilizowac makro. Domyslne wartosci w [...].")
    LW := 185
    VW := 340 - LW - 8
    gsR.SetFont("s8 c64748B", "Segoe UI")

    ; Timing
    gsR.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsR.AddText("xm y+8 w340", "  Timing")
    gsR.SetFont("s8 c64748B", "Segoe UI")
    gsR.AddText("xm y+4 w" LW, "Cooldown kliku E (ms) [14000]:")
    R_adv_CD := gsR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(R_IniFile, "Zaawansowane", "CD", "14000"))
    gsR.SetFont("s7 c94A3B8", "Segoe UI")
    gsR.AddText("xm y+2 w340", "  Uwaga: timer startuje od momentu klikniecia, nie od startu gry.")

    ; Statystyki
    gsR.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsR.AddText("xm y+8 w340", "  Statystyki i webhook")
    gsR.SetFont("s8 c64748B", "Segoe UI")
    gsR.AddText("xm y+4 w" LW, "Co ile klikniecia wysylac stats [100]:")
    R_adv_StatsInterval := gsR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(R_IniFile, "Makro", "InterwalStatystyk", "100"))

    ; WEBHOOK STATYSTYK
    gsR.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsR.AddText("xm y+12 w340", "WEBHOOK STATYSTYK")
    gsR.AddText("xm y+3 w340 h1 0x10", "")
    gsR.SetFont("s8 c64748B", "Segoe UI")
    gsR.AddText("xm y+4 w" LW, "URL webhooka statystyk:")
    R_wh_URL := gsR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(R_IniFile, "Webhook", "URL", ""))
    gsR.AddText("xm y+4 w" LW, "Cooldown webhooka (ms) [10000]:")
    R_wh_CD := gsR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(R_IniFile, "Webhook", "Cooldown", "10000"))

    ; DEBUGOWANIE
    gsR.SetFont("s7 Bold cF87171", "Segoe UI")
    gsR.AddText("xm y+12 w340", "DEBUGOWANIE")
    gsR.AddText("xm y+3 w340 h1 0x10", "")
    gsR.SetFont("s7 c94A3B8", "Segoe UI")
    gsR.AddText("xm y+3 w340", "Krytyczne zmienne — bledna wartosc zniszczy makro.")
    gsR.SetFont("s8 c64748B", "Segoe UI")
    gsR.AddText("xm y+6 w" LW, "Kod PIN:")
    dbPinR := gsR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200 Password")
    gsR.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    dbBtnR := gsR.AddButton("xm y+6 w340 h26", "Odblokuj sekcje debugowania")
    dbBtnR.OnEvent("Click", (*) => OpenReplicaDebug(gsR, dbPinR.Value))

    gsR.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    svR := gsR.AddButton("xm y+10 w340 h30", "Zapisz ustawienia")
    svR.OnEvent("Click", SaveReplicaSettings)
    gsR.Show("w372")
}

OpenReplicaDebug(parentGui, enteredPin) {
    global debugCode, R_IniFile, webhookHWID, jsonURL, R_BOB_DENOM
    if (enteredPin != debugCode) {
        MsgBox "Nieprawidlowy kod PIN.", "Debugowanie", 48
        return
    }
    gdR := Gui("+AlwaysOnTop +Owner" parentGui.Hwnd, "Debugowanie — Replica Bob")
    gdR.BackColor := "0A0C12"
    gdR.MarginX := 16
    gdR.MarginY := 10
    LW := 185
    VW := 340 - LW - 8

    gdR.SetFont("s9 Bold cF87171", "Segoe UI")
    gdR.AddText("xm y10 w340 Center", "SEKCJA DEBUGOWANIA")
    gdR.SetFont("s7 c94A3B8", "Segoe UI")
    gdR.AddText("xm y+4 w340 Center", "UWAGA: bledna zmiana = makro przestanie dzialac!")
    gdR.AddText("xm y+8 w340 h1 0x10", "")

    gdR.SetFont("s7 Bold cF87171", "Segoe UI")
    gdR.AddText("xm y+8 w340", "  Licencja i HWID")
    gdR.SetFont("s8 c64748B", "Segoe UI")
    gdR.AddText("xm y+4 w" LW, "URL JSON licencji:")
    dbJsonR := gdR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", jsonURL)
    gdR.AddText("xm y+4 w" LW, "Webhook HWID (rejestracja):")
    dbWHR := gdR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", webhookHWID)

    gdR.SetFont("s7 Bold cF87171", "Segoe UI")
    gdR.AddText("xm y+8 w340", "  Webhook statystyk Replica")
    gdR.SetFont("s8 c64748B", "Segoe UI")
    gdR.AddText("xm y+4 w" LW, "URL webhooka statystyk:")
    dbRWH := gdR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(R_IniFile, "Webhook", "URL", ""))
    gdR.AddText("xm y+4 w" LW, "Cooldown webhooka (ms) [10000]:")
    dbRWHCD := gdR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(R_IniFile, "Webhook", "Cooldown", "10000"))

    gdR.SetFont("s7 Bold cF87171", "Segoe UI")
    gdR.AddText("xm y+8 w340", "  Szansa na Boba")
    gdR.SetFont("s8 c64748B", "Segoe UI")
    gdR.AddText("xm y+4 w" LW, "Mianownik szansy (1/X) [7500]:")
    dbBobDenomR := gdR.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", String(R_BOB_DENOM))

    gdR.SetFont("s9 Bold cF87171", "Segoe UI")
    svDbR := gdR.AddButton("xm y+14 w340 h28", "Zapisz ustawienia debugowania")
    svDbR.OnEvent("Click", (*) => SaveReplicaDebug(dbJsonR.Value, dbWHR.Value, dbBobDenomR.Value))
    gdR.SetFont("s8 c64748B", "Segoe UI")
    gdR.AddButton("xm y+5 w340 h24", "Zamknij").OnEvent("Click", (*) => gdR.Destroy())
    gdR.Show("w372")
}

SaveReplicaDebug(newJson, newWH, newBobDenom) {
    global jsonURL, webhookHWID, R_IniFile, R_BOB_DENOM
    jsonURL     := newJson
    webhookHWID := newWH
    R_BOB_DENOM := SafeNum(newBobDenom, 7500)
    IniWrite newBobDenom, R_IniFile, "Debug", "BobDenom"
    MsgBox "Ustawienia debugowania zapisane.", "Debugowanie", 64
}

SaveReplicaSettings(*) {
    global R_IniFile, R_CD
    global R_adv_CD, R_adv_StatsInterval, R_apC_R, R_dzC_R
    IniWrite R_apC_R.Value,           R_IniFile, "Makro",        "AutoPauza"
    IniWrite R_dzC_R.Value,           R_IniFile, "Makro",        "DzwiekBob"
    IniWrite R_adv_StatsInterval.Value,R_IniFile,"Makro",        "InterwalStatystyk"
    IniWrite R_adv_CD.Value,          R_IniFile, "Zaawansowane", "CD"
    R_CD := SafeNum(R_adv_CD.Value, 14000)
    IniWrite R_wh_URL.Value, R_IniFile, "Webhook", "URL"
    IniWrite R_wh_CD.Value,  R_IniFile, "Webhook", "Cooldown"
    R_webhook    := R_wh_URL.Value
    R_whCooldown := SafeNum(R_wh_CD.Value, 10000)
    MsgBox "Ustawienia zapisane!", APP_NAME, 64
}

OpenReplicaHistory(*) {
    global R_HistFile
    if !FileExist(R_HistFile) {
        MsgBox "Brak historii.", APP_NAME, 64
        return
    }
    content := FileRead(R_HistFile)
    ghR := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Historia — Replica Bob")
    ghR.BackColor := "0A0C12"
    ghR.MarginX := 14
    ghR.MarginY := 14
    ghR.SetFont("s8 cF1F5F9", "Segoe UI")
    eR := ghR.AddEdit("xm y14 w540 h300 ReadOnly Background12151F cF1F5F9 -E0x200", content)
    ghR.SetFont("s8 c64748B", "Segoe UI")
    c1 := ghR.AddButton("xm y+8 w265 h24", "Wyczysc")
    c2 := ghR.AddButton("x+10 yp w265 h24", "Zamknij")
    c1.OnEvent("Click", (*) => (FileDelete(R_HistFile), eR.Value := "", MsgBox("Wyczyszczono.", APP_NAME, 64)))
    c2.OnEvent("Click", (*) => ghR.Destroy())
    ghR.Show("w568")
}

; ══════════════════════════════════════════════════════════════════
; HELPER — przechwytywanie klawisza/przycisku myszy od użytkownika
; NIE blokuje wątku — używa InputHook bez Wait() + callback
; Bezpieczne: Esc anuluje, timeout 10s, LButton NIE jest przechwytywany
; (LButtonem zamykałoby okno zanim cokolwiek się stanie)
; ══════════════════════════════════════════════════════════════════
global WKP_ih := ""        ; aktywny InputHook (żeby StopMacro mógł go wyczyścić)
global WKP_targetEdit := "" ; kontrolka Edit do której wpisujemy wynik

WKP_Open(parentHwnd, editCtrl) {
    global WKP_ih, WKP_targetEdit, WKP_gui

    ; Jeśli już nasłuchujemy — ignoruj
    if (WKP_ih != "")
        return

    WKP_targetEdit := editCtrl

    WKP_gui := Gui("+AlwaysOnTop +Owner" parentHwnd " +ToolWindow -SysMenu", "Ustaw klawisz")
    WKP_gui.BackColor := "0A0C12"
    WKP_gui.MarginX := 20
    WKP_gui.MarginY := 16
    WKP_gui.SetFont("s10 Bold cF1F5F9", "Segoe UI")
    WKP_gui.AddText("xm y16 w260 Center", "Naciśnij klawisz lub przycisk myszy")
    WKP_gui.SetFont("s8 c94A3B8", "Segoe UI")
    WKP_gui.AddText("xm y+8 w260 Center", "Aktualny: " editCtrl.Value)
    WKP_gui.SetFont("s8 cFBBF24", "Segoe UI")
    WKP_gui.AddText("xm y+6 w260 Center", "Esc = anuluj  ·  timeout: 10s")
    WKP_gui.OnEvent("Close", WKP_Cancel)
    WKP_gui.Show("w300")

    ; InputHook bez Wait() — nie blokuje wątku
    WKP_ih := InputHook("L0 T10")
    WKP_ih.KeyOpt("{All}", "N")      ; N = notify OnKeyDown, nie suppress (bezpieczne)
    WKP_ih.OnKeyDown := WKP_OnKey
    WKP_ih.OnEnd     := WKP_OnEnd   ; wywoływane przy timeout lub Stop()
    WKP_ih.Start()

    ; Przyciski myszy (bez LButton — nim klikamy przycisk "Ustaw")
    for btn in ["RButton", "MButton", "XButton1", "XButton2"]
        Hotkey btn, WKP_OnMouse.Bind(btn), "On"
}

WKP_OnKey(ih, vk, sc) {
    key := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
    if (key = "Escape") {
        WKP_Cancel()
        return
    }
    WKP_Finish(key)
}

WKP_OnEnd(ih) {
    ; Timeout — po prostu zamknij bez zmian
    WKP_Cancel()
}

WKP_OnMouse(btn, *) {
    WKP_Finish(btn)
}

WKP_Finish(key) {
    global WKP_ih, WKP_targetEdit, WKP_gui
    WKP_Cleanup()
    if (IsObject(WKP_targetEdit))
        WKP_targetEdit.Value := key
    try WKP_gui.Destroy()
}

WKP_Cancel(*) {
    global WKP_ih, WKP_gui
    WKP_Cleanup()
    try WKP_gui.Destroy()
}

WKP_Cleanup() {
    global WKP_ih
    for btn in ["RButton", "MButton", "XButton1", "XButton2"]
        try Hotkey btn, WKP_OnMouse.Bind(btn), "Off"
    if (WKP_ih != "") {
        try WKP_ih.Stop()
        WKP_ih := ""
    }
}

; ══════════════════════════════════════════════════════════════════
; MODUŁ MANUAL BOB — GUI
; Naciśnij E → Esc (0.1s) → R (0.1s) → Enter (0.1s) = respawn
; Zlicza kliknięcia i szacuje szansę na Boba
; ══════════════════════════════════════════════════════════════════
global MB_wh_URL, MB_wh_CD
global MB_adv_Hotkey, MB_adv_PreEscSleep, MB_adv_EscSleep, MB_adv_RSleep, MB_adv_EnterSleep
global MB_apC, MB_dzC, MB_siI_ctrl

BuildManualBobGUI() {
    global gui1, statusText, gameText
    global MB_clickText, MB_totalText, MB_timerText, MB_cphText, MB_bobText, MB_estText
    global MB_totalClicks, MB_BOB_DENOM

    W := 300
    gui1 := Gui("+AlwaysOnTop -MaximizeBox", "Manual Bob — " APP_VERSION)
    gui1.BackColor := "0A0C12"
    gui1.MarginX := 16
    gui1.MarginY := 14
    gui1.OnEvent("Close", (*) => gui1.Hide())

    gui1.SetFont("s12 Bold cF1F5F9", "Segoe UI")
    gui1.AddText("xm y14 w" W-32 " Center", "🖐  Manual Bob")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gui1.AddText("xm y+2 w" W-32 " Center", APP_NAME "  ·  " APP_VERSION)
    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    gui1.SetFont("s9 Bold cF87171", "Segoe UI")
    statusText := gui1.AddText("xm y+8 w" (W-32)//2, "● ZATRZYMANE")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gameText := gui1.AddText("x+0 yp w" (W-32)//2 " Right", "Gra —")
    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    LW := 155
    VW := W-32-LW-2

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+10 w" LW, "Kliknięcia sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    MB_clickText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Znalezione Boby")
    gui1.SetFont("s8 Bold cA78BFA", "Segoe UI")
    MB_bobText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Szacowane Boby")
    gui1.SetFont("s8 Bold c4ADE80", "Segoe UI")
    MB_estText := gui1.AddText("x+2 yp w" VW " Right", "0.000")

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Czas sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    MB_timerText := gui1.AddText("x+2 yp w" VW " Right", "00:00:00")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Kliki/godz.")
    gui1.SetFont("s8 c6366F1", "Segoe UI")
    MB_cphText := gui1.AddText("x+2 yp w" VW " Right", "—")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Kliki łącznie")
    gui1.SetFont("s8 c818CF8", "Segoe UI")
    MB_totalText := gui1.AddText("x+2 yp w" VW " Right", FormatLoops(MB_totalClicks))

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Szansa na Boba")
    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("x+2 yp w" VW " Right", "1/" MB_BOB_DENOM)

    gui1.SetFont("s7 cFBBF24", "Segoe UI")
    mbHkLabel := gui1.AddText("xm y+8 w" W-32 " Center", "[ " StrUpper(MB_hotkey) " ] = Esc → R → Enter (respawn)")

    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    BW := (W-32-8)//2
    gui1.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    sBtn := gui1.AddButton("xm y+10 w" BW " h30", "▶  Start")
    eBtn := gui1.AddButton("x+8 yp w" BW " h30",  "■  Stop")
    gui1.SetFont("s8 c64748B", "Segoe UI")
    tBtn := gui1.AddButton("xm y+6 w" BW " h24", "⚙  Ustawienia")
    hBtn := gui1.AddButton("x+8 yp w" BW " h24", "📋  Historia")
    gui1.SetFont("s7 c334155", "Segoe UI")
    gui1.AddText("xm y+10 w" W-32 " Center", "F6 start/stop   F9 panic   F8 wyjście")

    sBtn.OnEvent("Click", StartMacro)
    eBtn.OnEvent("Click", StopMacro)
    tBtn.OnEvent("Click", OpenManualBobSettings)
    hBtn.OnEvent("Click", OpenManualBobHistory)

    gui1.Show("w" W)
}

UpdateManualBobStats(elapsed) {
    global MB_clickText, MB_totalText, MB_timerText, MB_cphText, MB_bobText, MB_estText
    global MB_clickCount, MB_totalClicks, MB_bobHits, MB_BOB_DENOM
    try {
        MB_clickText.Text  := FormatLoops(MB_clickCount)
        MB_bobText.Text    := String(MB_bobHits)
        MB_estText.Text    := Format("{:.3f}", MB_clickCount * (1/MB_BOB_DENOM))
        MB_timerText.Text  := FormatTime2(elapsed)
        MB_totalText.Text  := FormatLoops(MB_totalClicks)
        h := elapsed / 3600000
        MB_cphText.Text    := (h > 0.001) ? Format("{:.0f}", MB_clickCount/h) : "—"
    }
}

; Hotkey trigger — wywoływany po naciśnięciu E gdy moduł aktywny
ManualBobTrigger(*) {
    global running, paused, sessionStart
    global MB_clickCount, MB_totalClicks, MB_bobHits, MB_BOB_DENOM
    global MB_webhook, MB_whCooldown, MB_lastWH
    global MB_IniFile, hwid

    if (!running || paused)
        return

    ; Odczytaj timingowe parametry z INI (live)
    preEscSleep := SafeNum(IniRead(MB_IniFile, "Zaawansowane", "PreEscSleep", "0"),   0)
    escSleep   := SafeNum(IniRead(MB_IniFile, "Zaawansowane", "EscSleep",   "100"), 100)
    rSleep     := SafeNum(IniRead(MB_IniFile, "Zaawansowane", "RSleep",     "100"), 100)
    enterSleep := SafeNum(IniRead(MB_IniFile, "Zaawansowane", "EnterSleep", "100"), 100)
    dzwiek     := SafeNum(IniRead(MB_IniFile, "Makro",        "DzwiekBob",  "1"),   1)
    statsInterval := SafeNum(IniRead(MB_IniFile, "Makro", "InterwalStatystyk", "100"), 100)
    MB_BOB_DENOM  := SafeNum(IniRead(MB_IniFile, "Debug", "BobDenom", "7500"), 7500)

    ; Sekwencja respawn: [sleep] → Esc → [sleep] → R → [sleep] → Enter
    if (preEscSleep > 0)
        Sleep preEscSleep
    SendInput "{Escape}"
    Sleep escSleep
    SendInput "r"
    Sleep rSleep
    SendInput "{Enter}"
    Sleep enterSleep

    MB_clickCount++
    MB_totalClicks++

    ; Szansa na Boba
    if (Random(1, MB_BOB_DENOM) = 1) {
        MB_bobHits++
        if dzwiek {
            Loop 3 {
                SoundPlay "*16"
                Sleep 400
            }
        }
        est := Format("{:.3f}", MB_clickCount * (1/MB_BOB_DENOM))
        st  := FormatTime2(A_TickCount - sessionStart)
        MB_lastWH := A_TickCount
        PostWebhook(MB_webhook, "ZNALEZIONO BOBA! (Manual Bob)`nKliki: " MB_clickCount "`nBoby: " MB_bobHits "`nSzac.: " est "`nCzas: " st "`nHWID: " hwid)
    }

    ; Cykliczne statystyki
    if (Mod(MB_clickCount, statsInterval) = 0) {
        now := A_TickCount
        if (MB_webhook != "") && (now - MB_lastWH >= MB_whCooldown) {
            MB_lastWH := now
            est := Format("{:.3f}", MB_clickCount * (1/MB_BOB_DENOM))
            st  := FormatTime2(A_TickCount - sessionStart)
            h   := (A_TickCount - sessionStart) / 3600000
            cph := (h > 0) ? Format("{:.0f}", MB_clickCount/h) : "—"
            PostWebhook(MB_webhook, "Statystyki Manual Bob`nKliki: " MB_clickCount "`nBoby: " MB_bobHits "`nSzac.: " est "`nKliki/h: " cph "`nCzas: " st)
        }
    }

    UpdateManualBobStats(A_TickCount - sessionStart)
}

; ══════════════════════════════════════════════════════════════════
; MANUAL BOB — USTAWIENIA
; ══════════════════════════════════════════════════════════════════
OpenManualBobSettings(*) {
    global MB_IniFile, gui1
    global MB_wh_URL, MB_wh_CD, MB_adv_Hotkey, MB_adv_PreEscSleep, MB_adv_EscSleep, MB_adv_RSleep, MB_adv_EnterSleep
    global MB_apC, MB_dzC, MB_siI_ctrl

    LW := 185
    VW := 340 - LW - 8

    gsM := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Ustawienia — Manual Bob")
    gsM.BackColor := "0A0C12"
    gsM.MarginX := 16
    gsM.MarginY := 10

    gsM.SetFont("s10 Bold cF1F5F9", "Segoe UI")
    gsM.AddText("xm y10 w340 Center", "Ustawienia — Manual Bob")

    ; OPCJE
    gsM.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsM.AddText("xm y+10 w340", "OPCJE")
    gsM.AddText("xm y+3 w340 h1 0x10", "")
    gsM.SetFont("s8 c64748B", "Segoe UI")
    MB_apC := gsM.AddCheckbox("xm y+6 w340 c94A3B8", "Auto-pauza gdy gra nieaktywna")
    MB_apC.Value := SafeNum(IniRead(MB_IniFile, "Makro", "AutoPauza", "1"), 1)
    MB_dzC := gsM.AddCheckbox("xm y+4 w340 c94A3B8", "Dzwiek przy znalezieniu Boba")
    MB_dzC.Value := SafeNum(IniRead(MB_IniFile, "Makro", "DzwiekBob", "1"), 1)

    ; ZAAWANSOWANE
    gsM.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsM.AddText("xm y+10 w340", "ZAAWANSOWANE")
    gsM.AddText("xm y+3 w340 h1 0x10", "")
    gsM.SetFont("s8 c64748B", "Segoe UI")
    gsM.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsM.AddText("xm y+4 w340", "  Klawisz wyzwalacza")
    gsM.SetFont("s8 c64748B", "Segoe UI")
    gsM.AddText("xm y+4 w" LW, "Aktualny klawisz:")
    MB_adv_Hotkey := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200 ReadOnly", IniRead(MB_IniFile, "Zaawansowane", "Hotkey", "e"))
    gsM.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    mbPickBtn := gsM.AddButton("xm y+4 w340 h26", "🎯  Kliknij i naciśnij klawisz / przycisk myszy")
    mbPickBtn.OnEvent("Click", (*) => MB_PickHotkey(gsM))
    gsM.SetFont("s8 c64748B", "Segoe UI")
    gsM.AddText("xm y+6 w" LW, "Sleep PRZED Esc (ms) [0]:")
    MB_adv_PreEscSleep := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(MB_IniFile, "Zaawansowane", "PreEscSleep", "0"))
    gsM.AddText("xm y+4 w" LW, "Sleep po Esc (ms) [100]:")
    MB_adv_EscSleep := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(MB_IniFile, "Zaawansowane", "EscSleep", "100"))
    gsM.AddText("xm y+4 w" LW, "Sleep po R (ms) [100]:")
    MB_adv_RSleep := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(MB_IniFile, "Zaawansowane", "RSleep", "100"))
    gsM.AddText("xm y+4 w" LW, "Sleep po Enter (ms) [100]:")
    MB_adv_EnterSleep := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(MB_IniFile, "Zaawansowane", "EnterSleep", "100"))

    ; WEBHOOK
    gsM.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsM.AddText("xm y+10 w340", "WEBHOOK STATYSTYK")
    gsM.AddText("xm y+3 w340 h1 0x10", "")
    gsM.SetFont("s8 c64748B", "Segoe UI")
    gsM.AddText("xm y+4 w" LW, "URL webhooka statystyk:")
    MB_wh_URL := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(MB_IniFile, "Webhook", "URL", ""))
    gsM.AddText("xm y+4 w" LW, "Cooldown webhooka (ms) [5000]:")
    MB_wh_CD := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(MB_IniFile, "Webhook", "Cooldown", "5000"))
    gsM.AddText("xm y+4 w" LW, "Co ile klikniecia wysylac stats:")
    MB_siI_ctrl := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(MB_IniFile, "Makro", "InterwalStatystyk", "100"))

    ; DEBUGOWANIE
    gsM.SetFont("s7 Bold cF87171", "Segoe UI")
    gsM.AddText("xm y+10 w340", "DEBUGOWANIE")
    gsM.AddText("xm y+3 w340 h1 0x10", "")
    gsM.SetFont("s7 c94A3B8", "Segoe UI")
    gsM.AddText("xm y+3 w340", "Krytyczne — bledna wartosc zniszczy makro.")
    gsM.SetFont("s8 c64748B", "Segoe UI")
    gsM.AddText("xm y+6 w" LW, "Kod PIN:")
    dbPinM := gsM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200 Password")
    gsM.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    dbBtnM := gsM.AddButton("xm y+6 w340 h26", "Odblokuj sekcje debugowania")
    dbBtnM.OnEvent("Click", (*) => OpenManualBobDebug(gsM, dbPinM.Value))

    gsM.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    svM := gsM.AddButton("xm y+10 w340 h30", "Zapisz ustawienia")
    svM.OnEvent("Click", SaveManualBobSettings)
    gsM.Show("w372")
}

OpenManualBobDebug(parentGui, enteredPin) {
    global debugCode, MB_IniFile, webhookHWID, jsonURL, MB_BOB_DENOM
    if (enteredPin != debugCode) {
        MsgBox "Nieprawidlowy kod PIN.", "Debugowanie", 48
        return
    }
    gdM := Gui("+AlwaysOnTop +Owner" parentGui.Hwnd, "Debugowanie — Manual Bob")
    gdM.BackColor := "0A0C12"
    gdM.MarginX := 16
    gdM.MarginY := 10
    LW := 185
    VW := 340 - LW - 8

    gdM.SetFont("s9 Bold cF87171", "Segoe UI")
    gdM.AddText("xm y10 w340 Center", "SEKCJA DEBUGOWANIA")
    gdM.SetFont("s7 c94A3B8", "Segoe UI")
    gdM.AddText("xm y+4 w340 Center", "UWAGA: bledna zmiana = makro przestanie dzialac!")
    gdM.AddText("xm y+8 w340 h1 0x10", "")

    gdM.SetFont("s7 Bold cF87171", "Segoe UI")
    gdM.AddText("xm y+8 w340", "  Licencja i HWID")
    gdM.SetFont("s8 c64748B", "Segoe UI")
    gdM.AddText("xm y+4 w" LW, "URL JSON licencji:")
    dbJsonM := gdM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", jsonURL)
    gdM.AddText("xm y+4 w" LW, "Webhook HWID (rejestracja):")
    dbWHM := gdM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", webhookHWID)

    gdM.SetFont("s7 Bold cF87171", "Segoe UI")
    gdM.AddText("xm y+8 w340", "  Szansa na Boba")
    gdM.SetFont("s8 c64748B", "Segoe UI")
    gdM.AddText("xm y+4 w" LW, "Mianownik szansy (1/X) [7500]:")
    dbBobDenomM := gdM.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", String(MB_BOB_DENOM))

    gdM.SetFont("s9 Bold cF87171", "Segoe UI")
    svDbM := gdM.AddButton("xm y+14 w340 h28", "Zapisz ustawienia debugowania")
    svDbM.OnEvent("Click", (*) => SaveManualBobDebug(dbJsonM.Value, dbWHM.Value, dbBobDenomM.Value))
    gdM.SetFont("s8 c64748B", "Segoe UI")
    gdM.AddButton("xm y+5 w340 h24", "Zamknij").OnEvent("Click", (*) => gdM.Destroy())
    gdM.Show("w372")
}

SaveManualBobDebug(newJson, newWH, newBobDenom) {
    global jsonURL, webhookHWID, MB_IniFile, MB_BOB_DENOM
    jsonURL      := newJson
    webhookHWID  := newWH
    MB_BOB_DENOM := SafeNum(newBobDenom, 7500)
    IniWrite newBobDenom, MB_IniFile, "Debug", "BobDenom"
    MsgBox "Ustawienia debugowania zapisane.", "Debugowanie", 64
}

MB_PickHotkey(parentGui) {
    global MB_adv_Hotkey
    WKP_Open(parentGui.Hwnd, MB_adv_Hotkey)
}

CG_PickHotkey(parentGui) {
    global CG_adv_Hotkey
    WKP_Open(parentGui.Hwnd, CG_adv_Hotkey)
}

SaveManualBobSettings(*) {
    global MB_IniFile, MB_webhook, MB_whCooldown, MB_hotkey
    global MB_wh_URL, MB_wh_CD, MB_adv_Hotkey, MB_adv_PreEscSleep, MB_adv_EscSleep, MB_adv_RSleep, MB_adv_EnterSleep
    global MB_apC, MB_dzC, MB_siI_ctrl
    IniWrite MB_apC.Value,            MB_IniFile, "Makro",        "AutoPauza"
    IniWrite MB_dzC.Value,            MB_IniFile, "Makro",        "DzwiekBob"
    IniWrite MB_siI_ctrl.Value,       MB_IniFile, "Makro",        "InterwalStatystyk"
    newHK := Trim(MB_adv_Hotkey.Value)
    if (newHK = "")
        newHK := "e"
    ; Jeśli makro działa — przestaw hotkey w locie
    if running && (activeModule = "manualbob") {
        try Hotkey MB_hotkey, ManualBobTrigger, "Off"
        MB_hotkey := newHK
        try Hotkey MB_hotkey, ManualBobTrigger, "On"
    } else {
        MB_hotkey := newHK
    }
    IniWrite newHK,                   MB_IniFile, "Zaawansowane", "Hotkey"
    IniWrite MB_adv_PreEscSleep.Value, MB_IniFile, "Zaawansowane", "PreEscSleep"
    IniWrite MB_adv_EscSleep.Value,   MB_IniFile, "Zaawansowane", "EscSleep"
    IniWrite MB_adv_RSleep.Value,     MB_IniFile, "Zaawansowane", "RSleep"
    IniWrite MB_adv_EnterSleep.Value, MB_IniFile, "Zaawansowane", "EnterSleep"
    IniWrite MB_wh_URL.Value,         MB_IniFile, "Webhook",      "URL"
    IniWrite MB_wh_CD.Value,          MB_IniFile, "Webhook",      "Cooldown"
    MB_webhook    := MB_wh_URL.Value
    MB_whCooldown := SafeNum(MB_wh_CD.Value, 5000)
    MsgBox "Ustawienia zapisane!", APP_NAME, 64
}

OpenManualBobHistory(*) {
    global MB_HistFile, gui1
    if !FileExist(MB_HistFile) {
        MsgBox "Brak historii.", APP_NAME, 64
        return
    }
    content := FileRead(MB_HistFile)
    ghM := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Historia — Manual Bob")
    ghM.BackColor := "0A0C12"
    ghM.MarginX := 14
    ghM.MarginY := 14
    ghM.SetFont("s8 cF1F5F9", "Segoe UI")
    eM := ghM.AddEdit("xm y14 w540 h300 ReadOnly Background12151F cF1F5F9 -E0x200", content)
    ghM.SetFont("s8 c64748B", "Segoe UI")
    c1 := ghM.AddButton("xm y+8 w265 h24", "Wyczysc")
    c2 := ghM.AddButton("x+10 yp w265 h24", "Zamknij")
    c1.OnEvent("Click", (*) => (FileDelete(MB_HistFile), eM.Value := "", MsgBox("Wyczyszczono.", APP_NAME, 64)))
    c2.OnEvent("Click", (*) => ghM.Destroy())
    ghM.Show("w568")
}

; ══════════════════════════════════════════════════════════════════
; MODUŁ CRITICAL GLOVE — GUI
; PPM → SendInput Space → sleep → Click (LPM)
; Działa jako remap: PPM nie jest przekazywany, zamiast tego
; wykonuje combo Spacja + LPM.
; ══════════════════════════════════════════════════════════════════
global CG_wh_URL, CG_wh_CD
global CG_adv_Hotkey, CG_adv_SpaceSleep, CG_adv_ClickSleep_ctrl
global CG_apC_ctrl, CG_siI_ctrl2

BuildCritGloveGUI() {
    global gui1, statusText, gameText
    global CG_clickText, CG_totalText, CG_timerText, CG_cphText
    global CG_totalClicks

    W := 300
    gui1 := Gui("+AlwaysOnTop -MaximizeBox", "Critical Glove — " APP_VERSION)
    gui1.BackColor := "0A0C12"
    gui1.MarginX := 16
    gui1.MarginY := 14
    gui1.OnEvent("Close", (*) => gui1.Hide())

    gui1.SetFont("s12 Bold cF1F5F9", "Segoe UI")
    gui1.AddText("xm y14 w" W-32 " Center", "💥  Critical Glove")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gui1.AddText("xm y+2 w" W-32 " Center", APP_NAME "  ·  " APP_VERSION)
    gui1.AddText("xm y+10 w" W-32 " h1 0x10", "")

    gui1.SetFont("s9 Bold cF87171", "Segoe UI")
    statusText := gui1.AddText("xm y+8 w" (W-32)//2, "● ZATRZYMANE")
    gui1.SetFont("s7 c64748B", "Segoe UI")
    gameText := gui1.AddText("x+0 yp w" (W-32)//2 " Right", "Gra —")
    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    LW := 155
    VW := W-32-LW-2

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+10 w" LW, "Kliki sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    CG_clickText := gui1.AddText("x+2 yp w" VW " Right", "0")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Kliki łącznie")
    gui1.SetFont("s8 c818CF8", "Segoe UI")
    CG_totalText := gui1.AddText("x+2 yp w" VW " Right", FormatLoops(CG_totalClicks))

    gui1.SetFont("s8 c64748B", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Czas sesji")
    gui1.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    CG_timerText := gui1.AddText("x+2 yp w" VW " Right", "00:00:00")

    gui1.SetFont("s8 c334155", "Segoe UI")
    gui1.AddText("xm y+5 w" LW, "Kliki/godz.")
    gui1.SetFont("s8 c6366F1", "Segoe UI")
    CG_cphText := gui1.AddText("x+2 yp w" VW " Right", "—")

    gui1.SetFont("s7 cFBBF24", "Segoe UI")
    cgHkLabel := gui1.AddText("xm y+8 w" W-32 " Center", "[ " StrUpper(CG_hotkey) " ] = Spacja + LPM (crit combo)")

    gui1.AddText("xm y+8 w" W-32 " h1 0x10", "")

    BW := (W-32-8)//2
    gui1.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    sBtn := gui1.AddButton("xm y+10 w" BW " h30", "▶  Start")
    eBtn := gui1.AddButton("x+8 yp w" BW " h30",  "■  Stop")
    gui1.SetFont("s8 c64748B", "Segoe UI")
    tBtn := gui1.AddButton("xm y+6 w" BW " h24", "⚙  Ustawienia")
    hBtn := gui1.AddButton("x+8 yp w" BW " h24", "📋  Historia")
    gui1.SetFont("s7 c334155", "Segoe UI")
    gui1.AddText("xm y+10 w" W-32 " Center", "F6 start/stop   F9 panic   F8 wyjście")

    sBtn.OnEvent("Click", StartMacro)
    eBtn.OnEvent("Click", StopMacro)
    tBtn.OnEvent("Click", OpenCritGloveSettings)
    hBtn.OnEvent("Click", OpenCritGloveHistory)

    gui1.Show("w" W)
}

UpdateCritGloveStats(elapsed) {
    global CG_clickText, CG_totalText, CG_timerText, CG_cphText
    global CG_clickCount, CG_totalClicks
    try {
        CG_clickText.Text  := FormatLoops(CG_clickCount)
        CG_totalText.Text  := FormatLoops(CG_totalClicks)
        CG_timerText.Text  := FormatTime2(elapsed)
        h := elapsed / 3600000
        CG_cphText.Text    := (h > 0.001) ? Format("{:.0f}", CG_clickCount/h) : "—"
    }
}

; Hotkey trigger — PPM → Spacja + LPM
CritGloveTrigger(*) {
    global running, paused, sessionStart
    global CG_clickCount, CG_totalClicks
    global CG_webhook, CG_whCooldown, CG_lastWH
    global CG_IniFile, hwid

    if (!running || paused)
        return

    ; Odczytaj timingowe z INI
    spaceSleep := SafeNum(IniRead(CG_IniFile, "Zaawansowane", "SpaceSleep", "50"), 50)
    clickSleep := SafeNum(IniRead(CG_IniFile, "Zaawansowane", "ClickSleep", "30"), 30)
    statsInterval := SafeNum(IniRead(CG_IniFile, "Makro", "InterwalStatystyk", "100"), 100)

    ; Combo: Spacja (skok) → sleep → LPM w miejscu kursora (crit)
    ; SendInput wysyła do aktywnego okna, {LButton} klika w miejscu kursora
    SendInput "{Space down}"
    Sleep spaceSleep
    SendInput "{Space up}"
    SendInput "{LButton down}"
    Sleep clickSleep
    SendInput "{LButton up}"

    CG_clickCount++
    CG_totalClicks++

    ; Statystyki cykliczne
    if (Mod(CG_clickCount, statsInterval) = 0) {
        now := A_TickCount
        if (CG_webhook != "") && (now - CG_lastWH >= CG_whCooldown) {
            CG_lastWH := now
            st  := FormatTime2(A_TickCount - sessionStart)
            h   := (A_TickCount - sessionStart) / 3600000
            cph := (h > 0) ? Format("{:.0f}", CG_clickCount/h) : "—"
            PostWebhook(CG_webhook, "Statystyki Critical Glove`nKliki: " CG_clickCount "`nKliki/h: " cph "`nCzas: " st)
        }
    }

    UpdateCritGloveStats(A_TickCount - sessionStart)
}

; ══════════════════════════════════════════════════════════════════
; CRITICAL GLOVE — USTAWIENIA
; ══════════════════════════════════════════════════════════════════
OpenCritGloveSettings(*) {
    global CG_IniFile, gui1
    global CG_wh_URL, CG_wh_CD, CG_adv_Hotkey, CG_adv_SpaceSleep, CG_adv_ClickSleep_ctrl
    global CG_apC_ctrl, CG_siI_ctrl2

    LW := 185
    VW := 340 - LW - 8

    gsC := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Ustawienia — Critical Glove")
    gsC.BackColor := "0A0C12"
    gsC.MarginX := 16
    gsC.MarginY := 10

    gsC.SetFont("s10 Bold cF1F5F9", "Segoe UI")
    gsC.AddText("xm y10 w340 Center", "Ustawienia — Critical Glove")

    ; OPCJE
    gsC.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsC.AddText("xm y+10 w340", "OPCJE")
    gsC.AddText("xm y+3 w340 h1 0x10", "")
    gsC.SetFont("s8 c64748B", "Segoe UI")
    CG_apC_ctrl := gsC.AddCheckbox("xm y+6 w340 c94A3B8", "Auto-pauza gdy gra nieaktywna")
    CG_apC_ctrl.Value := SafeNum(IniRead(CG_IniFile, "Makro", "AutoPauza", "1"), 1)

    ; ZAAWANSOWANE
    gsC.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsC.AddText("xm y+10 w340", "ZAAWANSOWANE")
    gsC.AddText("xm y+3 w340 h1 0x10", "")
    gsC.SetFont("s7 c94A3B8", "Segoe UI")
    gsC.AddText("xm y+3 w340", "Sleep po Spacji = opoznienie przed kliknieciem LPM.")
    gsC.SetFont("s8 c64748B", "Segoe UI")
    gsC.SetFont("s7 Bold cFBBF24", "Segoe UI")
    gsC.AddText("xm y+4 w340", "  Klawisz wyzwalacza")
    gsC.SetFont("s8 c64748B", "Segoe UI")
    gsC.AddText("xm y+4 w" LW, "Aktualny klawisz:")
    CG_adv_Hotkey := gsC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200 ReadOnly", IniRead(CG_IniFile, "Zaawansowane", "Hotkey", "RButton"))
    gsC.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    cgPickBtn := gsC.AddButton("xm y+4 w340 h26", "🎯  Kliknij i naciśnij klawisz / przycisk myszy")
    cgPickBtn.OnEvent("Click", (*) => CG_PickHotkey(gsC))
    gsC.SetFont("s8 c64748B", "Segoe UI")
    gsC.AddText("xm y+6 w" LW, "Sleep po Spacji (ms) [50]:")
    CG_adv_SpaceSleep := gsC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(CG_IniFile, "Zaawansowane", "SpaceSleep", "50"))
    gsC.AddText("xm y+4 w" LW, "Sleep po LPM (ms) [30]:")
    CG_adv_ClickSleep_ctrl := gsC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(CG_IniFile, "Zaawansowane", "ClickSleep", "30"))

    ; WEBHOOK
    gsC.SetFont("s7 Bold c6366F1", "Segoe UI")
    gsC.AddText("xm y+10 w340", "WEBHOOK STATYSTYK")
    gsC.AddText("xm y+3 w340 h1 0x10", "")
    gsC.SetFont("s8 c64748B", "Segoe UI")
    gsC.AddText("xm y+4 w" LW, "URL webhooka statystyk:")
    CG_wh_URL := gsC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(CG_IniFile, "Webhook", "URL", ""))
    gsC.AddText("xm y+4 w" LW, "Cooldown webhooka (ms) [5000]:")
    CG_wh_CD := gsC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(CG_IniFile, "Webhook", "Cooldown", "5000"))
    gsC.AddText("xm y+4 w" LW, "Co ile klikniecia wysylac stats:")
    CG_siI_ctrl2 := gsC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", IniRead(CG_IniFile, "Makro", "InterwalStatystyk", "100"))

    ; DEBUGOWANIE
    gsC.SetFont("s7 Bold cF87171", "Segoe UI")
    gsC.AddText("xm y+10 w340", "DEBUGOWANIE")
    gsC.AddText("xm y+3 w340 h1 0x10", "")
    gsC.SetFont("s7 c94A3B8", "Segoe UI")
    gsC.AddText("xm y+3 w340", "Krytyczne — bledna wartosc zniszczy makro.")
    gsC.SetFont("s8 c64748B", "Segoe UI")
    gsC.AddText("xm y+6 w" LW, "Kod PIN:")
    dbPinC := gsC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200 Password")
    gsC.SetFont("s8 Bold cF1F5F9", "Segoe UI")
    dbBtnC := gsC.AddButton("xm y+6 w340 h26", "Odblokuj sekcje debugowania")
    dbBtnC.OnEvent("Click", (*) => OpenCritGloveDebug(gsC, dbPinC.Value))

    gsC.SetFont("s9 Bold cF1F5F9", "Segoe UI")
    svC := gsC.AddButton("xm y+10 w340 h30", "Zapisz ustawienia")
    svC.OnEvent("Click", SaveCritGloveSettings)
    gsC.Show("w372")
}

OpenCritGloveDebug(parentGui, enteredPin) {
    global debugCode, CG_IniFile, webhookHWID, jsonURL
    if (enteredPin != debugCode) {
        MsgBox "Nieprawidlowy kod PIN.", "Debugowanie", 48
        return
    }
    gdC := Gui("+AlwaysOnTop +Owner" parentGui.Hwnd, "Debugowanie — Critical Glove")
    gdC.BackColor := "0A0C12"
    gdC.MarginX := 16
    gdC.MarginY := 10
    LW := 185
    VW := 340 - LW - 8

    gdC.SetFont("s9 Bold cF87171", "Segoe UI")
    gdC.AddText("xm y10 w340 Center", "SEKCJA DEBUGOWANIA")
    gdC.SetFont("s7 c94A3B8", "Segoe UI")
    gdC.AddText("xm y+4 w340 Center", "UWAGA: bledna zmiana = makro przestanie dzialac!")
    gdC.AddText("xm y+8 w340 h1 0x10", "")

    gdC.SetFont("s7 Bold cF87171", "Segoe UI")
    gdC.AddText("xm y+8 w340", "  Licencja i HWID")
    gdC.SetFont("s8 c64748B", "Segoe UI")
    gdC.AddText("xm y+4 w" LW, "URL JSON licencji:")
    dbJsonC := gdC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", jsonURL)
    gdC.AddText("xm y+4 w" LW, "Webhook HWID (rejestracja):")
    dbWHC := gdC.AddEdit("x+8 yp w" VW " h20 Background1C2030 cF1F5F9 -E0x200", webhookHWID)

    gdC.SetFont("s9 Bold cF87171", "Segoe UI")
    svDbC := gdC.AddButton("xm y+14 w340 h28", "Zapisz ustawienia debugowania")
    svDbC.OnEvent("Click", (*) => SaveCritGloveDebug(dbJsonC.Value, dbWHC.Value))
    gdC.SetFont("s8 c64748B", "Segoe UI")
    gdC.AddButton("xm y+5 w340 h24", "Zamknij").OnEvent("Click", (*) => gdC.Destroy())
    gdC.Show("w372")
}

SaveCritGloveDebug(newJson, newWH) {
    global jsonURL, webhookHWID
    jsonURL     := newJson
    webhookHWID := newWH
    MsgBox "Ustawienia debugowania zapisane.", "Debugowanie", 64
}

SaveCritGloveSettings(*) {
    global CG_IniFile, CG_webhook, CG_whCooldown, CG_hotkey
    global CG_wh_URL, CG_wh_CD, CG_adv_Hotkey, CG_adv_SpaceSleep, CG_adv_ClickSleep_ctrl
    global CG_apC_ctrl, CG_siI_ctrl2
    IniWrite CG_apC_ctrl.Value,          CG_IniFile, "Makro",        "AutoPauza"
    IniWrite CG_siI_ctrl2.Value,         CG_IniFile, "Makro",        "InterwalStatystyk"
    newHK := Trim(CG_adv_Hotkey.Value)
    if (newHK = "")
        newHK := "RButton"
    if running && (activeModule = "critglove") {
        try Hotkey CG_hotkey, CritGloveTrigger, "Off"
        CG_hotkey := newHK
        try Hotkey CG_hotkey, CritGloveTrigger, "On"
    } else {
        CG_hotkey := newHK
    }
    IniWrite newHK,                       CG_IniFile, "Zaawansowane", "Hotkey"
    IniWrite CG_adv_SpaceSleep.Value,    CG_IniFile, "Zaawansowane", "SpaceSleep"
    IniWrite CG_adv_ClickSleep_ctrl.Value, CG_IniFile, "Zaawansowane", "ClickSleep"
    IniWrite CG_wh_URL.Value,            CG_IniFile, "Webhook",      "URL"
    IniWrite CG_wh_CD.Value,             CG_IniFile, "Webhook",      "Cooldown"
    CG_webhook    := CG_wh_URL.Value
    CG_whCooldown := SafeNum(CG_wh_CD.Value, 5000)
    MsgBox "Ustawienia zapisane!", APP_NAME, 64
}

OpenCritGloveHistory(*) {
    global CG_HistFile, gui1
    if !FileExist(CG_HistFile) {
        MsgBox "Brak historii.", APP_NAME, 64
        return
    }
    content := FileRead(CG_HistFile)
    ghC := Gui("+AlwaysOnTop +Owner" gui1.Hwnd, "Historia — Critical Glove")
    ghC.BackColor := "0A0C12"
    ghC.MarginX := 14
    ghC.MarginY := 14
    ghC.SetFont("s8 cF1F5F9", "Segoe UI")
    eC := ghC.AddEdit("xm y14 w540 h300 ReadOnly Background12151F cF1F5F9 -E0x200", content)
    ghC.SetFont("s8 c64748B", "Segoe UI")
    c1 := ghC.AddButton("xm y+8 w265 h24", "Wyczysc")
    c2 := ghC.AddButton("x+10 yp w265 h24", "Zamknij")
    c1.OnEvent("Click", (*) => (FileDelete(CG_HistFile), eC.Value := "", MsgBox("Wyczyszczono.", APP_NAME, 64)))
    c2.OnEvent("Click", (*) => ghC.Destroy())
    ghC.Show("w568")
}
