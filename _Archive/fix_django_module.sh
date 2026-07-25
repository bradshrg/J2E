#!/usr/bin/env bash
# fix_django_module.sh
# Fixes the stale 'MAVJ_website' Django project references. The project folder was
# renamed to 'Website_Pyfiles' but settings/manage/wsgi/asgi still pointed at the old
# package name, causing: ModuleNotFoundError: No module named 'MAVJ_website'.
#
# Can be run from ANYWHERE (e.g. from _Archive/); it locates the target files itself.
#   bash _Archive/fix_django_module.sh          # dry run: shows what WOULD change
#   bash _Archive/fix_django_module.sh --apply  # makes the edits
#
# Only edits FUNCTIONAL references (the string 'MAVJ_website.something' in quotes).
# Leaves comments/docstrings alone. Idempotent: safe to run twice.

set -uo pipefail

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

# --- locate the Django project dir relative to this script -------------------
# This script lives in _Archive/ ; repo root is its parent. Target is backend/Website_Pyfiles.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WP="$REPO_ROOT/backend/Website_Pyfiles"

# Fallback: if not found relative to the script, try the well-known absolute path.
if [ ! -d "$WP" ]; then
  if [ -d "/workspaces/J2E/backend/Website_Pyfiles" ]; then
    WP="/workspaces/J2E/backend/Website_Pyfiles"
  else
    echo "ERROR: can't find backend/Website_Pyfiles."
    echo "  Looked in: $WP"
    echo "  Run this from inside the J2E repo (script expects to sit in _Archive/)."
    exit 1
  fi
fi

echo "Target Django project: $WP"
echo

# file : "old exact string" : "new exact string"
declare -a EDITS=(
  "settings.py|'MAVJ_website.urls'|'urls'"
  "settings.py|'MAVJ_website.wsgi.application'|'wsgi.application'"
  "manage.py|'MAVJ_website.settings'|'settings'"
  "wsgi.py|'MAVJ_website.settings'|'settings'"
  "asgi.py|'MAVJ_website.settings'|'settings'"
)

if [ "$APPLY" -eq 1 ]; then
  echo "=== APPLYING EDITS ==="
else
  echo "=== DRY RUN (nothing changes; re-run with --apply) ==="
fi
echo

changed=0
for e in "${EDITS[@]}"; do
  IFS='|' read -r fname old new <<< "$e"
  f="$WP/$fname"

  if [ ! -f "$f" ]; then
    echo "  skip (missing file): $fname"
    continue
  fi

  if grep -Fq "$old" "$f"; then
    ln="$(grep -Fn "$old" "$f" | head -1 | cut -d: -f1)"
    if [ "$APPLY" -eq 1 ]; then
      # escape for sed: old and new contain dots and quotes; use | delimiter and escape backslashes/pipes
      esc_old="$(printf '%s' "$old" | sed -e 's/[.[\*^$/]/\\&/g')"
      esc_new="$(printf '%s' "$new" | sed -e 's/[&/]/\\&/g')"
      sed -i "s/$esc_old/$esc_new/" "$f"
      echo "  fixed: $fname line $ln   $old -> $new"
    else
      echo "  would fix: $fname line $ln   $old -> $new"
    fi
    changed=$((changed+1))
  else
    echo "  already ok (not found): $fname   $old"
  fi
done

echo
echo "----------------------------------------------"
if [ "$APPLY" -eq 1 ]; then
  echo "Edits applied: $changed"
  echo
  echo "Verify (should show ONLY comment/docstring lines, none functional):"
  grep -rn "MAVJ_website" "$WP"/manage.py "$WP"/settings.py "$WP"/wsgi.py "$WP"/asgi.py 2>/dev/null || echo "  (no MAVJ_website references at all)"
  echo
  echo "Now run the backend:"
  echo "  cd $WP"
  echo "  source .venv/bin/activate"
  echo "  python manage.py migrate"
  echo "  python manage.py runserver 0.0.0.0:8000"
else
  echo "Would change: $changed reference(s). Re-run with --apply to make edits."
fi
echo "----------------------------------------------"
