#!/bin/sh
# run_once: sets up VS Code Remote machine-level MCP server definitions.
# Using plain "npx" (no absolute path) avoids breakage when the Node version
# installed by the devcontainer changes between codespace rebuilds.

set -eu

MCP_DIR="${HOME}/.vscode-remote/data/Machine"
MCP_FILE="${MCP_DIR}/mcp.json"

mkdir -p "${MCP_DIR}"

# Only write if file doesn't already exist, so manual edits are preserved.
if [ ! -f "${MCP_FILE}" ]; then
  cat > "${MCP_FILE}" <<'EOF'
{
  "servers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
EOF
  echo "Created ${MCP_FILE}"
else
  echo "${MCP_FILE} already exists, skipping."
fi
