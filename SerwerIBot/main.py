import discord
from discord.ext import commands
import json
import random
import string
import os
import requests
from aiohttp import web
import asyncio
import re
from datetime import datetime

TOKEN            = os.environ.get("DISCORD_TOKEN", "")
JSON_FILE        = "licenses.json"
GIST_TOKEN       = os.environ.get("GIST_TOKEN", "")
GIST_ID          = os.environ.get("GIST_ID", "")
ADMIN_CHANNEL_ID = int(os.environ.get("ADMIN_CHANNEL_ID", "0"))

WEBHOOK_CATEGORY_NAME = "Webhooki"

intents = discord.Intents.default()
intents.message_content = True
intents.members = True          # wymagany do on_member_join (włącz w Dev Portal!)
bot = commands.Bot(command_prefix='.', intents=intents)

activity_log = []
ws_clients: set = set()


def log_activity(action, details):
    entry = {
        "time":    datetime.now().strftime("%H:%M:%S"),
        "date":    datetime.now().strftime("%Y-%m-%d"),
        "action":  action,
        "details": details,
    }
    activity_log.insert(0, entry)
    if len(activity_log) > 200:
        activity_log.pop()
    asyncio.ensure_future(_broadcast_ws())


async def _broadcast_ws():
    dead = set()
    for ws in ws_clients:
        try:
            await ws.send_json({"type": "update"})
        except Exception:
            dead.add(ws)
    ws_clients.difference_update(dead)


def load_licenses():
    if not os.path.exists(JSON_FILE):
        return {}
    with open(JSON_FILE, "r") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return {}


def save_licenses(data):
    with open(JSON_FILE, "w") as f:
        json.dump(data, f, indent=4)


def load_from_gist():
    """Pobiera licenses.json z Gist przy starcie bota."""
    if not all([GIST_TOKEN, GIST_ID]):
        print("Gist config missing, loading from local file.")
        return
    url     = f"https://api.github.com/gists/{GIST_ID}"
    headers = {
        "Authorization": f"token {GIST_TOKEN}",
        "Accept":        "application/vnd.github.v3+json",
    }
    try:
        r = requests.get(url, headers=headers, timeout=10)
        r.raise_for_status()
        content = r.json()["files"]["licenses.json"]["content"]
        data = json.loads(content)
        save_licenses(data)
        print(f"Gist sync: załadowano {len(data)} kluczy.")
    except Exception as e:
        print(f"Błąd ładowania z Gist: {e} — używam lokalnego pliku.")


async def save_licenses_async(data):
    """Zapisuje lokalnie i pushuje do Gist bez blokowania event loop."""
    save_licenses(data)
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, update_gist, data)


def update_gist(data):
    """Aktualizuje prywatny Gist z licenses.json (nie blokować async — używać przez executor)."""
    if not all([GIST_TOKEN, GIST_ID]):
        print("Gist config missing (GIST_TOKEN / GIST_ID), skipping.")
        return
    url     = f"https://api.github.com/gists/{GIST_ID}"
    headers = {
        "Authorization": f"token {GIST_TOKEN}",
        "Accept":        "application/vnd.github.v3+json",
    }
    payload = {
        "files": {
            "licenses.json": {
                "content": json.dumps(data, indent=4)
            }
        }
    }
    try:
        r = requests.patch(url, headers=headers, json=payload, timeout=10)
        print(f"Gist update: {r.status_code}")
    except Exception as e:
        print(f"Error updating Gist: {e}")


def generate_key():
    k = ''.join(random.choices(string.ascii_uppercase + string.digits, k=16))
    return '-'.join([k[i:i+4] for i in range(0, 16, 4)])


def parse_webhook_message(content: str) -> dict:
    """Parsuje wiadomości z makra AHK (NOWA AKTYWACJA)."""
    result = {}

    key_m = re.search(
        r'Klucz[:\s]+([A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4})',
        content)
    if key_m:
        result['key'] = key_m.group(1)

    hwid_m = re.search(r'HWID[:\s]+([A-F0-9\-]{30,})', content, re.IGNORECASE)
    if hwid_m:
        result['hwid'] = hwid_m.group(1).strip()

    debug_m = re.search(r'KodDebug[:\s]+([A-Z0-9]{4}-[A-Z0-9]{4})', content)
    if debug_m:
        result['debug_code'] = debug_m.group(1)

    if 'NOWA AKTYWACJA' in content:
        result['type'] = 'activation'

    return result


# ── Discord Commands ──────────────────────────────────────────────

@bot.command()
async def generate(ctx):
    data = load_licenses()
    key  = generate_key()
    data[key] = {"hwid": "", "banned": False, "note": "", "debug_code": ""}
    await save_licenses_async(data)
    log_activity("GENERATE", f"Klucz {key} wygenerowany przez {ctx.author}")
    await ctx.send(f"Nowy klucz: `{key}`")


@bot.command()
async def ban(ctx, key):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    data[key]["banned"] = True
    await save_licenses_async(data)
    log_activity("BAN", f"Klucz {key} zbanowany przez {ctx.author}")
    await ctx.send(f"Klucz `{key}` zbanowany")


@bot.command()
async def unban(ctx, key):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    data[key]["banned"] = False
    await save_licenses_async(data)
    log_activity("UNBAN", f"Klucz {key} odbanowany przez {ctx.author}")
    await ctx.send(f"Klucz `{key}` odbanowany")


@bot.command()
async def reset(ctx, key):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    data[key]["hwid"] = ""
    await save_licenses_async(data)
    log_activity("RESET", f"HWID klucza {key} zresetowany przez {ctx.author}")
    await ctx.send(f"HWID klucza `{key}` zresetowany")


@bot.command()
async def assign(ctx, key, hwid):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    data[key]["hwid"] = hwid
    await save_licenses_async(data)
    log_activity("ASSIGN", f"HWID {hwid[:12]}... przypisany do {key}")
    await ctx.send(f"HWID przypisany do klucza `{key}`")


@bot.command()
async def note(ctx, key, *, text):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    data[key]["note"] = text
    await save_licenses_async(data)
    log_activity("NOTE", f"Notatka klucza {key}: {text[:40]}")
    await ctx.send(f"Notatka klucza `{key}`:\n> {text}")


@bot.command()
async def clearnote(ctx, key):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    data[key]["note"] = ""
    await save_licenses_async(data)
    log_activity("NOTE", f"Notatka klucza {key} wyczyszczona przez {ctx.author}")
    await ctx.send(f"Notatka klucza `{key}` wyczyszczona")


@bot.command()
async def info(ctx, key):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    v      = data[key]
    status = "Zbanowany" if v.get("banned") else ("Aktywny" if v.get("hwid") else "Oczekuje")
    dc     = v.get("debug_code") or "brak"
    await ctx.send(
        f"**Klucz:** `{key}`\n"
        f"**Status:** {status}\n"
        f"**HWID:** `{v.get('hwid') or 'brak'}`\n"
        f"**Kod debug:** `{dc}`\n"
        f"**Notatka:** {v.get('note') or 'brak'}"
    )


@bot.command(name="list")
async def list_cmd(ctx):
    data = load_licenses()
    if not data:
        return await ctx.send("Brak kluczy.")
    lines = []
    for k, v in data.items():
        status     = "Ban" if v.get("banned") else ("OK" if v.get("hwid") else "??")
        hwid_short = (v.get("hwid", "")[:8] + "...") if v.get("hwid") else "brak"
        dc         = v.get("debug_code", "") or "-"
        note_s     = f" | {v.get('note','')[:20]}" if v.get("note") else ""
        lines.append(f"[{status}] `{k}` HWID:`{hwid_short}` Debug:`{dc}`{note_s}")
    header = f"**Klucze ({len(data)}):**\n"
    # Discord limit: 2000 znaków — wysyłaj w kawałkach
    chunk = header
    for line in lines:
        if len(chunk) + len(line) + 1 > 1900:
            await ctx.send(chunk)
            chunk = ""
        chunk += line + "\n"
    if chunk:
        await ctx.send(chunk)


@bot.command()
async def debugcode(ctx, key):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    code = data[key].get("debug_code", "")
    if code:
        await ctx.send(f"Kod debug klucza `{key}`: `{code}`")
    else:
        await ctx.send(
            f"Klucz `{key}` nie ma jeszcze kodu debug — uruchom makro przynajmniej raz."
        )


@bot.command()
async def delete(ctx, key):
    data = load_licenses()
    if key not in data:
        return await ctx.send("Nie znaleziono klucza")
    del data[key]
    await save_licenses_async(data)
    log_activity("DELETE", f"Klucz {key} usunięty przez {ctx.author}")
    await ctx.send(f"Klucz `{key}` usunięty")


# ── Webhook auto-handler ──────────────────────────────────────────

@bot.event
async def on_message(message):
    await bot.process_commands(message)

    # Tylko wiadomosci od innych botow (webhooki z makra)
    if not message.author.bot or message.author == bot.user:
        return

    parsed = parse_webhook_message(message.content)
    key   = parsed.get('key')
    hwid  = parsed.get('hwid')
    dc    = parsed.get('debug_code')
    mtype = parsed.get('type')

    if not key or mtype != 'activation':
        return

    data = load_licenses()

    if key not in data:
        await message.channel.send(
            f"Nieznany klucz: `{key}` — nie istnieje w bazie."
        )
        return

    changed = False
    notes   = []

    if hwid and not data[key].get('hwid'):
        data[key]['hwid'] = hwid
        log_activity("AUTO-ASSIGN", f"HWID {hwid[:12]}... => {key}")
        notes.append(f"HWID przypisany: `{hwid[:20]}...`")
        changed = True
    elif hwid:
        notes.append("HWID juz przypisany (bez zmian)")

    if dc and not data[key].get('debug_code'):
        data[key]['debug_code'] = dc
        log_activity("DEBUG-CODE", f"Kod debug {key}: {dc}")
        notes.append(f"Kod debug zapisany: `{dc}`")
        changed = True

    if changed:
        await save_licenses_async(data)
        print(f"[AUTO] {key}: {', '.join(notes)}")


# ── Web API ───────────────────────────────────────────────────────

async def handle_root(request):
    try:
        with open("panel.html", "r", encoding="utf-8") as f:
            return web.Response(text=f.read(), content_type="text/html")
    except Exception as e:
        return web.Response(text=f"Error: {e}", status=500)


async def handle_api_licenses(request):
    data = load_licenses()
    return web.json_response([
        {
            "key":        k,
            "hwid":       v.get("hwid", ""),
            "banned":     v.get("banned", False),
            "note":       v.get("note", ""),
            "debug_code": v.get("debug_code", ""),
            "active":     bool(v.get("hwid")) and not v.get("banned", False),
        }
        for k, v in data.items()
    ])


async def handle_api_log(request):
    return web.json_response(activity_log)


async def handle_api_stats(request):
    data    = load_licenses()
    total   = len(data)
    active  = sum(1 for v in data.values() if v.get("hwid") and not v.get("banned"))
    pending = sum(1 for v in data.values() if not v.get("hwid") and not v.get("banned"))
    banned  = sum(1 for v in data.values() if v.get("banned"))
    return web.json_response({"total": total, "active": active, "pending": pending, "banned": banned})


async def handle_api_generate(request):
    data = load_licenses()
    key  = generate_key()
    data[key] = {"hwid": "", "banned": False, "note": "", "debug_code": ""}
    await save_licenses_async(data)
    log_activity("GENERATE", f"Klucz {key} wygenerowany z panelu")
    return web.json_response({"key": key})


async def handle_api_action(request):
    try:
        body   = await request.json()
        action = body.get("action")
        key    = body.get("key")
        data   = load_licenses()

        if key not in data:
            return web.json_response({"error": "Klucz nie istnieje"}, status=404)

        if action == "ban":
            data[key]["banned"] = True
            log_activity("BAN", f"Klucz {key} zbanowany z panelu")
        elif action == "unban":
            data[key]["banned"] = False
            log_activity("UNBAN", f"Klucz {key} odbanowany z panelu")
        elif action == "reset":
            data[key]["hwid"] = ""
            log_activity("RESET", f"HWID klucza {key} zresetowany z panelu")
        elif action == "delete":
            del data[key]
            log_activity("DELETE", f"Klucz {key} usuniety z panelu")
        elif action == "note":
            data[key]["note"] = body.get("note", "")
            log_activity("NOTE", f"Notatka klucza {key}: {body.get('note','')[:40]}")
        elif action == "clear_debug":
            data[key]["debug_code"] = ""
            log_activity("DEBUG-CLEAR", f"Kod debug klucza {key} wyczyszczony")
        else:
            return web.json_response({"error": "Nieznana akcja"}, status=400)

        await save_licenses_async(data)
        return web.json_response({"ok": True})
    except Exception as e:
        return web.json_response({"error": str(e)}, status=500)


async def handle_ws(request):
    ws = web.WebSocketResponse()
    await ws.prepare(request)
    ws_clients.add(ws)
    try:
        async for _ in ws:
            pass
    finally:
        ws_clients.discard(ws)
    return ws


async def start_webserver():
    app = web.Application()
    app.router.add_get("/",             handle_root)
    app.router.add_get("/ws",           handle_ws)
    app.router.add_get("/api/licenses", handle_api_licenses)
    app.router.add_get("/api/log",      handle_api_log)
    app.router.add_get("/api/stats",    handle_api_stats)
    app.router.add_get("/api/generate", handle_api_generate)
    app.router.add_post("/api/action",  handle_api_action)
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, "0.0.0.0", 5000)
    await site.start()
    print("Panel dostepny na porcie 5000")


@bot.event
async def on_ready():
    print(f"Bot online: {bot.user}")
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, load_from_gist)
    await start_webserver()


# ── Auto-webhook przy dołączeniu do serwera ───────────────────────

@bot.event
async def on_member_join(member: discord.Member):
    guild = member.guild

    # Znajdź lub utwórz kategorię "Webhooki"
    category = discord.utils.get(guild.categories, name=WEBHOOK_CATEGORY_NAME)
    if category is None:
        category = await guild.create_category(WEBHOOK_CATEGORY_NAME)

    # Utwórz kanał  username_webhook  (discord wymaga małych liter / bez spacji)
    safe_name = re.sub(r'[^a-z0-9_]', '', member.name.lower()) or f"user{member.id}"
    channel_name = f"{safe_name}_webhook"

    # Jeśli kanał już istnieje — nie twórz duplikatu
    existing = discord.utils.get(guild.text_channels, name=channel_name, category=category)
    if existing:
        return

    # Uprawnienia: tylko bot + administrator widzą kanał
    overwrites = {
        guild.default_role: discord.PermissionOverwrite(read_messages=False),
        guild.me:           discord.PermissionOverwrite(read_messages=True,
                                                        send_messages=True,
                                                        manage_webhooks=True,
                                                        manage_messages=True),
    }
    channel = await guild.create_text_channel(channel_name,
                                               category=category,
                                               overwrites=overwrites,
                                               topic=f"Webhook kanał użytkownika {member}")

    # Utwórz webhook dla tego kanału
    webhook = await channel.create_webhook(name=f"{member.name} — SBMM")

    # Wyślij URL webhooka i przypnij wiadomość
    msg = await channel.send(
        f"**Webhook dla: {member.mention}**\n"
        f"```\n{webhook.url}\n```\n"
        f"Wklej ten URL w ustawieniach makra → Webhook → URL."
    )
    await msg.pin()
    log_activity("WEBHOOK-CREATE", f"Kanał {channel_name} + webhook dla {member}")


bot.run(TOKEN)
