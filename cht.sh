#!/usr/bin/env bash
# cht — interactive cht.sh wrapper with fzf
# Usage: cht [topic]   or just: cht

set -euo pipefail

# ── config ──────────────────────────────────────────────────────────────────
CHT_URL="https://cht.sh"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cht"
CACHE_TTL=86400   # seconds before refreshing topic list (24h)
TOPICS_FILE="$CACHE_DIR/topics.txt"
PAGER="${PAGER:-less -R}"

# ── colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
YELLOW='\033[0;33m'; BOLD='\033[1m'; RESET='\033[0m'

# ── helpers ──────────────────────────────────────────────────────────────────
die()  { echo -e "${RED}error:${RESET} $*" >&2; exit 1; }
info() { echo -e "${CYAN}::${RESET} $*" >&2; }

require() {
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || die "'$cmd' is required but not installed."
  done
}

# ── fetch & cache topic list ─────────────────────────────────────────────────
refresh_topics() {
  mkdir -p "$CACHE_DIR"
  info "refreshing topic list from cht.sh…"
  curl -fsSL "$CHT_URL/:list" -o "$TOPICS_FILE.tmp" \
    || die "could not reach $CHT_URL"
  mv "$TOPICS_FILE.tmp" "$TOPICS_FILE"
}

ensure_topics() {
  local now stale_after
  now=$(date +%s)

  if [[ ! -f "$TOPICS_FILE" ]]; then
    refresh_topics
    return
  fi

  # check age (works on Linux; macOS needs stat -f %m)
  local mtime
  if stat --version &>/dev/null 2>&1; then
    mtime=$(stat -c %Y "$TOPICS_FILE")      # GNU
  else
    mtime=$(stat -f %m "$TOPICS_FILE")      # BSD/macOS
  fi

  stale_after=$(( mtime + CACHE_TTL ))
  if (( now > stale_after )); then
    refresh_topics
  fi
}

# ── filter topics for a prefix ───────────────────────────────────────────────
topics_for() {
  local prefix="$1"
  if [[ -z "$prefix" ]]; then
    cat "$TOPICS_FILE"
  else
    grep -i "^${prefix}" "$TOPICS_FILE" 2>/dev/null \
      || grep -i "${prefix}" "$TOPICS_FILE" 2>/dev/null \
      || cat "$TOPICS_FILE"
  fi
}

# ── fzf picker ───────────────────────────────────────────────────────────────
pick_topic() {
  local initial_query="${1:-}"

  # preview command: show a short snippet from cht.sh
  local preview_cmd="curl -fsSL --max-time 5 '$CHT_URL/{}' 2>/dev/null | head -40"

  topics_for "$initial_query" | fzf \
    --ansi \
    --height=100% \
    --layout=reverse \
    --border=rounded \
    --prompt="  cht.sh > " \
    --pointer="▶" \
    --marker="✓" \
    --query="$initial_query" \
    --header=$'  \033[36menter\033[0m select  \033[36mctrl-r\033[0m refresh  \033[36mesc\033[0m quit' \
    --preview="$preview_cmd" \
    --preview-window="right:55%:wrap" \
    --bind="ctrl-r:reload(curl -fsSL '$CHT_URL/:list' 2>/dev/null && echo refreshed >&2)" \
    --bind="tab:down,shift-tab:up" \
    --bind="ctrl-/:toggle-preview" \
    --info=inline \
    || true
}

# ── subtopic picker ───────────────────────────────────────────────────────────
pick_subtopic() {
  local topic="$1"

  # list subtopics: cht.sh/<topic>/:list
  local subtopics
  subtopics=$(curl -fsSL --max-time 8 "$CHT_URL/${topic}/:list" 2>/dev/null) || true

  if [[ -z "$subtopics" ]]; then
    echo ""   # no subtopics, caller will use bare topic
    return
  fi

  local preview_cmd="curl -fsSL --max-time 5 '$CHT_URL/${topic}/{}' 2>/dev/null | head -40"

  echo "$subtopics" | fzf \
    --ansi \
    --height=80% \
    --layout=reverse \
    --border=rounded \
    --prompt="  ${topic} > " \
    --pointer="▶" \
    --header=$"  \033[36m${topic}\033[0m subtopics — \033[36menter\033[0m to view  \033[36mesc\033[0m to skip" \
    --preview="$preview_cmd" \
    --preview-window="right:55%:wrap" \
    --bind="tab:down,shift-tab:up" \
    --bind="ctrl-/:toggle-preview" \
    --info=inline \
    || true
}

# ── run pager (handles pagers with flags like "bat --paging=always") ──────────
run_pager() {
  # eval word-splits PAGER so flags work: e.g. "bat --paging=always --style=changes"
  # cht.sh already returns ANSI-colored output, so no extra flags needed.
  eval "$PAGER"
}

# ── display result ────────────────────────────────────────────────────────────
show() {
  local query="$1"
  # cht.sh returns ANSI-colored output by default — no flags needed.
  echo -e "\n${BOLD}${CYAN}cht.sh/${query}${RESET}\n" >&2
  curl -fsSL "${CHT_URL}/${query}" | run_pager
}

# ── copy to clipboard (best-effort) ──────────────────────────────────────────
maybe_copy() {
  local text="$1"
  if command -v pbcopy &>/dev/null; then
    printf '%s' "$text" | pbcopy && echo -e "${GREEN}✓${RESET} copied to clipboard" >&2
  elif command -v xclip &>/dev/null; then
    printf '%s' "$text" | xclip -selection clipboard && echo -e "${GREEN}✓${RESET} copied to clipboard" >&2
  elif command -v xsel &>/dev/null; then
    printf '%s' "$text" | xsel --clipboard --input && echo -e "${GREEN}✓${RESET} copied to clipboard" >&2
  elif command -v wl-copy &>/dev/null; then
    printf '%s' "$text" | wl-copy && echo -e "${GREEN}✓${RESET} copied to clipboard" >&2
  fi
}

# ── main ──────────────────────────────────────────────────────────────────────
main() {
  require curl fzf

  local initial="${1:-}"

  # Refresh flag
  if [[ "$initial" == "--refresh" || "$initial" == "-r" ]]; then
    refresh_topics
    info "topic list refreshed."
    exit 0
  fi

  # Help
  if [[ "$initial" == "--help" || "$initial" == "-h" ]]; then
    echo -e "${BOLD}cht${RESET} — interactive cht.sh with fzf"
    echo
    echo "  ${CYAN}cht${RESET}            open topic picker"
    echo "  ${CYAN}cht go${RESET}         pre-filter to 'go' topics"
    echo "  ${CYAN}cht go/map${RESET}     jump straight to go/map"
    echo "  ${CYAN}cht --refresh${RESET}  force-refresh topic cache"
    echo
    echo "  inside fzf:"
    echo "    ${YELLOW}tab/${RESET}        next / prev item"
    echo "    ${YELLOW}enter${RESET}        select topic"
    echo "    ${YELLOW}ctrl-/${RESET}       toggle preview pane"
    echo "    ${YELLOW}ctrl-r${RESET}       refresh topic list"
    echo "    ${YELLOW}esc${RESET}          quit"
    exit 0
  fi

  # If given a direct topic/subtopic (e.g. "go/map"), skip picker
  if [[ "$initial" == *"/"* ]]; then
    show "$initial"
    exit 0
  fi

  ensure_topics

  # Step 1: pick topic
  local topic
  topic=$(pick_topic "$initial")

  if [[ -z "$topic" ]]; then
    echo -e "${YELLOW}cancelled.${RESET}" >&2
    exit 0
  fi

  # Step 2: optionally pick subtopic
  local subtopic
  subtopic=$(pick_subtopic "$topic")

  local query
  if [[ -n "$subtopic" ]]; then
    query="${topic}/${subtopic}"
  else
    query="$topic"
  fi

  # Step 3: fetch and display

  local result
  result=$(curl -fsSL "${CHT_URL}/${query}" 2>/dev/null) \
    || die "failed to fetch $CHT_URL/$query"

  show "$query"

  # Step 4: offer to copy (uses the plain-text result, not ANSI version)
  echo >&2
  read -rp $'\033[36m?\033[0m copy to clipboard? [y/N] ' yn
  if [[ "${yn,,}" == "y" ]]; then
    maybe_copy "$result"
  fi
}

main "$@"
