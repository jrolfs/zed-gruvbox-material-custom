#!/usr/bin/env bash
#
# Syncs tree-sitter query files from upstream Zed for TypeScript and TSX.
# Fetches all .scm files except highlights.scm (which we customize locally).
#
# Usage: ./scripts/sync-queries.sh

set -euo pipefail

ZED_COMMIT="1ac669d108fbcf9b14bbfa45ed0a2d16e830930e"

BASE_URL="https://raw.githubusercontent.com/zed-industries/zed/${ZED_COMMIT}/crates/grammars/src"

QUERY_FILES=(
  brackets.scm
  debugger.scm
  indents.scm
  injections.scm
  outline.scm
  overrides.scm
  runnables.scm
  textobjects.scm
)

LANGUAGES=(
  "typescript:TypeScript"
  "tsx:TSX"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

for lang_pair in "${LANGUAGES[@]}"; do
  upstream="${lang_pair%%:*}"
  local_dir="${lang_pair##*:}"
  target_dir="${REPO_ROOT}/languages/${local_dir}"

  echo "Syncing ${local_dir} queries from zed@${ZED_COMMIT:0:10}..."

  for file in "${QUERY_FILES[@]}"; do
    url="${BASE_URL}/${upstream}/${file}"

    if curl -fsSL "${url}" -o "${target_dir}/${file}"; then
      echo "  ${file}"
    else
      echo "  ${file} (not found, skipping)" >&2
    fi
  done
done

echo "Done. Pinned to zed commit ${ZED_COMMIT:0:10}."
