#!/bin/bash
input=$(cat)

hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')

case "$hook_event" in
  Stop)
    prefix="DONE"
    # Truncate last assistant message to keep notification short
    msg=$(echo "$input" | jq -r '.last_assistant_message // empty' | tr '\n' ' ' | head -c 120)
    if [ -n "$msg" ]; then
      alert="[$prefix] $msg"
    else
      alert="[$prefix] Claude finished"
    fi
    ;;
  PermissionRequest)
    prefix="🔐 PERMISSION"
    tool=$(echo "$input" | jq -r '.tool_name // "unknown"')
    desc=$(echo "$input" | jq -r '.tool_input.description // .tool_input.command // .tool_input.pattern // .tool_input.file_path // empty' | tr '\n' ' ' | head -c 100)
    if [ -n "$desc" ]; then
      alert="[$prefix] $tool: $desc"
    else
      alert="[$prefix] $tool"
    fi
    ;;
  *)
    alert="[🔔 NOTIFY] Claude Code"
    ;;
esac

# Pick ttys to write to, in order of preference:
#   1. attached tmux client(s) — works even without a controlling terminal
#   2. /dev/tty if the hook happens to have one
#   3. all login ttys owned by this user (no tmux, hook has no tty)
target_ttys=""
if command -v tmux >/dev/null 2>&1; then
  target_ttys=$(tmux list-clients -F '#{client_tty}' 2>/dev/null)
fi
if [ -z "$target_ttys" ] && (: > /dev/tty) 2>/dev/null; then
  target_ttys=/dev/tty
fi
if [ -z "$target_ttys" ]; then
  target_ttys=$(who 2>/dev/null | awk -v u="$USER" '$1 == u {print "/dev/" $2}')
fi
[ -n "$target_ttys" ] || exit 0

# OSC 777 carries title + body (Ghostty/urxvt-style); fall back to OSC 9
# (iTerm2-style, body only) for terminals that don't speak it. A BEL rings
# the terminal bell so unsupported emulators still flag activity/urgency.
# Strip semicolons from the body so they don't break OSC 777 field parsing.
body=${alert//;/,}
for tty in $target_ttys; do
  [ -w "$tty" ] || continue
  {
    printf '\033]777;notify;Claude;%s\033\\' "$body"
    printf '\033]9;Claude — %s\033\\' "$body"
    printf '\a'
  } > "$tty" 2>/dev/null
done
exit 0
