#!/bin/bash
read -r input

message=$(echo "$input" | jq -r '.message // "Claude Code"')
title=$(echo "$input" | jq -r '.title // empty')
ntype=$(echo "$input" | jq -r '.notification_type // empty')
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')

case "$ntype" in
  permission_prompt)   prefix="🔐 PERMISSION" ;;
  idle_prompt)         prefix="💤 IDLE" ;;
  auth_success)        prefix="✅ AUTH OK" ;;
  elicitation_dialog)  prefix="❓ INPUT NEEDED" ;;
  *)
    if [ "$hook_event" = "Stop" ]; then
      prefix="🏁 DONE"
    else
      prefix="🔔 NOTIFY"
    fi
    ;;
esac

if [ -n "$title" ]; then
  alert="[$prefix] $title — $message"
else
  alert="[$prefix] $message"
fi

if [ -n "$TMUX" ]; then
  printf '\033Ptmux;\033\033]9;%s\007\033\\' "$alert" > /dev/tty
else
  printf '\033]9;%s\033\\' "$alert" > /dev/tty
fi
