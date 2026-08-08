#!/bin/bash
# Helper script to manually sync docs to ascii-ui-docs repo
# Usage: ./scripts/sync-docs.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOCS_REPO="${DOCS_REPO:-/tmp/ascii-ui-docs}"

echo "=== ascii-ui.nvim → ascii-ui-docs sync ==="
echo ""

# Check if docs repo exists
if [ ! -d "$DOCS_REPO" ]; then
    echo "Cloning ascii-ui-docs to $DOCS_REPO..."
    git clone https://github.com/rcasia/ascii-ui-docs.git "$DOCS_REPO"
fi

cd "$DOCS_REPO"
git checkout main
git pull

echo ""
echo "Docs repo is up to date at: $DOCS_REPO"
echo ""
echo "Next steps:"
echo "1. Review changes in ascii-ui.nvim (lua/ascii-ui/, doc/)"
echo "2. Update Docusaurus markdown files in docs/"
echo "3. Run 'npm run build' to verify"
echo "4. Commit and create PR"
