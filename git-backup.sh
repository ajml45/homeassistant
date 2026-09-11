#!/bin/bash

export HOME=/root

LOG_FILE="/config/git-backup.log"
CONFIG_DIR="/config"

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
# Files we intentionally back up
# --------------------------------------------------

BACKUP_FILES=(
    ".gitignore"
    "git-backup.sh"

    "automations.yaml"
    "configuration.yaml"
    "govee_learning.yaml"
    "groups.yaml"
    "input_booleans.yaml"
    "input_select.yaml"
    "mobile_frontend.yaml"
    "scenes.yaml"
    "scripts.yaml"
    "sensors.yaml"
    "tablet_frontend.yaml"
    "templates.yaml"

    "themes/isaaclucas_kitchen.yaml"
    "themes/mobile.yaml"
    "themes/mudroom.yaml"

    "themes/kitchen_tablet.yaml"
    "themes/mudroom_tablet.yaml"
)

echo "Staging Home Assistant configuration..."

for FILE in "${BACKUP_FILES[@]}"; do

    if [ -e "$FILE" ]; then
        #
        # -f intentionally overrides .gitignore because this is
        # our explicit backup allowlist.
        #
        git add -f -- "$FILE"

    elif git ls-files --error-unmatch "$FILE" >/dev/null 2>&1; then
        echo "Detected deleted tracked file: $FILE"
        git add -u -- "$FILE"

    else
        echo "Skipping nonexistent/untracked file: $FILE"
    fi
done

# --------------------------------------------------
# Commit local HA changes
# --------------------------------------------------

if git diff --cached --quiet; then
    echo "No local changes to commit."
else
    if git commit -m "Daily catchup: $(date '+%Y-%m-%d %H:%M:%S')"; then
        echo "Committed Home Assistant changes."
    else
        echo "ERROR: Git commit failed."
        exit 1
    fi
fi

# --------------------------------------------------
# Make sure nothing unexpected remains dirty
# --------------------------------------------------

if ! git diff --quiet; then
    echo
    echo "ERROR: Unstaged tracked changes remain after commit:"
    git status --short
    echo
    echo "Refusing to pull/rebase until these are resolved."
    exit 1
fi

# --------------------------------------------------
# Synchronize with GitHub
# --------------------------------------------------

echo "Pulling remote changes..."

if ! git pull origin main --rebase; then
    echo "ERROR: Git pull/rebase failed."
    exit 1
fi

echo "Pushing to GitHub..."

if ! git push origin main; then
    echo "ERROR: Git push failed."
    exit 1
fi

echo "--- Backup completed successfully: $(date) ---"