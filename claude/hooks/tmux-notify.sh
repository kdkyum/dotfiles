#!/bin/bash
read -r input

hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')

case "$hook_event" in
  Stop)
    prefix="DONE"
    # Truncate last assistant message to keep notification short
    msg=$(echo "$input" | jq -r '.last_assistant_message // empty' | head -c 120)
    if [ -n "$msg" ]; then
      alert="[$prefix] $msg"
    else
      alert="[$prefix] Claude finished"
    fi
    ;;
  PermissionRequest)
    prefix="🔐 PERMISSION"
    tool=$(echo "$input" | jq -r '.tool_name // "unknown"')
    desc=$(echo "$input" | jq -r '.tool_input.description // .tool_input.command // .tool_input.pattern // .tool_input.file_path // empty' | head -c 100)
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

if [ -n "$TMUX" ]; then
  printf '\033Ptmux;\033\033]9;%s\007\033\\' "$alert" > /dev/tty
else
  printf '\033]9;%s\033\\' "$alert" > /dev/tty
fi
