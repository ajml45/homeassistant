#!/bin/bash
#
# Nightly Home Assistant config backup to GitHub.
# Called from shell_command.git_backup (automation "GitHub Daily Backup").
#
# What gets committed is controlled entirely by .gitignore (ignore-everything
# with an explicit whitelist), so adding a new file to the backup means adding
# a `!path` line there — no second list to keep in sync.
#
# Everything goes to $LOG_FILE. The automation only gets one line on stdout:
# "OK: ...", "OK with warnings: ..." (backed up, but the dashboard export or
# inventory step failed), or the reason it failed. The exit code is 0 when the
# backup reached GitHub and 1 when it didn't; the alert checks both.

export HOME=/root

LOG_FILE="/config/git-backup.log"
CONFIG_DIR="/config"
BRANCH="main"
INVENTORY="$CONFIG_DIR/hacs-inventory.md"

# Keep the original stdout as fd 3 for the one-line result, then send
# everything else to the log.
exec 3>&1
exec >> "$LOG_FILE" 2>&1

fail() {
    echo "ERROR: $1"
    echo "--- Backup FAILED: $(date) ---"
    echo "$1" >&3
    exit 1
}

echo
echo "=================================================="
echo "--- Backup started: $(date) ---"
echo "=================================================="

cd "$CONFIG_DIR" || fail "Could not change to $CONFIG_DIR"

# --------------------------------------------------
# SSH configuration
# --------------------------------------------------

SSH_KEY="/config/.ssh/id_ed25519"
KNOWN_HOSTS="/config/.ssh/known_hosts"

export GIT_SSH_COMMAND="ssh \
    -i $SSH_KEY \
    -o UserKnownHostsFile=$KNOWN_HOSTS \
    -o StrictHostKeyChecking=accept-new"

[ -f "$SSH_KEY" ] || fail "SSH key not found at $SSH_KEY"

# --------------------------------------------------
# Recover from a previous run that died mid-rebase.
# Without this, one bad night blocks every run after it.
# --------------------------------------------------

GIT_DIR_PATH="$(git rev-parse --git-dir)"
if [ -d "$GIT_DIR_PATH/rebase-merge" ] || [ -d "$GIT_DIR_PATH/rebase-apply" ]; then
    echo "WARNING: Found an in-progress rebase from a previous run; aborting it."
    git rebase --abort || fail "Could not abort a stale rebase. Manual intervention needed."
fi

# --------------------------------------------------
# Export the live dashboards to frontends/.
#
# The dashboards are storage-mode, so the real config lives in
# .storage/lovelace.<id>. This writes the ones listed in EXPORT to
# frontends/ as YAML, so the repo copies always match what's live (they used
# to be pasted in by hand and could fall behind). Edit dashboards in Home
# Assistant as usual; the files here are read-only copies.
#
# Only dashboards listed in EXPORT are written — this repo is public, so a
# new dashboard isn't published until you add it here.
#
# A failure here never blocks the backup; the previous copies are kept.
# --------------------------------------------------

WARNINGS=""
warn() {
    echo "WARNING: $1"
    WARNINGS="${WARNINGS:+$WARNINGS; }$1"
}

echo "Exporting dashboards..."
python3 - "$CONFIG_DIR" <<'PY' || warn "dashboard export failed, kept the previous copies (see log)"
import json
import os
import sys

import yaml

# url_path of the dashboard -> file in frontends/
EXPORT = {
    "isaac-lucas": "tablet_frontend.yaml",
    "mobile-rooms": "mobile_frontend.yaml",
}

config = sys.argv[1]
storage = os.path.join(config, ".storage")


def load(name):
    with open(os.path.join(storage, name), encoding="utf-8") as f:
        return json.load(f)


class Dumper(yaml.SafeDumper):
    """Block style for multi-line strings, lists indented under their key."""

    def increase_indent(self, flow=False, indentless=False):
        return super().increase_indent(flow, False)

    def analyze_scalar(self, scalar):
        # PyYAML won't write a "|" block if any line ends in a space, which
        # turns most card_mod CSS into one long "\n"-escaped line. Literal
        # blocks keep trailing spaces fine, so allow it (the round-trip check
        # below catches anything that doesn't load back the same).
        analysis = super().analyze_scalar(scalar)
        if (analysis.multiline and not analysis.allow_block
                and all(ch in "\n\t" or (" " <= ch <= "\x7e") or ch >= "\xa0"
                        for ch in scalar)):
            analysis.allow_block = True
        return analysis


def represent_str(dumper, data):
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


Dumper.add_representer(str, represent_str)

items = (load("lovelace_dashboards").get("data") or {}).get("items") or []
by_path = {item.get("url_path"): item for item in items}
failed = False

for url_path, filename in EXPORT.items():
    item = by_path.get(url_path)
    if not item:
        print(f"dashboards: no dashboard with url_path {url_path!r}; skipped")
        failed = True
        continue
    try:
        dashboard = load(f"lovelace.{item['id']}")
    except (OSError, ValueError) as err:
        print(f"dashboards: could not read {url_path} ({err}); skipped")
        failed = True
        continue
    cfg = (dashboard.get("data") or {}).get("config")
    if not cfg:
        print(f"dashboards: {url_path} has no saved config; skipped")
        failed = True
        continue

    text = (
        f"# Live copy of the \"{item.get('title') or url_path}\" dashboard (/{url_path}),\n"
        "# exported nightly by git-backup.sh. Edit the dashboard in Home Assistant;\n"
        "# changes made here are overwritten.\n"
        + yaml.dump(cfg, Dumper=Dumper, sort_keys=False, allow_unicode=True,
                    width=4096, default_flow_style=False)
    )
    # Round-trip check: never publish a file that doesn't load back the same.
    if yaml.safe_load(text) != cfg:
        print(f"dashboards: {url_path} did not round-trip; skipped")
        failed = True
        continue

    path = os.path.join(config, "frontends", filename)
    try:
        with open(path, encoding="utf-8", newline="") as f:
            if f.read() == text:
                continue
    except OSError:
        pass
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path + ".tmp", "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    os.replace(path + ".tmp", path)
    print(f"dashboards: wrote frontends/{filename}")

sys.exit(1 if failed else 0)
PY

# --------------------------------------------------
# Inventory of Marketplace (formerly HACS) installs, custom components and
# dashboard resources.
#
# The code itself isn't versioned (the Marketplace reinstalls it), so this
# list is what a rebuild works from. It only reads the fields it prints —
# never credentials. There's deliberately no timestamp in the file, so it only
# shows up in a commit when something was installed, removed or updated.
#
# Since HA 2026.11 HACS is built in as the Marketplace, and its update
# entities are the supported source of installed/latest versions. They're read
# from the entity registry (which entities) and core.restore_state (their last
# state, saved every 15 minutes). Pre-2026.11 HACS data is used as a fallback.
#
# A failure here never blocks the backup; the previous inventory is kept.
# --------------------------------------------------

echo "Writing Marketplace / custom component inventory..."
if python3 - "$CONFIG_DIR" > "${INVENTORY}.tmp" <<'PY'
import glob
import json
import os
import re
import sys

config = sys.argv[1]
storage = os.path.join(config, ".storage")


def load(path):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (OSError, ValueError) as err:
        print(f"inventory: could not read {path}: {err}", file=sys.stderr)
        return None


def cell(value):
    return str(value if value not in (None, "") else "—").replace("|", "\\|")


def repo_from_url(url):
    match = re.match(r"https?://github\.com/([^/]+/[^/#?]+)", str(url or ""))
    return match.group(1) if match else None


lines = [
    "# Custom components & frontend inventory",
    "",
    "Generated nightly by `git-backup.sh`. After a fresh restore, reinstall",
    "these from Settings → Marketplace, then re-add the dashboard resources if",
    "any are missing.",
    "",
]

# Marketplace: one update entity per installed repository
lines += ["## Installed through the Marketplace", ""]
registry = (load(os.path.join(storage, "core.entity_registry")) or {}).get("data") or {}
update_entities = [
    e for e in registry.get("entities") or []
    if e.get("platform") in ("marketplace", "hacs")
    and str(e.get("entity_id", "")).startswith("update.")
]
restored = {}
for item in (load(os.path.join(storage, "core.restore_state")) or {}).get("data") or []:
    state = item.get("state") or {}
    if state.get("entity_id"):
        restored[state["entity_id"]] = state
# The update entities carry no title; the Marketplace names each repo's device.
devices = {}
if update_entities:
    for device in ((load(os.path.join(storage, "core.device_registry")) or {}).get("data") or {}).get("devices") or []:
        devices[device.get("id")] = device.get("name_by_user") or device.get("name")

rows = []
for entity in update_entities:
    state = restored.get(entity["entity_id"]) or {}
    attrs = state.get("attributes") or {}
    rows.append((
        attrs.get("title") or devices.get(entity.get("device_id")) or entity.get("name")
        or entity.get("original_name") or entity["entity_id"],
        repo_from_url(attrs.get("release_url")),
        attrs.get("installed_version"),
        attrs.get("latest_version"),
        "disabled" if entity.get("disabled_by") else "",
    ))

if rows:
    lines += ["| Name | Repository | Installed | Latest | Note |", "|---|---|---|---|---|"]
    for row in sorted(rows, key=lambda r: str(r[0]).lower()):
        lines.append("| " + " | ".join(cell(v) for v in row) + " |")
else:
    # Pre-2026.11: HACS kept its own list
    hacs = (load(os.path.join(storage, "hacs.repositories")) or {}).get("data")
    legacy = []
    if isinstance(hacs, dict):
        for repo in hacs.values():
            if isinstance(repo, dict) and repo.get("installed"):
                legacy.append((repo.get("category") or "?", repo.get("full_name") or "?",
                               repo.get("version_installed") or repo.get("installed_commit")))
    if legacy:
        lines += ["| Type | Repository | Version |", "|---|---|---|"]
        for kind, name, version in sorted(legacy, key=lambda r: (r[0], r[1].lower())):
            lines.append(f"| {cell(kind)} | {cell(name)} | {cell(version)} |")
    else:
        lines.append("_No Marketplace update entities found._")
lines.append("")

# Custom integrations actually on disk (catches anything installed by hand)
lines += ["## custom_components on disk", ""]
manifests = sorted(glob.glob(os.path.join(config, "custom_components", "*", "manifest.json")))
if manifests:
    lines += ["| Domain | Name | Version |", "|---|---|---|"]
    for path in manifests:
        manifest = load(path) or {}
        domain = manifest.get("domain") or os.path.basename(os.path.dirname(path))
        lines.append(
            f"| {cell(domain)} | {cell(manifest.get('name'))} | {cell(manifest.get('version'))} |"
        )
else:
    lines.append("_None._")
lines.append("")

# Dashboard resources registered in the UI (Settings → Dashboards → Resources)
lines += ["## Dashboard resources", ""]
resources = load(os.path.join(storage, "lovelace_resources"))
items = ((resources or {}).get("data") or {}).get("items") or []
if items:
    lines += ["| Type | URL |", "|---|---|"]
    for item in sorted(items, key=lambda i: str(i.get("url", ""))):
        lines.append(f"| {cell(item.get('type'))} | {cell(item.get('url'))} |")
else:
    lines.append("_None registered in the UI._")

print("\n".join(lines))
PY
then
    mv "${INVENTORY}.tmp" "$INVENTORY"
else
    warn "inventory failed, kept the previous one (see log)"
    rm -f "${INVENTORY}.tmp"
fi

# --------------------------------------------------
# Stage local HA changes (adds, modifications, deletions),
# honoring .gitignore.
# --------------------------------------------------

echo "Staging Home Assistant configuration..."
git add -A || fail "git add failed."

SUMMARY="nothing new to commit"
if git diff --cached --quiet; then
    echo "No local changes to commit."
else
    SUMMARY="$(git diff --cached --stat | tail -n 1 | sed 's/^ *//')"
    FILES="$(git diff --cached --name-status)"
    git commit -q -m "Daily catchup: $(date '+%Y-%m-%d %H:%M:%S') — ${SUMMARY}" -m "${FILES}" \
        || fail "git commit failed."
    echo "Committed: ${SUMMARY}"
fi

# --------------------------------------------------
# Synchronize with GitHub
# --------------------------------------------------

echo "Pulling remote changes..."
if ! git pull --rebase origin "$BRANCH"; then
    git rebase --abort 2>/dev/null
    git status --short
    fail "git pull --rebase failed (likely a conflict or no network). Aborted the rebase so the next run can retry."
fi

echo "Pushing to GitHub..."
git push origin "$BRANCH" || fail "git push to GitHub failed."

echo "--- Backup completed successfully: $(date) ---"
if [ -n "$WARNINGS" ]; then
    echo "OK with warnings: ${SUMMARY} — ${WARNINGS}" >&3
else
    echo "OK: ${SUMMARY}" >&3
fi
