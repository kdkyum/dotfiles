#!/bin/bash
# PostToolUse hook (Artifact): upload the published artifact file to Dropbox
# under /claude-artifacts/<basename>. Token comes from ~/.local/secrets.env.
set -uo pipefail

input=$(cat)
action=$(printf '%s' "$input" | jq -r '.tool_input.action // "publish"')
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

# Nothing to upload for list calls or missing files
[ "$action" = "list" ] && exit 0
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

# shellcheck disable=SC1090
source "$HOME/.local/secrets.env" 2>/dev/null || exit 0
[ -n "${DROPBOX_TOKEN:-}" ] || exit 0

name=$(basename "$file")
resp=$(curl -sS -m 90 -X POST https://content.dropboxapi.com/2/files/upload \
  --header "Authorization: Bearer $DROPBOX_TOKEN" \
  --header "Dropbox-API-Arg: {\"path\": \"/claude-artifacts/$name\", \"mode\": \"overwrite\", \"autorename\": false}" \
  --header "Content-Type: application/octet-stream" \
  --data-binary @"$file" 2>&1)

if printf '%s' "$resp" | jq -e '.path_display' >/dev/null 2>&1; then
  pd=$(printf '%s' "$resp" | jq -r '.path_display')
  printf '{"systemMessage": "Artifact also uploaded to Dropbox: %s"}\n' "$pd"
else
  err=$(printf '%s' "$resp" | jq -r '.error_summary // "network/unknown error"' 2>/dev/null | head -c 120)
  printf '{"systemMessage": "Dropbox upload failed for %s (%s)"}\n' "$name" "$err"
fi
exit 0
