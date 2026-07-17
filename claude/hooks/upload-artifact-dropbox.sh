#!/bin/bash
# PostToolUse hook (Artifact): upload the published artifact file to Dropbox
# under /Apps/artifacts/<basename> using dbxcli.
# dbxcli handles auth (~/.config/dbxcli/auth.json) and overwrites by default.
set -uo pipefail

input=$(cat)
action=$(printf '%s' "$input" | jq -r '.tool_input.action // "publish"')
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

# Nothing to upload for list calls or missing files
[ "$action" = "list" ] && exit 0
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

# Locate dbxcli (hooks may run with a minimal PATH)
dbxcli=$(command -v dbxcli || true)
[ -z "$dbxcli" ] && [ -x "$HOME/.local/bin/dbxcli" ] && dbxcli="$HOME/.local/bin/dbxcli"
[ -z "$dbxcli" ] && exit 0

name=$(basename "$file")
dest="/Apps/artifacts/$name"

if resp=$("$dbxcli" --timeout 90s put "$file" "$dest" 2>&1); then
  printf '{"systemMessage": "Artifact also uploaded to Dropbox: %s"}\n' "$dest"
else
  err=$(printf '%s' "$resp" | tr '\n' ' ' | head -c 120)
  printf '{"systemMessage": "Dropbox upload failed for %s (%s)"}\n' "$name" "$err"
fi
exit 0
