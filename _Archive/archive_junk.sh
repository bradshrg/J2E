#!/usr/bin/env bash
# archive_junk.sh
# Moves throwaway one-off helper scripts into ./_Archive, preserving their
# relative folder structure. Run from the REPO ROOT (/workspaces/J2E).
#
#   cd /workspaces/J2E
#   bash archive_junk.sh            # dry run: shows what WOULD move
#   bash archive_junk.sh --apply    # actually moves them
#
# Safe by design:
#   - Moves ONLY the explicit files listed below (no blanket "*.sh" glob).
#   - Uses `git mv` for tracked files (clean rename in git), plain `mv` otherwise.
#   - Skips anything already gone; never touches src/ app code or .rairc.

set -uo pipefail

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1

# Must be at repo root: sanity-check that frontend/ and backend/ exist.
if [ ! -d frontend ] || [ ! -d backend ]; then
  echo "ERROR: run this from the repo root (the folder containing 'frontend/' and 'backend/')."
  echo "You are in: $(pwd)"
  exit 1
fi

ARCHIVE_ROOT="_Archive"

# --- The explicit list of files to archive (relative to repo root) ----------
FILES=(
  # i18n scaffolding (one-time, already ran or superseded)
  "frontend/01-create-locales.sh"
  "frontend/02-create-locales-index.sh"
  "frontend/03-create-language-context.sh"
  "frontend/04-create-translation-hook.sh"
  "frontend/05-create-language-selector.sh"
  "frontend/06-populate-english-words.sh"
  "frontend/07-create-game-translations.sh"
  "frontend/08-create-brian-story-component.sh"
  "frontend/09-create-stress-teaching-component.sh"
  # banner / logo / layout saga (destructive + analyze + fixes)
  "frontend/ANALYZE_PAGELAYOUT.sh"
  "frontend/CLEAN_RESTRUCTURE.sh"
  "frontend/DO_THE_WORK.sh"
  "frontend/STEP1_BACKUP.sh"
  "frontend/STEP2_REMOVE_CENTER_LOGO.sh"
  "frontend/VERIFY_EXACT_LINES.sh"
  "frontend/VETTED_BANNER_FIX.sh"
  "frontend/analyze_current_layout.sh"
  "frontend/bypass_cache_test.sh"
  "frontend/check-translations.sh"
  "frontend/check_backup.sh"
  "frontend/check_css_overrides.sh"
  "frontend/check_logo_animation.sh"
  "frontend/check_logo_css.sh"
  "frontend/check_logo_path.sh"
  "frontend/check_server_config.sh"
  "frontend/check_title_section.sh"
  "frontend/check_title_section_fixed.sh"
  "frontend/create_complete_layout.sh"
  "frontend/debug_logo_only.sh"
  "frontend/fix_animation_name.sh"
  "frontend/fix_container2_full_border.sh"
  "frontend/fix_logo_conflict.sh"
  "frontend/fix_nav_and_title.sh"
  "frontend/fix_to_public_path.sh"
  "frontend/fix_wrong_path.sh"
  "frontend/make_logo_larger.sh"
  "frontend/media-sandbox.sh"
  "frontend/quick_test.sh"
  "frontend/replace_with_complete.sh"
  "frontend/restore_most_recent.sh"
  "frontend/show_current_path.sh"
  "frontend/show_exact_current.sh"
  "frontend/show_restructure_plan.sh"
  "frontend/test_static_files.sh"
  "frontend/test_with_curl.sh"
  "frontend/verify_location.sh"
  "frontend/setup_phase1.sh.save"
  "frontend/src/Pages/Fixes/fix_container2_exact.sh"
  "frontend/src/Pages/move_disclaimer.sh"
  "frontend/src/Pages/simple_container2_fix.sh"
  # loose JS/PY/MJS helpers + redundant rai configs (.rairc is KEPT, not listed here)
  "frontend/PROPERLY_VETTED_FIX.js"
  "frontend/convert-translations.js"
  "frontend/patch-homepage.js"
  "frontend/fix-imports.py"
  "frontend/rai.config.js"
  "frontend/rai.config.mjs"
  "frontend/react-auto-intl.config.js"
  "frontend/auto-intl.config.mjs"
)

echo "=============================================="
if [ "$APPLY" -eq 1 ]; then
  echo " ARCHIVING (apply mode) -> $ARCHIVE_ROOT/"
else
  echo " DRY RUN (nothing will move). Re-run with --apply to move."
fi
echo "=============================================="
echo

moved=0; missing=0; git_tracked=0

for rel in "${FILES[@]}"; do
  if [ ! -f "$rel" ]; then
    echo "  skip (already gone): $rel"
    missing=$((missing+1))
    continue
  fi

  dest="$ARCHIVE_ROOT/$rel"

  if [ "$APPLY" -eq 1 ]; then
    mkdir -p "$(dirname "$dest")"
    if git ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
      git mv -f "$rel" "$dest" && { echo "  git mv: $rel"; git_tracked=$((git_tracked+1)); }
    else
      mv "$rel" "$dest" && echo "  mv:     $rel"
    fi
    moved=$((moved+1))
  else
    if git ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
      echo "  would git mv: $rel  ->  $dest"
    else
      echo "  would mv:     $rel  ->  $dest"
    fi
    moved=$((moved+1))
  fi
done

echo
echo "----------------------------------------------"
if [ "$APPLY" -eq 1 ]; then
  echo "Moved: $moved   (git-tracked: $git_tracked)   Already gone: $missing"
  # Drop a short pointer note in the archive.
  cat > "$ARCHIVE_ROOT/README.md" <<'NOTE'
# _Archive

Throwaway one-off helper scripts moved out of the working tree. None of these are
imported or run by the app. They were scratch scripts from an iterative debugging loop
over the homepage banner/logo and i18n setup.

WARNING before re-running any of them:
  - They use macOS-only `sed -i ''` and will misbehave on Linux.
  - Many hardcode `/Users/robin/Desktop/J2E/...` paths that don't exist here.
  - They target stale line numbers in HomePage.js.

Copy a file back to its original path first if you ever need to reference/run it.
The canonical react-auto-intl config (`frontend/.rairc`) was intentionally KEPT in place.
NOTE
  echo "Wrote $ARCHIVE_ROOT/README.md"
  echo
  echo "Review with:  git status"
  echo "Commit with:  git add -A && git commit -m 'Archive one-off helper scripts under _Archive/'"
else
  echo "Would move: $moved   Already gone: $missing"
  echo "Run it for real:  bash archive_junk.sh --apply"
fi
echo "----------------------------------------------"
