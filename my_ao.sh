#!/usr/bin/env bash
set -euo pipefail

# ── Paths & env ────────────────────────────────────────────────────────────────
# Adjust these if your locations change.
XPLANE_ROOT="/Users/Allan/X-Plane 12"
SRC_ROOT="$XPLANE_ROOT/My Custom Scenery/z_autoortho/scenery"   # source (FUSE)
DST_EUR="$XPLANE_ROOT/My Custom Scenery/z_ao_eur"                # mountpoint (dest)
DST_NA="$XPLANE_ROOT/My Custom Scenery/z_ao_na"                  # mountpoint (dest)

# Repo / venv
REPO="$HOME/repos/my_autoortho_kubilus"
VENV="$HOME/venvs/my_autoortho_kubilus"

# AutoOrtho config/data — you chose to stick with these names
export AO_CONFIG="$HOME/.my_autoortho"
export AO_DATA="$HOME/.my_autoortho-data"

# Python (use python3 explicitly on macOS)
PYTHON_BIN="python3"

# ── Activate env & cd repo ────────────────────────────────────────────────────
# (Keep this part unprivileged)
source "$VENV/bin/activate"
cd "$REPO"

# ── Phase 1: Ensure config is created/saved as your user (no sudo here) ───────
$PYTHON_BIN - <<'PY'
import os, sys, traceback
sys.path.insert(0, os.path.abspath("autoortho"))
try:
    from aoconfig import AOConfig
    cfg = AOConfig()  # loads + may save config
    print("Config OK:", os.environ.get("AO_CONFIG"))
except Exception as e:
    traceback.print_exc()
    raise SystemExit(1)
PY

# Make sure ownership/permissions are yours before we launch anything with sudo
# (These may not exist the very first time; ignore errors.)
chmod -R u+rwX,go-rwx "$AO_CONFIG" "$AO_DATA" 2>/dev/null || true
chown -R "$USER":"$USER" "$AO_CONFIG" "$AO_DATA" 2>/dev/null || true

# ── Prepare mountpoints & source dirs (as your user) ──────────────────────────
mkdir -p "$SRC_ROOT/z_ao_eur" "$SRC_ROOT/z_ao_na"
mkdir -p "$DST_EUR" "$DST_NA"

# Helper: is a path a FUSE mount already?
is_mounted() {
  mount | grep -F " on $1 " >/dev/null 2>&1
}

# Cleanly unmount on exit (or Ctrl+C)
cleanup() {
  set +e
  for mp in "$DST_EUR" "$DST_NA"; do
    if is_mounted "$mp"; then
      echo "Unmounting $mp ..."
      sudo umount "$mp" || sudo diskutil unmount force "$mp"
    fi
  done
}
trap cleanup EXIT

# If stale mounts exist, unmount first (idempotent)
for mp in "$DST_EUR" "$DST_NA"; do
  if is_mounted "$mp"; then
    echo "Found existing mount at $mp — unmounting first..."
    sudo umount "$mp" || sudo diskutil unmount force "$mp"
  fi
done

# ── Phase 2: Launch FUSE mounts with sudo, preserving AO_* env via -E ─────────
# NOTE: We only run the *FUSE* processes as root. Config was already handled above.
# echo "Starting FUSE for Europe..."
# sudo -E "$PYTHON_BIN" autoortho/autoortho_fuse.py \
#  "$SRC_ROOT/z_ao_eur" \
#  "$DST_EUR" &

# echo "Starting FUSE for North America..."
# sudo -E "$PYTHON_BIN" autoortho/autoortho_fuse.py \
#  "$SRC_ROOT/z_ao_na" \
#  "$DST_NA" &

# Optional: short settle delay
sleep 5

# ── Start AutoOrtho main (if you need it) ─────────────────────────────────────
# Choose ONE of the following (uncomment it and comment the other).
# If it needs elevated privileges for macOS FUSE ops, keep sudo -E;
# otherwise prefer running as your user.

# 1) CLI entrypoint (typical):
# "$PYTHON_BIN" -m autoortho
"$PYTHON_BIN" autoortho/

# 2) Older direct script (if your fork uses it):
# "$PYTHON_BIN" autoortho/autoortho.py

# 3) If you know it truly needs root (rare for the main app), then:
# sudo -E "$PYTHON_BIN" -m autoortho

# Keep the script alive until background FUSE processes exit
wait

