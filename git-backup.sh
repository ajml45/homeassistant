#!/bin/bash
#
# Nightly Home Assistant config backup to GitHub.
# Called from shell_command.git_backup (automation "GitHub Daily Backup").
#
# What gets committed is controlled entirely by .gitignore (ignore-everything
# with an explicit whitelist), so adding a new file to the backup means adding
# a `!path` line there — no second list to keep in sync.

export HOME=/root

LOG_FILE="/config/git-backup.log"
CONFIG_DIR="/config"
BRANCH="main"
INVENTORY="$CONFIG_DIR/hacs-inventory.md"

exec >> "$LOG_FILE" 2>&1

echo
echo "=================================================="
echo "--- Backup started: $(date) ---"
echo "=================================================="

cd "$CONFIG_DIR" || {
    echo "ERROR: Could not change to $CONFIG_DIR"
    exit 1
}

# --------------------------------------------------
# SSH configuration
# --------------------------------------------------

SSH_KEY="/config/.ssh/id_ed25519"
KNOWN_HOSTS="/config/.ssh/known_hosts"

export GIT_SSH_COMMAND="ssh \
    -i $SSH_KEY \
    -o UserKnownHostsFile=$KNOWN_HOSTS \
    -o StrictHostKeyChecking=accept-new"

if [ ! -f "$SSH_KEY" ]; then
    echo "ERROR: SSH key not found at $SSH_KEY"
    exit 1
fi

# --------------------------------------------------
# Recover from a previous run that died mid-rebase.
# Without this, one bad night blocks every run after it.
# --------------------------------------------------

GIT_DIR_PATH="$(git rev-parse --git-dir)"
if [ -d "$GIT_DIR_PATH/rebase-merge" ] || [ -d "$GIT_DIR_PATH/rebase-apply" ]; then
    echo "WARNING: Found an in-progress rebase from a previous run; aborting it."
    git rebase --abort || {
        echo "ERROR: Could not abort stale rebase. Manual intervention needed."
        exit 1
    }
fi

# --------------------------------------------------
# Inventory of HACS installs, custom components and dashboard resources.
#
# The code itself isn't versioned (HACS reinstalls it), so this list is what a
# rebuild works from. It only reads the fields it prints — never credentials.
# There's deliberately no timestamp in the file, so it only shows up in a
# commit when something was actually installed, removed or updated.
#
# A failure here never blocks the backup; the previous inventory is kept.
# --------------------------------------------------

echo "Writing HACS / custom component inventory..."
if python3 - "$CONFIG_DIR" > "${INVENTORY}.tmp" <<'PY'
import glob
import json
import os
import sys

config = sys.argv[1]

CATEGORY_LABELS = {
    "integration": "Integration",
    "plugin": "Dashboard",
    "theme": "Theme",
    "python_script": "Python script",
    "template": "Template",
    "appdaemon": "AppDaemon",
    "netdaemon": "NetDaemon",
}


def load(path):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (OSError, ValueError) as err:
        print(f"inventory: could not read {path}: {err}", file=sys.stderr)
        return None


def cell(value):
    return str(value if value not in (None, "") else "—").replace("|", "\\|")


lines = [
    "# Custom components & frontend inventory",
    "",
    "Generated nightly by `git-backup.sh`. After a fresh restore, reinstall",
    "these through HACS, then re-add the dashboard resources if any are missing.",
    "",
]

# HACS: everything it has installed (integrations, cards, themes, ...)
lines += ["## Installed through HACS", ""]
hacs = load(os.path.join(config, ".storage", "hacs.repositories"))
repos = (hacs or {}).get("data")
rows = []
if isinstance(repos, dict):
    for repo in repos.values():
        if not isinstance(repo, dict) or not repo.get("installed"):
            continue
        version = repo.get("version_installed") or repo.get("installed_commit")
        rows.append((
            CATEGORY_LABELS.get(repo.get("category"), repo.get("category") or "?"),
            repo.get("full_name") or "?",
            version,
        ))
if rows:
    lines += ["| Type | Repository | Version |", "|---|---|---|"]
    for kind, name, version in sorted(rows, key=lambda r: (r[0], r[1].lower())):
        lines.append(f"| {cell(kind)} | {cell(name)} | {cell(version)} |")
else:
    lines.append("_HACS repository data not found._")
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
resources = load(os.path.join(config, ".storage", "lovelace_resources"))
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
    echo "WARNING: Inventory generation failed; keeping the previous inventory."
    rm -f "${INVENTORY}.tmp"
fi

# --------------------------------------------------
# Stage local HA changes (adds, modifications, deletions),
# honoring .gitignore.
# --------------------------------------------------

echo "Staging Home Assistant configuration..."
git add -A

if git diff --cached --quiet; then
    echo "No local changes to commit."
else
    SUMMARY="$(git diff --cached --stat | tail -n 1)"
    FILES="$(git diff --cached --name-status)"
    if git commit -q -m "Daily catchup: $(date '+%Y-%m-%d %H:%M:%S') — ${SUMMARY}" -m "${FILES}"; then
        echo "Committed: ${SUMMARY}"
    else
        echo "ERROR: Git commit failed."
        exit 1
    fi
fi

# --------------------------------------------------
# Synchronize with GitHub
# --------------------------------------------------

echo "Pulling remote changes..."
if ! git pull --rebase origin "$BRANCH"; then
    echo "ERROR: Git pull/rebase failed (likely a conflict). Aborting rebase so the next run can retry."
    git rebase --abort 2>/dev/null
    git status --short
    exit 1
fi

echo "Pushing to GitHub..."
if ! git push origin "$BRANCH"; then
    echo "ERROR: Git push failed."
    exit 1
fi

echo "--- Backup completed successfully: $(date) ---"