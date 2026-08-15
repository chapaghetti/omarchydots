#!/usr/bin/env bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotbackups}"
MAX_BACKUPS=3

SOURCES=(
  "$HOME/.config/hypr"
  "$HOME/.config/omarchy"
  "$HOME/.bashrc.d"
  "$HOME/.bashrc"
)

RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

fatal() { echo "${RED}error: $*${RESET}" >&2; exit 1; }

list_backups() {
  local i label newest
  echo "${BOLD}Existing backups:${RESET}"
  for ((i = 1; i <= MAX_BACKUPS; i++)); do
    if [[ -d "$BACKUP_ROOT/$i" ]]; then
      newest=$(find "$BACKUP_ROOT/$i" -type f -not -name .timestamp -printf '%T@ %p\n' 2>/dev/null |
        sort -nr | awk 'NR == 1 { print $2 }')
      newest="${newest#"$BACKUP_ROOT/$i"/}"
      label=$(stat -c %y "$BACKUP_ROOT/$i" 2>/dev/null | cut -d. -f1)
      echo "  ${GREEN}$i${RESET}) $label  [last change: $newest]"
    else
      echo "  ${GREEN}$i${RESET}) (empty)"
    fi
  done
}

do_backup() {
  local slot=$1 dest="$BACKUP_ROOT/$1"
  local src exists=0

  rm -rf "$dest"
  mkdir -p "$dest"
  for src in "${SOURCES[@]}"; do
    if [[ -e "$src" ]]; then
      rsync -a --relative "$src" "$dest/" 2>/dev/null ||
        cp -a --parents "$src" "$dest/" 
      exists=1
    else
      echo "${YELLOW}warning: $src does not exist, skipping${RESET}" >&2
    fi
  done

  [[ $exists -eq 1 ]] || fatal "no sources found; nothing to back up"
  date > "$dest/.timestamp"
  echo "${GREEN}Backup written to $dest${RESET}"
}

used_slots() {
  local i c=0
  for ((i = 1; i <= MAX_BACKUPS; i++)); do
    [[ -d "$BACKUP_ROOT/$i" ]] && c=$((c + 1))
  done
  echo "$c"
}

main() {
  command -v rsync >/dev/null 2>&1 || echo "${YELLOW}rsync not found, falling back to cp${RESET}" >&2

  if [[ ! -d "$BACKUP_ROOT" ]]; then
    mkdir -p "$BACKUP_ROOT"
    echo "No backups yet; creating $BACKUP_ROOT"
    do_backup 1
    exit 0
  fi

  list_backups
  echo
  echo "${BOLD}Which slot should this new backup overwrite?${RESET}"
  echo "  Enter a number 1-$MAX_BACKUPS"
  [[ $(used_slots) -lt $MAX_BACKUPS ]] && echo "  (or an empty slot to keep your history)"
  echo "  q = quit"

  local choice
  while :; do
    read -rp "> " choice
    [[ "$choice" == "q" || "$choice" == "Q" ]] && { echo "Aborted."; exit 1; }
    if [[ "$choice" =~ ^[1-9]$ ]] && ((choice >= 1 && choice <= MAX_BACKUPS)); then
      break
    fi
    echo "${YELLOW}Invalid choice; pick 1-$MAX_BACKUPS or q.${RESET}" >&2
  done

  if [[ -d "$BACKUP_ROOT/$choice" ]]; then
    read -rp "Overwrite backup #$choice? [y/N] " confirm
    [[ "$confirm" =~ ^[yY]$ ]] || { echo "Aborted."; exit 1; }
  fi

  do_backup "$choice"
}

main "$@"
