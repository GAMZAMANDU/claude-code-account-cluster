#!/bin/bash
python3 - <<'EOF'
import json, os, re
from datetime import datetime, timezone

R  = "\033[0m"; B = "\033[1m"; D = "\033[2m"; G = "\033[32m"
Y  = "\033[33m"; Re = "\033[31m"; C = "\033[36m"; W = "\033[97m"

def load(path):
    try:
        with open(os.path.expanduser(path)) as f:
            return json.load(f)
    except Exception:
        return {}

def fh_pct(acc):    return ((acc.get("usageSnapshot") or {}).get("five_hour") or {}).get("utilization")
def resets_at(acc): return ((acc.get("usageSnapshot") or {}).get("five_hour") or {}).get("resets_at")
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

store    = load("~/.ClaudeCodeMultiAccounts.json")
cfg      = load("~/.claude.json")
uid      = (cfg.get("oauthAccount") or {}).get("accountUuid")
accounts = store.get("accounts", [])

active = next((a for a in accounts if (a.get("metadata") or {}).get("accountUuid") == uid), None)
a_pct  = fh_pct(active) if active else None

others = [a for a in accounts if (a.get("metadata") or {}).get("accountUuid") != uid]
usable = sorted([a for a in others if (fh_pct(a) or 0) < 90], key=lambda a: fh_pct(a) or 100)
free_count  = len(usable)
total_count = len(accounts)

# ── Active account ──
critical = (a_pct or 0) >= 80
dot_c = Re if critical else (Y if (a_pct or 0) >= 40 else G)
dot   = dot_c + ("⚠" if critical else "◉") + R
name  = (Re + B + acc_name(active) + R) if critical else (W + acc_name(active) + R)
cur   = f"{dot} {name} {minibar(a_pct)} {pct_color(a_pct)}"

reset_str = fmt_reset(resets_at(active)) if active else None
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
    nxt_pct = fh_pct(nxt) or 0
    rec = f"{C}›{R} {D}[{idx}]{R} {acc_name(nxt)} {minibar(nxt_pct)} {pct_color(nxt_pct)}"
else:
    candidates = sorted(
        [(a, accounts.index(a)) for a in accounts if resets_at(a)],
        key=lambda x: resets_at(x[0])
    )
    if candidates:
        sa, si = candidates[0]
        try:
            dt   = datetime.fromisoformat(resets_at(sa).replace("Z", "+00:00"))
            diff = (dt - datetime.now(timezone.utc)).total_seconds()
            t = "now" if diff <= 0 else (f"{int(diff//3600)}h{int((diff%3600)//60):02d}m" if diff >= 3600 else f"{int(diff//60)}m")
            rec = f"{Y}⏳{R} {D}[{si}]{R} {acc_name(sa)} {C}in {t}{R}"
        except Exception:
            rec = f"{Y}⏳ all full{R}"
    else:
        rec = f"{Y}⏳ all full{R}"

print(f"{cur}{sep}{avail}{sep}{rec}")
EOF
