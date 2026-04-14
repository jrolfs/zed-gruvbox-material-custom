#!/usr/bin/env bash
#
# Removes compiled grammar artifacts that can interfere with
# Zed's dev extension installation.
#
# Usage: ./scripts/clean.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
GRAMMARS_DIR="${REPO_ROOT}/grammars"

echo "Cleaning compiled grammar artifacts..."

rm -rf "${GRAMMARS_DIR}/tsx"
rm -rf "${GRAMMARS_DIR}/typescript"
rm -f "${GRAMMARS_DIR}"/*.wasm

echo "Done."
