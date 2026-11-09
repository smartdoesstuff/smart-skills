#!/usr/bin/env python3
"""ask-tkm: one scoped call to tokenme (OpenAI-compatible). stdlib only.
Usage: ask.py <find|think|draft> <brief-file> <tag> [context files...]
       [--model qwen|deepseek|gemma|<full-id>] [--think|--nothink] [--out PATH] [--force] [--max N] [--dry]
"""
import argparse, json, os, re, subprocess, sys, time
from pathlib import Path

URL = "https://api.tokenme.limited/api/v1/chat/completions"
MODELS = {"qwen": "unsloth/qwen3.8-27b-nvfp4", "deepseek": "deepseek-ai/deepseek-v4-flash-0731", "gemma": "google/gemma-4-31b-it"}
CTX = {"qwen": 262144, "gemma": 262144, "deepseek": 1048576}
# Stable system prefix + files first, brief last: tokenme prefix-caches, so repeat asks on the same files are cheap.
SYS = {
 "find": "Answer ONLY from the provided files. Cite file:line. If the answer is not in them say 'not in files'. Be terse: facts, no preamble.",
 "think": "Lead with your recommendation in one line, then at most 5 bullets of reasoning. State uncertainty and anything you could not verify. No preamble.",
 "draft": "Output ONLY the complete file content: no markdown fences, no commentary, no placeholders like '...'.",
}
MAXTOK = {"find": 2000, "think": 8000, "draft": 8000}  # max_tokens includes reasoning tokens
SECRET = re.compile(r"(^|/)(\.env[^/]*|id_[a-z0-9]+|[^/]*\.(pem|key|p12)|credentials[^/]*)$", re.I)
SETUP = """tokenme API key missing or rejected. Tell the user to set it up:
  1. Get/rotate a key from their tokenme account.
  2. export TOKENME_API_KEY=... in ~/.zshrc  (or: mkdir -p ~/.config/tokenme && printf %s KEY > ~/.config/tokenme/api-key && chmod 600 ~/.config/tokenme/api-key)
  3. Re-run. Smoke test: curl -s https://api.tokenme.limited/api/v1/models -H "Authorization: Bearer $TOKENME_API_KEY" | head -c 200"""

def die(msg, code=1): print(msg, file=sys.stderr); sys.exit(code)

a = argparse.ArgumentParser()
a.add_argument("mode", choices=SYS); a.add_argument("brief"); a.add_argument("tag"); a.add_argument("files", nargs="*")
a.add_argument("--model", default=os.environ.get("ASK_TKM_MODEL", "")); a.add_argument("--out"); a.add_argument("--force", action="store_true")
a.add_argument("--max", type=int); a.add_argument("--dry", action="store_true")
g = a.add_mutually_exclusive_group(); g.add_argument("--think", action="store_true"); g.add_argument("--nothink", action="store_true")
o = a.parse_args()
if o.mode == "draft" and not o.out: die("draft needs --out PATH")
if o.mode == "draft" and Path(o.out).exists() and not o.force: die(f"{o.out} exists; pass --force to overwrite")

def read(p):
    try: return Path(p).read_text(errors="replace")
    except OSError as e: die(f"cannot read {p}: {e.strerror}", 2)

parts = []
for f in o.files:
    if SECRET.search(f): die(f"refusing to send secret-looking file to a third party: {f}")
    parts.append(f"### {f}\n{read(f)}")
user = "\n\n".join(parts + ["### Task\n" + read(o.brief)])
est = len((SYS[o.mode] + user).encode()) // 3  # deliberately high

alias = o.model or ("deepseek" if est > 200_000 else "qwen")  # qwen/gemma ctx is 262k
mid = MODELS.get(alias) or (alias if "/" in alias else None)
if not mid: die(f"unknown model '{alias}'; use {'|'.join(MODELS)} or a full id", 2)
if est > CTX.get(alias, 262144) * 0.9: die(f"~{est} tokens exceeds {alias} context; use --model deepseek or send fewer files", 2)

think = o.think or (not o.nothink and o.mode == "think")
body = {"model": mid, "max_tokens": o.max or MAXTOK[o.mode], "temperature": 0.6 if think else 0.3,
        "messages": [{"role": "system", "content": SYS[o.mode]}, {"role": "user", "content": user}]}
if alias == "deepseek":  # measured: thinking off gave a wrong 17*23, and reasoning_effort="low" returns EMPTY content (8/8), so send nothing
    if not think: print("[deepseek: thinking kept on for accuracy]", file=sys.stderr)
elif not think: body["reasoning_effort"] = "none"
if o.dry: die(f"[dry] model={mid} think={think} est_tokens~{est} max_tokens={body['max_tokens']}", 0)

kf = Path.home() / ".config/tokenme/api-key"
key = os.environ.get("TOKENME_API_KEY") or (kf.read_text().strip() if kf.exists() else "")
if not key: die(SETUP, 3)

def call(b):  # curl, not urllib: python fails cert checks on macOS. Key goes via stdin config, body via 0600 file: nothing secret in argv.
    f = Path(f"/tmp/tkm-{o.tag}.json"); f.touch(mode=0o600); f.write_text(json.dumps(b))
    cfg = f'header = "Authorization: Bearer {key}"\nheader = "Content-Type: application/json"\n'
    p = subprocess.run(["curl", "-sS", "-m", "300", "-K", "-", "-d", f"@{f}", "-w", "\n%{http_code}", URL], input=cfg, capture_output=True, text=True)
    f.unlink(missing_ok=True)
    if p.returncode: die(f"tokenme unreachable: {p.stderr.strip()[:200]}")
    txt, code = p.stdout.rsplit("\n", 1)
    return int(code), txt

for attempt in range(3):
    code, txt = call(body)
    if code == 200:
        r = json.loads(txt); c = r["choices"][0]
        if not (c["message"].get("content") or "").strip() and c.get("finish_reason") != "length" and attempt < 2: continue  # deepseek sometimes returns empty (2/6 measured)
        break
    if code in (401, 403): die(SETUP, 3)
    if code == 400 and "reasoning_effort" in body and "reasoning" in txt.lower(): body.pop("reasoning_effort"); continue
    if code in (429, 500, 502, 503, 504) and attempt < 2: time.sleep(3); continue
    die(f"tokenme HTTP {code}: {txt[:300]}")

ch, u = r["choices"][0], r.get("usage", {})
out = (ch["message"].get("content") or "").strip()
print(f"[{alias} think={think} in={u.get('prompt_tokens')} cached={u.get('prompt_tokens_details', {}).get('cached_tokens')} out={u.get('completion_tokens')} reasoning={u.get('completion_tokens_details', {}).get('reasoning_tokens')}]", file=sys.stderr)
if ch.get("finish_reason") == "length": die("TRUNCATED (max_tokens hit, reasoning counts too): raise --max or use --nothink; nothing written.")
if not out: die("empty reply")
if o.mode == "draft":
    out = re.sub(r"\A```[\w+-]*\n|\n```\s*\Z", "", out)
    Path(o.out).parent.mkdir(parents=True, exist_ok=True); Path(o.out).write_text(out + "\n")
    print(f"wrote {o.out} ({out.count(chr(10)) + 1} lines) — unreviewed, verify before use")
else: print(out[:6000])
