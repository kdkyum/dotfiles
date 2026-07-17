#!/bin/bash

# Notification failures must never interrupt Claude Code.
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat) || exit 0

# Sanitize untrusted model/tool text before it reaches a terminal sequence.
# Truncation uses Unicode code points rather than bytes, so UTF-8 remains valid.
alert=$(printf '%s' "$input" | jq -er '
  def clean($limit):
    tostring
    | explode
    | map(
        if . == 59 then 44
        elif . < 32 or (. >= 127 and . <= 159) then 32
        else .
        end
      )
    | implode
    | gsub(" +"; " ")
    | sub("^ +"; "")
    | sub(" +$"; "")
    | explode
    | .[:$limit]
    | implode
    | sub(" +$"; "");

  (.hook_event_name // "") as $event
  | if $event == "Stop" then
      (.last_assistant_message // "" | clean(120)) as $message
      | if $message == "" then
          "[DONE] Claude finished"
        else
          "[DONE] \($message)"
        end
    elif $event == "PermissionRequest" then
      (.tool_name // "unknown" | clean(60)) as $tool
      | (
          .tool_input.description
          // .tool_input.command
          // .tool_input.pattern
          // .tool_input.file_path
          // ""
          | clean(100)
        ) as $description
      | if $description == "" then
          "[🔐 PERMISSION] \($tool)"
        else
          "[🔐 PERMISSION] \($tool): \($description)"
        end
    else
      "[🔔 NOTIFY] Claude Code"
    end
') || exit 0

# Claude Code routes terminalSequence through the originating interface. Emit one
# OSC 777 notification only; direct TTY broadcasts, OSC 9, and BEL are avoided.
terminal_sequence=$(printf '\033]777;notify;Claude;%s\033\\' "$alert")
jq -nc --arg terminalSequence "$terminal_sequence" '{terminalSequence: $terminalSequence}'
exit 0
