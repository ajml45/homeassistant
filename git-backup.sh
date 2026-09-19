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