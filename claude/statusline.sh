#!/bin/bash
set -f

input=$(cat)

if [ -z "$input" ]; then
    printf "Claude"
    exit 0
fi

# ── Colors ──────────────────────────────────────────────
blue='\033[38;2;0;153;255m'
green='\033[38;2;0;175;80m'
cyan='\033[38;2;86;182;194m'
yellow='\033[38;2;255;193;7m'
red='\033[38;2;255;85;85m'
white='\033[38;2;220;220;220m'
magenta='\033[38;2;180;140;255m'
dim='\033[2m'
reset='\033[0m'

sep=" ${dim}│${reset} "

# ── Helpers ─────────────────────────────────────────────
is_num() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac; }

format_tokens() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
    elif [ "$num" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fk\", $num / 1000}"
    else
        printf "%d" "$num"
    fi
}

# ── Extract JSON data (single jq pass) ──────────────────
IFS=$'\t' read -r model_name size input_tokens cache_create cache_read \
    effort_level cwd duration_ms < <(
    echo "$input" | jq -r '[
        (.model.display_name // "Claude"),
        (.context_window.context_window_size // 200000),
        (.context_window.current_usage.input_tokens // 0),
        (.context_window.current_usage.cache_creation_input_tokens // 0),
        (.context_window.current_usage.cache_read_input_tokens // 0),
        (.effort.level // "-"),
        (.cwd // "-"),
        (.cost.total_duration_ms // 0)
    ] | @tsv' 2>/dev/null
)

[ -n "$model_name" ] || model_name="Claude"
is_num "$size" && [ "$size" -gt 0 ] || size=200000
is_num "$input_tokens" || input_tokens=0
is_num "$cache_create" || cache_create=0
is_num "$cache_read"   || cache_read=0
is_num "$duration_ms"  || duration_ms=0
[ "$effort_level" = "-" ] && effort_level=""

current=$(( input_tokens + cache_create + cache_read ))
pct_used=$(( current * 100 / size ))
used_tokens=$(format_tokens "$current")
total_tokens=$(format_tokens "$size")

# ── LINE 1: Model │ Context │ Directory (branch) │ Session │ Effort ──
if   [ "$pct_used" -ge 90 ]; then pct_color="$red"
elif [ "$pct_used" -ge 70 ]; then pct_color="$yellow"
elif [ "$pct_used" -ge 50 ]; then pct_color="$cyan"
else pct_color="$green"
fi

{ [ -z "$cwd" ] || [ "$cwd" = "-" ]; } && cwd=$(pwd)
dirname=$(basename "$cwd")

git_branch=""
git_dirty=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
        git_dirty="*"
    fi
fi

session_duration=""
elapsed=$(( duration_ms / 1000 ))
if [ "$elapsed" -ge 3600 ]; then
    session_duration="$(( elapsed / 3600 ))h$(( (elapsed % 3600) / 60 ))m"
elif [ "$elapsed" -ge 60 ]; then
    session_duration="$(( elapsed / 60 ))m"
elif [ "$elapsed" -gt 0 ]; then
    session_duration="${elapsed}s"
fi

line1="${blue}${model_name}${reset}"
line1+="${sep}"
line1+="${pct_color}ctx ${pct_used}% ${dim}(${used_tokens}/${total_tokens})${reset}"
line1+="${sep}"
line1+="${cyan}${dirname}${reset}"
if [ -n "$git_branch" ]; then
    line1+=" ${green}(${git_branch}${red}${git_dirty}${green})${reset}"
fi
if [ -n "$session_duration" ]; then
    line1+="${sep}"
    line1+="${dim}⏱ ${reset}${white}${session_duration}${reset}"
fi
line1+="${sep}"
if [ -n "$effort_level" ]; then
    case "$effort_level" in
        low)    line1+="${dim}◔ low${reset}" ;;
        medium) line1+="${cyan}◑ medium${reset}" ;;
        high)   line1+="${blue}◕ high${reset}" ;;
        xhigh)  line1+="${magenta}● xhigh${reset}" ;;
        max)    line1+="${red}◉ max${reset}" ;;
        *)      line1+="${dim}◑ ${effort_level}${reset}" ;;
    esac
else
    line1+="${dim}◑ thinking${reset}"
fi

# ── Output ─────────────────────────────────────────────
printf "%b" "$line1"

exit 0
