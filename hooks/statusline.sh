#!/bin/bash
python3 - <<'EOF'
import json, os, re, time, urllib.request
from datetime import datetime, timezone

R  = "\033[0m"; B = "\033[1m"; D = "\033[2m"; G = "\033[32m"
Y  = "\033[33m"; Re = "\033[31m"; C = "\033[36m"; W = "\033[97m"

USAGE_API  = "https://claude.ai/api/oauth/usage"
CACHE_FILE = "/tmp/cc-statusline-cache.json"
CACHE_TTL  = 300  # 5 minutes

def load(path):
    try:
        with open(os.path.expanduser(path)) as f:
            return json.load(f)
    except Exception:
        return {}

def acc_name(acc):  return (acc.get("metadata") or {}).get("displayName", "?")

def minibar(pct, width=6):
    if pct is None: return D + "──────" + R
    filled = round(pct / 100 * width)
    color = G if pct <= 40 else Y if pct <= 75 else Re
    return color + "█" * filled + D + "░" * (width - filled) + R

def pct_color(pct):
    if pct is None: return D + "?%" + R
    c = G if pct <= 40 else Y if pct <= 75 else Re
    return c + B + f"{pct:.0f}%" + R

def fmt_reset(iso):
    if not iso: return None
    try:
        dt   = datetime.fromisoformat(iso.replace("Z", "+00:00"))
        diff = (dt - datetime.now(timezone.utc)).total_seconds()
        if diff <= 0: return "now"
        h, m = int(diff // 3600), int((diff % 3600) // 60)
        return f"{h}h{m:02d}m" if h else f"{m}m"
    except:
        return None

def fetch_usage(token):
    try:
        req = urllib.request.Request(USAGE_API,
            headers={"Authorization": f"Bearer {token}", "User-Agent": "claude-code/1.0"})
        with urllib.request.urlopen(req, timeout=4) as r:
            return json.loads(r.read())
    except Exception:
        return None

def get_usage(uid, token):
    cache = load(CACHE_FILE)
    entry = cache.get(uid, {})
    if entry.get("ts", 0) > time.time() - CACHE_TTL:
        return entry.get("data")
    data = fetch_usage(token)
    if data:
        cache[uid] = {"ts": time.time(), "data": data}
        try:
            with open(CACHE_FILE, "w") as f:
                json.dump(cache, f)
        except Exception:
            pass
    return data

store    = load("~/.ClaudeCodeMultiAccounts.json")
cfg      = load("~/.claude.json")
uid      = (cfg.get("oauthAccount") or {}).get("accountUuid")
accounts = store.get("accounts", [])

# Fallback: read uid from .credentials.json (new CC auth flow omits oauthAccount)
if not uid:
    try:
        import subprocess
        creds_raw = subprocess.check_output(
            ["security", "find-generic-password", "-s", "Claude Code-credentials", "-w"],
            stderr=subprocess.DEVNULL
        ).decode().strip()
        uid = json.loads(creds_raw).get("claudeAiOauth", {}).get("accountUuid")
    except Exception:
        pass
if not uid:
    creds = load("~/.claude/.credentials.json")
    uid = (creds.get("claudeAiOauth") or creds).get("accountUuid")

active = next((a for a in accounts if (a.get("metadata") or {}).get("accountUuid") == uid), None)

# ── Live usage for active account ──
a_fh_pct   = None
a_resets_at = None
if active and uid:
    token = (active.get("credentials", {}).get("claudeAiOauth", {}) or {}).get("accessToken")
    if token:
        usage = get_usage(uid, token)
        if usage and usage.get("five_hour"):
            a_fh_pct    = usage["five_hour"].get("utilization")
            a_resets_at = usage["five_hour"].get("resets_at")
    if a_fh_pct is None:
        snap = (active.get("usageSnapshot") or {}).get("five_hour") or {}
        a_fh_pct    = snap.get("utilization")
        a_resets_at = snap.get("resets_at")

# ── Other accounts from snapshot ──
def snap_fh_pct(acc):    return ((acc.get("usageSnapshot") or {}).get("five_hour") or {}).get("utilization")
def snap_resets_at(acc): return ((acc.get("usageSnapshot") or {}).get("five_hour") or {}).get("resets_at")

others = [a for a in accounts if (a.get("metadata") or {}).get("accountUuid") != uid]
usable = sorted([a for a in others if (snap_fh_pct(a) or 0) < 90], key=lambda a: snap_fh_pct(a) or 100)
free_count  = len(usable)
total_count = len(accounts)

# ── Active account ──
if not active:
    print(f"{D}no active account — run cc use <n>{R}")
    exit(0)
critical = (a_fh_pct or 0) >= 80
dot_c = Re if critical else (Y if (a_fh_pct or 0) >= 40 else G)
dot   = dot_c + ("⚠" if critical else "◉") + R
name  = (Re + B + acc_name(active) + R) if critical else (W + acc_name(active) + R)
cur   = f"{dot} {name} {minibar(a_fh_pct)} {pct_color(a_fh_pct)}"

reset_str = fmt_reset(a_resets_at)
if reset_str:
    cur += f"  {D}resets{R} {C}{reset_str}{R}"

sep = f"  {D}·{R}  "

# ── Available count ──
fc    = G if free_count >= 2 else Y if free_count == 1 else Re
avail = f"{fc}{B}{free_count}/{total_count}{R} {D}free{R}"

# ── Recommendation ──
if usable:
    nxt     = usable[0]
    idx     = accounts.index(nxt)
    nxt_pct = snap_fh_pct(nxt) or 0
    rec = f"{C}›{R} {D}[{idx}]{R} {acc_name(nxt)} {minibar(nxt_pct)} {pct_color(nxt_pct)}"
else:
    candidates = sorted(
        [(a, accounts.index(a)) for a in accounts if snap_resets_at(a)],
        key=lambda x: snap_resets_at(x[0])
    )
    if candidates:
        sa, si = candidates[0]
        try:
            dt   = datetime.fromisoformat(snap_resets_at(sa).replace("Z", "+00:00"))
            diff = (dt - datetime.now(timezone.utc)).total_seconds()
            t = "now" if diff <= 0 else (f"{int(diff//3600)}h{int((diff%3600)//60):02d}m" if diff >= 3600 else f"{int(diff//60)}m")
            rec = f"{Y}⏳{R} {D}[{si}]{R} {acc_name(sa)} {C}in {t}{R}"
        except Exception:
            rec = f"{Y}⏳ all full{R}"
    else:
        rec = f"{Y}⏳ all full{R}"

print(f"{cur}{sep}{avail}{sep}{rec}")
EOF
